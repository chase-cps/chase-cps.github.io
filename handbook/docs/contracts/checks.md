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

`remove_redundant(c)` drops the terms implied by the others, keeping
A → G; before synthesis, use `remove_redundant(c, synth=True)`
([GR(1) synthesis](../tools/synthesis.md#redundancy-in-the-gr1-game)). With
`core=True`, each removed term comes with the terms that imply it.

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
result.

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

All the checks on this page take a `context`; the
[GR(1) synthesis](../tools/synthesis.md) checks do not.

## Real variables

A `real` variable takes any real value. When the reals are only compared
with constants, or with each other, the checks are exact and work for
synthesis too: each real is replaced by the interval between two constants
it falls in. Otherwise nuXmv decides them with its SMT engine, exact for
linear arithmetic. The result says which in `reals`. The
[Lift-Plus-Cruise demo](../demos/lift-plus-cruise.md) uses real variables.

Words (bit vectors) and `past(x, n)` go to nuXmv as they are; the values of
words in the traces are integers.

## RTL

A Verilog or SystemVerilog module is checked as a state machine, read with
Yosys: see [Hardware: SVA and RTL](../tools/systemverilog.md#rtl).

## Results

The checks of every behavior (`implies`, `refines`, `is_implementation`,
`is_environment`) answer `valid` or `invalid`; those of some behavior
(`is_satisfiable`, `is_compatible`, `is_consistent`, `verify`) answer `sat`
or `unsat`; `is_receptive` answers `receptive` or `not_receptive`. Any check
may answer `unknown`, with a `reason` (a time out, no tool installed).

A trace is a list of states, `prefix` then `loop`, the loop repeated forever.
`to_dict()` gives the result as JSON.

## Formulas over a bounded number of steps

A formula with no `G`, `F`, `U`, `R` reads a bounded number of steps (`X`,
`x'`, `past(x, n)`, and intervals such as `G[0,10] p`). A contract made of
formulas of one step is a static contract: a budget, a sizing, a choice of
parts. With z3 installed (`pip install chase-cps[z3]`), such formulas are
checked by z3 instead of nuXmv, exactly for linear arithmetic over integers
and reals, with any Boolean structure.

`minimize(objective, constraints)` and `maximize(objective, constraints)`
give the best value of a term where the constraints hold, and the values
that reach it:

```python
from chase_cps import Contract, maximize, minimize

gen = Contract.from_strings(name="Gen", inputs={"n": (0, 20)}, outputs={"p": "real"},
                            assumptions=["n <= 4"], guarantees=["p >= 2.5 * n", "p <= 30"])
print(maximize("n", gen).value)            # 4
print(minimize("p - 2.5 * n", gen).value)  # 0: the guarantee p >= 2.5 n is tight
```

The status is `optimal`, `not_attained` (the bound of a strict inequality),
`unbounded`, `infeasible`, or `unknown`. When the objective is a formula,
its robustness (below) is minimized: its worst case under the constraints.

## Robustness

The robustness of a formula on a trace says how much the trace satisfies
it (a positive number) or violates it (a negative number), in the unit of
the terms. It is the quantitative semantics of signal temporal logic, in
discrete time, on the traces of the checks:

- a comparison is the distance to its boundary: `x <= 30` is `30 - x`,
  `x >= 10` is `x - 10`, `x = c` is `-|x - c|`, and `x != c` is
  `|x - c|`;
- `!` is the opposite, `&` the minimum, `|` the maximum;
- `X` is the value at the next step, `G` the minimum over the steps to
  come, `F` the maximum, and `U` the maximum over the steps j of the
  right side at j, bounded by the left side before j.

0 is the boundary: the formula may hold or not (`holds` says which). The
robustness is useful for formulas that compare numbers; a Boolean is `inf`
or `-inf`.

```python
from chase_cps.queries import Trace
from chase_cps.robustness import robustness

trace = Trace(prefix=[{"p": 20}], loop=[{"p": 27.5}, {"p": 25}])  # 20, then 27.5, 25, ...
robustness("G (p <= 30)", trace)          # 2.5: p stays 2.5 below 30
robustness("F[0,1] (p >= 27.5)", trace)   # 0: reached, on the boundary
```

A check that fails gives the terms that its counterexample violates
(`violated` in the result), each with its robustness: a guarantee
`G (p >= 12)` violated with `-4` is missed by 4 at some step. These are the
terms broken by this counterexample; others may fail on other behaviors.

## Sampled signals: from steps to continuous time

When a step is a sample of a continuous signal, taken every `period`
seconds, and each variable changes at most its Lipschitz constant per
second, `chase_cps.sampled` gives a stricter formula to check at the
samples: if it holds there, the formula holds at every instant (Fainekos
and Pappas, TCS 2009, Corollary 44). Each comparison gets a margin, and the
intervals are adjusted by one step.

```python
from chase_cps.sampled import sampled

print(sampled("G[0,8] (x <= 11)", {"x": 1}, 0.5))     # G[0,9] (x + 0.5 < 11)
```

With a period, intervals may be written with times (`G[0s,2s] p`). The
command line checks a refinement in continuous time:

`$> chase-cps check plant.ltl --period 1 --lipschitz x=1 --refines Plant Req`

The margins are a sufficient condition: the answer is valid (it holds
between the samples too) or unknown, never invalid; the same check without
`--lipschitz` says whether it fails at the samples already. A term that
links two samples (`x' = x + u`, the model of a plant in steps) stays as it
is. The [Room thermostat demo](../demos/heater.md) uses it.
