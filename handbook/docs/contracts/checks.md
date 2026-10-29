# Contract-based verification

The verification tasks on contracts ask whether one contract refines
another, whether a contract can be met at all, and whether a component or an
environment satisfies a contract. They are defined on behaviors, for any
assume-guarantee contracts. CHASE carries them out for contracts in LTL over
Boolean, bounded integer, real, and word variables: each task reduces to the
**validity** or the **satisfiability** of a formula, which a model checker
decides ([back ends](../tools/model-checking.md)).

## Verification tasks

| Task | Holds when | Python |
|---|---|---|
| refinement C1 ⪯ C2 | A2 → A1 and (A1→G1) → (A2→G2) are valid | `refines(c1, c2)` |
| compatibility | some environment satisfies A | `is_compatible(c)` |
| consistency | some behavior satisfies A → G | `is_consistent(c)` |
| assumptions and guarantees together | A ∧ G is satisfiable (so compatible and consistent) | `verify(c)` |
| implementation M ⊨<sub>M</sub> C | M ∧ A → G is valid, or every behavior of the state machine M satisfies A → G | `is_implementation(m, c)` |
| environment E ⊨<sub>E</sub> C | E → A is valid, or every behavior of E satisfies A | `is_environment(e, c)` |
| receptiveness of a state machine M | M refuses no input that the assumptions allow | `is_receptive(m, c)` |
| no redundant terms | each term is not implied by the others | `remove_redundant(c)` |

M and E are LTL formulas over the variables of the contract. A failed check
comes with a counterexample: a behavior that breaks it.

`remove_redundant(c)` drops the terms implied by the others. Which terms it
may drop depends on what the contract is for next:

| Next | Call | Keeps |
|---|---|---|
| the algebra and verification | `remove_redundant(c)` | A → G |
| [GR(1) synthesis](../tools/synthesis.md#redundancy-in-the-gr1-game) | `remove_redundant(c, synth=True)` | realizability and the controllers |

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
    is `is_implementation(m, c)`.

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
`is_consistent`, `verify`, `refines`, `remove_redundant`, `is_environment`,
`is_implementation`, and `unsat_core` (the context is in every test, never in the
core). The [GR(1) synthesis](../tools/synthesis.md) checks do not take it.

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

## Words and past values

The checks give the words (bit vectors, `"word[8]"`) and `past(x, n)` to
nuXmv as they are; nuXmv keeps the past values in history variables. The
values of words in the traces are integers. The operators are in
[Formulas](formulas.md).

## RTL

A Verilog or SystemVerilog module is a state machine too:
`Model.from_rtl(files, top)` reads it with Yosys
(`pip install chase-cps[rtl]`), and `is_implementation`, `is_environment`, and
`is_receptive` take it. The ports are the variables of the contracts (a
1-bit port is a Boolean, a wider one a word), and one step is one cycle of
the clock.

```
from chase_cps import Model, is_implementation

m = Model.from_rtl(["bsg_dff_reset.sv", "bsg_dff_en.sv", "bsg_one_fifo.sv"],
                   "bsg_one_fifo", parameters={"width_p": 4}, reset="reset_i",
                   names={"ready_and_o": "ready_o"})
print(is_implementation(m, slot).status)
```

`parameters` sets parameters of the top module, `names` renames ports, and
`defines` gives macros. With `reset`, the reset holds in the first step and
the contracts are checked from the step after it. The checks are those of
nuXmv, for small and medium designs; the [BufferSwap demo](../demos/buffer-swap.md)
checks the RTL of two FIFOs.

## Results

| Check | Answers |
|---|---|
| `implies`, `refines`, `is_implementation`, `is_environment` | `valid`, `invalid` |
| `is_satisfiable`, `is_compatible`, `is_consistent`, `verify` | `sat`, `unsat` |
| `is_receptive` | `receptive`, `not_receptive` |
| any check | `unknown`, with a `reason` (time out, no tool installed) |

A trace is a list of states, `prefix` then `loop`, the loop repeated forever.
`to_dict()` gives the result as JSON.
