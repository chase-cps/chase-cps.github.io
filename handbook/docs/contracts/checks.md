# 2. Checks

The checks answer questions about contracts: does one refine another, can it
be met at all. Each one reduces to the **validity** or the **satisfiability**
of a formula, which a model checker decides. In CHASE the formulas are LTL
over Boolean, bounded integer, and real variables, and the model checker is
nuXmv (or NuSMV).

## Checks on contracts

| Check | Holds when | Python |
|---|---|---|
| refinement C1 ⪯ C2 | A2 → A1 and (A1→G1) → (A2→G2) are valid | `refines(c1, c2)` |
| compatibility | some environment satisfies A | `is_compatible(c)` |
| consistency | some behavior satisfies A → G | `is_consistent(c)` |
| assumptions and guarantees together | A ∧ G is satisfiable (so compatible and consistent) | `verify(c)` |
| implementation M ⊨ C | M ∧ A → G is valid, or every behavior of the state machine M satisfies A → G | `implements(m, c)` |
| acceptance of an environment E | E → A is valid, or every behavior of E satisfies A | `accepts(c, e)` |
| receptiveness of a state machine M | M refuses no input that the assumptions allow | `is_receptive(m, c)` |
| no redundant terms | each term is not implied by the others | `remove_redundant(c)` |

M and E are LTL formulas over the variables of the contract. A failed check
comes with a counterexample: a behavior that breaks it.

`remove_redundant(c)` drops the terms implied by the others. Which terms it
may drop depends on what the contract is for next:

| Next | Call | Keeps |
|---|---|---|
| the algebra and the checks | `remove_redundant(c)` | A → G |
| synthesis ([layer 3](synthesis.md#redundancy-in-the-gr1-game)) | `remove_redundant(c, synth=True)` | realizability and the controllers |

The two differ only when the assumptions are wrong, for instance
unsatisfiable. With `core=True`, each removed term comes with the terms
that imply it.

```python
r = refines(impl, spec)
r.status        # "valid" or "invalid"
r.failed        # "assumptions" or "guarantees", when invalid
r.guarantees.trace
```

## Queries on formulas

The checks above are built on two queries, which can also be called directly:

| Query | Question | Answer |
|---|---|---|
| `implies(phi, psi, variables)` | **validity**: does phi → psi hold for every behavior? | `valid`, or `invalid` with a behavior that satisfies phi and violates psi |
| `is_satisfiable(phi, variables)` | **satisfiability**: does some behavior satisfy phi? | `sat` with such a behavior, or `unsat` |

!!! note "A formula is satisfiable; a component satisfies a contract"
    `is_satisfiable` asks whether some behavior (a value of each variable at
    each step) satisfies a formula. Whether a component satisfies a contract
    is `implements(m, c)`.

## Cores: why a check fails

When the terms of a contract cannot hold together, `unsat_core` gives a
minimal set of them that cannot: remove any one, and the others can.

```python
from chase_cps import Contract, ltl, unsat_core, verify

bad = Contract.from_strings(inputs=["req"], outputs=["grant"], name="Bad",
                            guarantees=["G (req -> X grant)", "G !grant", "F req"])
print(verify(bad).status)
print([ltl.to_str(g) for g in unsat_core(bad).core.guarantees])
```

```
unsat
['G (req -> X grant)', 'G !grant', 'F req']
```

What the core says depends on what is in it:

- only assumptions: the contract is not compatible;
- only guarantees: the guarantees contradict each other;
- both: the guarantees cannot hold when the assumptions do.

`is_compatible(c, core=True)`, `is_consistent(c, core=True)`, and
`is_satisfiable(phi, variables, core=True)` return the core with a failed
result. The search is delta debugging, one call to nuXmv per test.

## Context

Some formulas are neither an assumption nor a guarantee: they say what any
behavior is like. Examples are the axiom of an encoding of finite traces, a
physical law, or "one tool call at each step". Pass them as `context`, and
the checks only look at the behaviors that satisfy them.

**Example.** Finite traces are often encoded with a variable `alive`, true
for the length of the trace and false after it; the axiom
`alive & (alive U G !alive)` says that a trace starts and ends. These two
guarantees contradict each other on every finite trace:

```python
FINITE = "alive & (alive U G !alive)"
c = Contract.from_strings(inputs=["alive"], outputs=["a"], name="C",
                          guarantees=["G (alive -> a)", "G (alive -> !a)"])
verify(c).status                     # sat
verify(c, context=FINITE).status     # unsat
is_consistent(c.assume(FINITE)).status   # sat
```

Without the context, the behavior where `alive` is false from the start
satisfies both guarantees. With the context, that behavior is left out.

!!! warning "A context is not an assumption"
    As an assumption the axiom does not help (the last line): a behavior that
    violates an assumption satisfies the contract, since A → G holds. A
    behavior that violates the context does not count at all.

`context` is taken by `implies`, `is_satisfiable`, `is_compatible`,
`is_consistent`, `verify`, `refines`, `remove_redundant`, `accepts`,
`implements`, and `unsat_core` (the context is in every test, never in the
core). The [GR(1) synthesis](synthesis.md) checks do not take it.

## Real variables

A variable of type `real` takes any real value. The checks use one of three
ways, in this order, and the result says which one in `reals`:

| `reals` | Used when | Exact | Realizability |
|---|---|---|---|
| `regions` | the real variables are only compared with constants, or with each other without arithmetic | yes | yes |
| `smt` | otherwise: the SMT engine of nuXmv | yes for linear arithmetic; nonlinear may not finish (30 s at most) | no |
| `predicates` | nuXmv gives no answer: each comparison becomes a Boolean | only `valid` and `unsat` are returned; z3 (`pip install chase-cps[reals]`) can make the others exact | no |

With `regions`, a variable compared with the constants c1 < … < ck is replaced
by the interval it falls in: (−∞, c1), c1, (c1, c2), …, ck, (ck, ∞). The
counterexamples still show real values, and synthesized controllers state
conditions such as `30.5 < kias < 40`. The
[Lift-Plus-Cruise demo](../demos/lift-plus-cruise.md) uses real variables.

## Words

A word is a bit vector of a fixed width, as a register of a circuit:
`"word[8]"` is unsigned, `"signed word[8]"` is in two's complement, and the
arithmetic wraps around (for a `word[8]` equal to 255, x + 1 = 0).

| Operator | Meaning |
|---|---|
| `+ - * / mod` | arithmetic modulo 2^n |
| `& \| xor !` | bitwise; in a relation, parenthesize them: `(x & y) = 0` |
| `<< >>` | shifts by a number |
| `x :: y` | concatenation, x on the high bits |
| `x[7:4]`, `x[3]` | bits; a single bit can be used as a Boolean |
| `extend(x, n)`, `signed(x)`, `unsigned(x)` | n more bits; the same bits read as signed or unsigned |

Both operands of an operation have the same width and signedness, and an
integer constant takes the type of the other operand. The checks give the
words to nuXmv. The contract algebra takes contracts with words; GR(1)
synthesis (slugs) and the logics language do not.

## Past values

`x'` is the value of x at the next step, and `past(x, n)` its value n steps
before, for a variable of any type: `G X X (y = past(x, 2))` says that y is
x delayed by two steps. In the first n steps `past(x, n)` is any value, so
write it under `X` as here. nuXmv keeps the past values in history
variables. GR(1) synthesis and the logics language do not take `past`.

## Engines

nuXmv checks the formulas with IC3 and BDDs at the same time, and the first
verdict is taken. Both engines prove and refute, so the verdict does not
depend on which one answers; the counterexample may. One engine can be
chosen with `engine`, or in the back end, as the results name it:

| Engine | Proves | Finds counterexamples | Good for |
|---|---|---|---|
| `portfolio` (default) | yes | yes | IC3 and BDDs at the same time |
| `ic3` | yes | yes | large state spaces, words, reals |
| `bdd` | yes | yes | a counterexample that needs a long loop (a counter that goes around) |
| `bmc` | no | up to `bmc_bound` steps | short counterexamples |

```
from chase_cps import implies

r = implies("cnt = 254 & G (cnt' = cnt + 1)", "X (cnt = 0)", {"cnt": "word[8]"},
            "nuxmv/bdd")
print(r.status, r.backend)      # invalid nuxmv/bdd
```

On the command line the option is `--engine`. Formulas with `signed()` or
`unsigned()` are checked with BDDs only: IC3 of nuXmv 2.2.0 gives wrong
answers on them.

!!! note "Integers out of range"
    `load_spec` warns when an integer is compared with a constant outside its
    range, for instance `credits >= 90` with `credits` declared without a
    range (so 0 to 16): such a comparison has the same value at every step.

## Results

| Check | Answers |
|---|---|
| `implies`, `refines`, `implements`, `accepts` | `valid`, `invalid` |
| `is_satisfiable`, `is_compatible`, `is_consistent`, `verify` | `sat`, `unsat` |
| `is_receptive` | `receptive`, `not_receptive` |
| any check | `unknown`, with a `reason` (time out, no tool installed) |

A trace is a list of states, `prefix` then `loop`, the loop repeated forever.
`to_dict()` gives the result as JSON.
