# Repair

When a check fails, `repair` finds values of named constants of the
contracts that make it pass, at the least cost, and changes nothing else.
The check and its arguments are those of the checks (`verify`, `compat`,
`consist`, `refines`, `impl`, `env`, as in `to_smv`); each parameter is a
constant with a range, `(low, high)` for a real and `(low, high, "int")` for
an integer. The cost is `minimize` or `maximize`, a term over the
parameters, and by default the change: the sum of |p - p0|.

```python
from chase_cps import Contract, repair

impl = Contract.from_strings(name="Impl", inputs={"x": (0, 9)}, outputs={"y": (0, 20)},
                             guarantees=["y = x + 5"])
spec = Contract.from_strings(name="Spec", inputs={"x": (0, 9)}, outputs={"y": (0, 20)},
                             guarantees=["y <= x + lam"], constants={"lam": 4})
r = repair("refines", impl, spec, parameters={"lam": (0, 10)})
print(r.status, r.values, r.cost, r.optimal)     # repaired {'lam': 5} 1 True
```

The result is `holds` when the check passes with the present values (a
repair is then a verification), `repaired` (the values, their cost,
`optimal` when no values of lower cost pass, and `check`, the result of
the check with the values),
`impossible` (no values in the ranges pass, with the evidence), or `unknown`
with the reason. The values of a repair are always checked by the check
itself, with its usual back end. The method is chosen by the formulas:

| Method | When | How |
|---|---|---|
| `projection` | formulas over a bounded number of steps, real parameters | the values for which the check fails are computed at once by eliminating the other variables (z3); one optimization |
| `counterexamples` | the other checks of every behavior: LTL (nuXmv), C (ESBMC), integers | optimize the cost under the conditions that the counterexamples found so far are no longer counterexamples, check, add the new counterexample, until the check passes |
| `witnesses` | checks of some behavior (`verify`, `compat`, `consist`) on bounded formulas (chosen by `auto`; not a value of `method=`) | the parameters and a behavior for each question, in one optimization |
| `enumeration` | checks of some behavior on other formulas, integer parameters | the values in the order of their cost, until one passes |

The conditions of `counterexamples` only remove values that cannot repair,
so the cost of each round is a lower bound: the values that pass are
optimal. On formulas over a bounded number of steps, a counterexample is
generalized: its integers and Booleans as they are and its reals free, it
removes every value for which some behavior of that kind still fails, not
only one value. A counterexample of a C function is not generalized (its
behaviors are those of its code). `method=` forces a method, `rounds=` (50)
limits the rounds. Repair optimizes with z3 (`pip install chase-cps[z3]`).

On the command line, with the checks of `chase-cps check` and
`--param NAME=LOW..HIGH` (`:int` for an integer):

````
$> chase-cps repair heater.ltl --refines Room+Thermostat Comfort --param theta=60..90:int
repair      repaired  (counterexamples, 4 rounds, 0.11 s)
  theta = 74
  change 2 (optimal)
````

The demos Braking, Heater, and Deadline repair a braking system (the bounds
of ContrACT, MEMOCODE 2026), a thermostat in signal temporal logic and its C
code, and a deadline in LTL.
