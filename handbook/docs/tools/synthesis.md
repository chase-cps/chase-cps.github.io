# GR(1) synthesis

The algebra and the verification tasks hold for any contracts. This page is
about contracts in the GR(1) fragment of LTL, for which a component can be
synthesized. The analyses ask whether a **component can be
synthesized** from a contract: a controller that sets the outputs so that the guarantees
hold against every environment that sets the inputs and meets the
assumptions. This depends on the synthesis approach, here GR(1) with
[slugs](https://github.com/VerifiableRobotics/slugs); it is not a property of
contracts in general.

The examples below are from the [Charger demo](../demos/charger.md): two
robots ask for a charging station (`req1`, `req2`), and an arbiter gives it
(`grant1`, `grant2`).

## The GR(1) form

Each assumption and guarantee must be one of:

| Kind | Form | Example |
|---|---|---|
| initial | no temporal operator | `!grant1` |
| safety | `G f`, with only `X` (or `x'`) in f | `G !(grant1 & grant2)` |
| justice | `G F f` | `G F req1` |

In addition, the environment cannot read the next value of the outputs: the
initial assumptions read the inputs only, and the safety assumptions read
only the next value of the inputs. A contract that is not in this form gives
`unknown`, with the term at fault.

## Realizability and synthesis

| Python | Answer |
|---|---|
| `is_realizable(c)` | `realizable`, or `unrealizable` with the counter-strategy of the environment |
| `synthesize(c)` | the same, and the controller (a state machine) when realizable |

**Example.** The arbiter *Greedy* gives the station to a robot at the next
step after its request, and never to both:

```
G (req1 -> X grant1)     R6.1
G (req2 -> X grant2)     R6.2
G !(grant1 & grant2)     R5
```

When both robots ask at once, it cannot keep its promise: *Greedy* is
unrealizable. The arbiter *Fair* promises a grant eventually instead,
`G F (grant1 | !req1)`, and is realizable:

```python
cs = load_spec("Charger/charger.ltl")
is_realizable(cs["Greedy"]).status      # unrealizable
r = synthesize(cs["Fair"])              # realizable, a controller with 18 states
```

## Other GR(1) solvers

slugs is the solver that CHASE runs. For another one, `to_gr1c(c)` writes
the contract as the input of [gr1c](https://github.com/tulip-control/gr1c),
as `to_sva` writes it for the tools of SystemVerilog:

```python
open("fair.spc", "w").write(to_gr1c(cs["Fair"]))
# gr1c -r fair.spc      realizability
# gr1c fair.spc         a controller
```

The inputs of the contract are the variables of the environment, its
outputs those of the system. gr1c compares an integer only with a constant,
so a relation with arithmetic or between variables (`x' = x + 1`) is
written as the values that satisfy it.

## Unrealizable cores

An unrealizable contract can have many guarantees. `unrealizable_core` (or
`is_realizable(c, core=True)`) gives a minimal set of guarantees that is
unrealizable under all the assumptions: remove any one, and the rest is
realizable.

```python
r = is_realizable(cs["Greedy"], core=True)
r.core.core.guarantees
```

```
G (req1 -> X grant1)
G (req2 -> X grant2)
G !(grant1 & grant2)
```

The two initial guarantees of *Greedy* (`!grant1`, `!grant2`) are not in the
core: they play no part in the conflict. The search shrinks the justice
guarantees first, then the safety ones, then the initial ones (QuickCore,
Maoz and Shalom, ICSE 2021), one call to slugs per test.

## Well-separation

A contract is realizable for a bad reason when the controller can win by
making the environment break its assumptions. Such a controller satisfies
the contract (A → G holds when A fails) without doing its job.

**Example.** The arbiter *Pushy* assumes two things about robot 1:

```
G F req1                     A2   robot 1 asks infinitely often
G (grant1 -> X !req1)        A3   robot 1 stops asking after a grant
```

If the arbiter gives `grant1` at every step, A3 makes robot 1 stop asking
from the next step on, and A2 can then never hold. The arbiter wins without
serving anybody. `is_well_separated` finds it:

```python
r = is_well_separated(cs["Pushy"], core=True)
r.status                     # not_separated
r.core.core.assumptions      # A2 and A3
r.controller                 # the strategy that forces the violation
is_well_separated(cs["Polite"]).status     # separated
```

*Polite* assumes `G ((req1 & grant1) -> X !req1)` instead of A3: robot 1 stops
asking only after a grant it asked for. The arbiter can no longer force a
violation, and the contract is well-separated.

The check is one realizability check with slugs, with the goal of the
controller replaced by `G F false` (Klein and Pnueli, HVC 2010; Maoz and
Ringert, FSE 2016): if the controller can still win, it can only win by
breaking the assumptions. The controller must keep its initial and safety
guarantees while it does so (Def. 4 of Maoz and Ringert): a violation it can
force only by breaking its own guarantees is not a defect of the
assumptions. `with_guarantees=False` leaves the guarantees out (Def. 2).
Only violations that can be forced from every initial state are detected.

## Vacuity

A contract is vacuous when the controller can win without an output that a
liveness guarantee asks for: the assumptions already make the guarantee
hold, and it obliges nothing. `is_vacuous` strengthens the guarantees and
asks slugs whether the contract is still realizable (Bloem, Chockler,
Ebrahimi, and Strichman, FMSD 2021):

| Mode | Query, for an output y | Meaning |
|---|---|---|
| never | A, G + {G !y} | a winning strategy never sets y |
| eventually | A, G + {!p, G (p → X p), G (p → !y), G F p}, p a new output | a winning strategy stops setting y from some step on |

The outputs checked are those that a justice guarantee asks to set (they
occur only positively in it).

**Example.** *Fair* is not vacuous: it cannot win without granting each
robot. An arbiter that trusts the robots to stop asking on their own is:

```python
fair = cs["Fair"]
trusting = Contract("Trusting", fair.inputs, fair.outputs,
                    [ltl.parse("G F !req1"), ltl.parse("G F !req2")], fair.guarantees)
is_vacuous(fair).status                  # not_vacuous
r = is_vacuous(trusting, core=True)
for v in r.vacuous:
    print(v.output, v.mode, [ltl.to_str(a) for a in v.core.core])
```

```
grant1 never ['G F !req1']
grant2 never ['G F !req2']
```

With G F !req1, the guarantee G F (grant1 | !req1) holds without any grant.
The core is the assumption that makes it so; it is too strong.

!!! note "Two weaker tests are not used"
    The test on a controller M, M ∧ A → φ[y ← false], and the rewrite
    Real(A, G[y ← false]) both call a good controller vacuous when an
    assumption ties the release of the environment to y, such as
    G ((req ∧ grant) → X !req): the controller grants, the request is
    released, and φ[grant ← false] holds because it granted. Forcing y false
    in the behavior asks the right question.

## Redundancy in the GR(1) game

A term is redundant in the game when removing it does not change the
synthesis problem: the same contracts are realizable, with the same
controllers (the inherent vacuity of Maoz and Shalom, ESEC/FSE 2020).
`remove_redundant(c, synth=True)` removes these terms.

**Example.** *Fair* has these justice guarantees:

```
G F (grant1 | !req1)             R7.1
G F (grant2 | !req2)             R7.2
G F (grant1 | !req1 | grant2)    R8
```

R8 is weaker than R7.1, so it adds nothing:

```python
v = remove_redundant(cs["Fair"], synth=True, core=True)
for t in v.removed:
    print(t.part, t.kind, ltl.to_str(t.term), [ltl.to_str(x) for x in t.core])
```

```
guarantee justice G F (grant1 | !req1 | grant2) ['G F (grant1 | !req1)']
```

Each term is compared with a premise set that depends on its kind, one call
to nuXmv per term:

| Kind | Premise set |
|---|---|
| initial | the other initial terms of its side; for a guarantee, also the initial assumptions |
| safety `G t` | the bodies of the other safety terms of its side (for a guarantee, also of the safety assumptions), as a propositional implication over the current and next values |
| justice `G F j` | the initial and safety terms of both sides, and the other justice terms of its side; for a guarantee, also the justice assumptions |

### With or without `synth`?

Without `synth`, `remove_redundant` ([contract-based verification](../contracts/checks.md)) keeps A → G
instead. On *Fair* both remove R8. They differ when the assumptions are
wrong:

| Contract | `remove_redundant(c)` | `remove_redundant(c, synth=True)` |
|---|---|---|
| A: G F (x ∧ !x); G: G g, G !g | drops both guarantees, since A cannot hold: now realizable | drops nothing: unrealizable, as before |
| A: G F g; G: G g | drops nothing | drops G F g: the component keeps G g anyway, but the contract is stronger |

In the game, the component must keep its safety guarantees even when the
environment breaks its justice assumptions; and an assumption that the
guarantees make hold does not matter in the game, but it does for A → G.
Use `synth=True` before synthesis, and the default before the algebra and
the checks.
