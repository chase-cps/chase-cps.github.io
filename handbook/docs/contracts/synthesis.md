# <span class="tag l3">3</span> GR(1) synthesis

The analyses of this layer ask whether a **component can be synthesized**
from a contract: a controller that sets the outputs so that the guarantees
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
breaking the assumptions. With `with_guarantees=True` it must also keep its
initial and safety guarantees. Only violations that can be forced from every
initial state are detected.

## Vacuity

A term is vacuous when removing it does not change the synthesis problem: the
same contracts are realizable, with the same controllers (inherent vacuity,
Maoz and Shalom, ESEC/FSE 2020).

**Example.** *Fair* has these justice guarantees:

```
G F (grant1 | !req1)             R7.1
G F (grant2 | !req2)             R7.2
G F (grant1 | !req1 | grant2)    R8
```

R8 is weaker than R7.1, so it adds nothing:

```python
v = remove_vacuous(cs["Fair"], core=True)
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

### Vacuity or redundancy?

`remove_redundant` ([layer 2](checks.md)) also removes the terms implied by
the others. Here both remove R8; they differ in what they keep:

| | `remove_redundant` | `remove_vacuous` |
|---|---|---|
| keeps | the behaviors of A → G | realizability and the controllers |
| may remove | a term that follows from the others only over whole traces | only a term whose removal leaves the game unchanged |
| use it for | specifications that are checked | specifications that are synthesized |
