# <span class="tag l2">2</span> Checks

The checks on contracts reduce to queries on formulas of a theory: validity
and satisfiability, which the back ends decide. The theory is LTL over
Boolean, bounded integer, and real variables; the back end is nuXmv, or
NuSMV. In Python the checks on contracts are in `chase_cps.checks`, the
queries on formulas in `chase_cps.logic`; all the names are also in
`chase_cps`.

## Checks on contracts

| Check | logics_tool | Python | chase-cps check | MCP tool |
|---|---|---|---|---|
| refinement ⪯ | `refines C1 C2 file` | `refines(c1, c2)` | `--refines C1 C2` | `refines` |
| compatibility and consistency | `verify C file` | `verify(c)` | `--verify` (default) | `verify` |
| compatibility | | `is_compatible(c)` | | `is_compatible` |
| consistency | | `is_consistent(c)` | | `is_consistent` |
| implementation M ⊨ C | | `implements(m, c)` | | `implements` |
| acceptance of an environment E | | `accepts(c, e)` | | `accepts` |
| redundant terms | | `remove_redundant(c)` | | `remove_redundant` |

A contract (A, G) is read saturated, as A -> G. `refines(c1, c2)` checks
that A2 -> A1 and (A1 -> G1) -> (A2 -> G2) are valid. A contract is
compatible when some environment satisfies A, and consistent when some
behavior satisfies A -> G; `verify` checks both. A component M satisfies
the contract (`implements(m, c)`) when M & A -> G is valid, and the contract
accepts an environment E (`accepts(c, e)`) when E -> A is valid; M and E are
LTL formulas over the variables of the contract. `remove_redundant(c)` drops
the assumptions implied by the other assumptions, and the guarantees implied
by the assumptions and the other guarantees.

The console writes the input file of nuXmv for `verify` and `refines`, to
be run by hand; the Python package, the command line, and the MCP server run
nuXmv and return the result.

## Queries on formulas

| Query | logics_tool | Python | chase-cps check | MCP tool |
|---|---|---|---|---|
| validity of phi -> psi | | `implies(phi, psi, variables)` | | `implies` |
| satisfiability of phi | | `is_satisfiable(phi, variables)` | | `is_satisfiable` |
| unsat core | | `unsat_core(c)` | `--core` | `unsat_core` |

The checks on contracts reduce to these queries, in `chase_cps.logic`.
`implies` checks validity: phi -> psi holds for every behavior; the answer
is `valid`, or `invalid` with a counterexample (a behavior that satisfies
phi and violates psi). `is_satisfiable` checks that some behavior (a value
of each variable at each step) satisfies the formula; the answer is `sat`
with such a behavior, or `unsat`. This satisfiability of a formula is not
the satisfaction of a contract by a component, which is `implements`.

When a check fails, a core is a minimal set of terms that explains it:
removing any term of the core makes the check pass. `unsat_core(c)` gives
the terms of A & G that cannot hold together. If they are all assumptions,
the contract is incompatible; all guarantees, the guarantees contradict
each other; both, the guarantees cannot hold when the assumptions do. This
is the consistency check of OCRA (`ocra_check_consistency -j`). The search
is delta debugging (Zeller and Hildebrandt, TSE 2002), one call to nuXmv per
test. `unsat_core(formulas, variables)` takes formulas and returns formulas.
The checks give the core of their failure with `core=True`:
`is_compatible(c, core=True)` (the assumptions), `is_consistent(c,
core=True)` (the guarantees), and `is_satisfiable(phi, variables,
core=True)`. The result is a `Core` with a `status`: `found` with the
`core`, `none` when the check does not fail, or `unknown` with a `reason`
when a test does not finish.

## Context

Some formulas are not an assumption of a component nor a guarantee: they
hold for every behavior that can happen at all. Examples are the axiom of
an encoding of finite traces (`alive & (alive U G !alive)`, where `alive`
is true for the length of the trace), a physical law, or "one tool call at
each step". The checks built on implication and satisfiability take them
as `context`, a formula or a list of formulas, and leave out the behaviors
that violate them:

```python
from chase_cps import Contract, verify

FINITE = "alive & (alive U G !alive)"
c = Contract.from_strings(inputs=["alive"], outputs=["a"], name="C",
                          guarantees=["G (alive -> a)", "G (alive -> !a)"])
assert verify(c).status == "sat"     # alive false from the start
assert verify(c, context=FINITE).status == "unsat"
```

A context is not an assumption. A behavior that violates an assumption
satisfies the contract (A -> G); one that violates the context does not
count. So `verify(c.assume(FINITE))` is still sat. The checks are:

- `implies(phi, psi, variables, context=k)`: k & phi -> psi;
- `is_satisfiable(phi, variables, context=k)`: k & phi;
- `is_compatible`, `is_consistent`, `verify`, `refines`, `remove_redundant`,
  `accepts`, `implements`, and `unsat_core` (the context is in every test of
  the search and never in the core).

The variables of the context must be variables of the check. The
realizability checks (`is_realizable`, `synthesize`, `is_well_separated`,
`remove_vacuous`, `unrealizable_core`) do not take a context: whether a
formula constrains the environment or the component is a question of
roles, which a context does not say.

## Real variables

A variable of type `"real"` (`real variable x;`) takes any real value. The
checks handle real variables in this order, and the result says in `reals`
which way answered:

1. `regions`: when a real variable is only compared with constants
   (`kias > 40`, `kias' <= 30.5`) or with other real variables of the same
   step (`kias = kgs`), without arithmetic, only the interval between the
   constants matters. With the constants c1 < ... < ck the variable is
   replaced by the index of its region among (-inf, c1), c1, (c1, c2), ...,
   ck, (ck, inf); variables compared with each other share their constants,
   and each interval has one place per variable, so that their order is
   kept. The answer is exact, traces have real values (one in each
   region), and realizability and synthesis work: the controller of
   `synthesize` gives for each node the values of the variables, the real
   ones as conditions (`30.5 < kias < 40`), and the list of the regions.
2. `smt`: otherwise the SMT engine of nuXmv checks the formulas with the
   real variables. It is exact for linear arithmetic; with nonlinear
   arithmetic (`x * y`) it often does not finish, so it gets at most 30
   seconds. NuSMV has no real type. Realizability and synthesis are
   unknown in this case.
3. `predicates`: when nuXmv gives no answer, each comparison becomes a
   Boolean variable (`x <= 10` and `x > 10` are the same one, negated). The
   abstraction allows values that are impossible (`x > 10` and `x < 5` at
   once), so only a valid implication or an unsatisfiable formula is
   returned as such. With z3 (`pip install chase-cps[reals]`), the
   combinations of one or two comparisons that no values satisfy are
   excluded first, and an invalid or sat answer is checked: z3 looks for
   real values for every state of the trace. If it finds them, the answer
   and the trace are those of the real variables (an irrational value, such
   as a square root, is given as a close fraction); if not, the comparisons
   of a core are excluded and the check is repeated. The other answers are
   unknown, with the trace of the abstraction.

Numbers with a fraction compared with integers (`n <= 20.5`) also need the
SMT engine of nuXmv. Without real variables none of this is used.

The console of logics_tool writes the file of `verify` and `refinement`
and does not run the model checker. When the file has real variables or
real numbers, the console says so, and the file starts with a comment:
NuSMV cannot read it, and nuXmv checks it with its SMT engine:

```
$> nuXmv -int refinement.smv
nuXmv > go_msat
nuXmv > check_ltlspec_ic3
```

`go`, followed by `check_ltlspec`, stops with an error on such a file.


## Results

The checks return a result with a `status`: `valid` or `invalid` for
implications and refinement, `sat` or `unsat` for satisfiability,
compatibility, consistency, and verify, `realizable` or `unrealizable` for
realizability and synthesis, and `unknown` with a `reason` when the check
does not finish or no tool is installed. A failed check comes with a
`trace`: the states of `prefix`, then the states of `loop` repeated forever.
`synthesize` returns the `controller`, and both `is_realizable` and
`synthesize` return the `counter_strategy` of the environment when the
contract is unrealizable.

`refines` checks the assumptions and the guarantees separately; `failed`
says which part fails, and its result has the counterexample.
