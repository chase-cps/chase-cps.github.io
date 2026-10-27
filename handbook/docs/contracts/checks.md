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
| both of them | compatible and consistent | `verify(c)` |
| implementation M ⊨ C | M ∧ A → G is valid | `implements(m, c)` |
| acceptance of an environment E | E → A is valid | `accepts(c, e)` |
| no redundant terms | each term is not implied by the others | `remove_redundant(c)` |

M and E are LTL formulas over the variables of the contract. A failed check
comes with a counterexample: a behavior that breaks it.

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
verify(c.assume(FINITE)).status      # sat
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

!!! note "Integers out of range"
    `load_spec` warns when an integer is compared with a constant outside its
    range, for instance `credits >= 90` with `credits` declared without a
    range (so 0 to 16): such a comparison has the same value at every step.

## Results

| Check | Answers |
|---|---|
| `implies`, `refines`, `implements`, `accepts` | `valid`, `invalid` |
| `is_satisfiable`, `is_compatible`, `is_consistent`, `verify` | `sat`, `unsat` |
| any check | `unknown`, with a `reason` (time out, no tool installed) |

A trace is a list of states, `prefix` then `loop`, the loop repeated forever.
`to_dict()` gives the result as JSON.
