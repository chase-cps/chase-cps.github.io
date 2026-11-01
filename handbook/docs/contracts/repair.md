# Repair

When a check fails, `repair` finds the values of named constants (a
deadline, a threshold, a bound) that make it pass, at the least cost, and
changes nothing else. Each constant is given a range; the cost is by
default the change, the sum of |p - p0|, or any term with `minimize` or
`maximize`.

```python
from chase_cps import Contract, repair

impl = Contract.from_strings(name="Impl", inputs={"x": (0, 9)}, outputs={"y": (0, 20)},
                             guarantees=["y = x + 5"])
spec = Contract.from_strings(name="Spec", inputs={"x": (0, 9)}, outputs={"y": (0, 20)},
                             guarantees=["y <= x + lam"], constants={"lam": 4})
r = repair("refines", impl, spec, parameters={"lam": (0, 10)})
print(r.status, r.values, r.optimal)     # repaired {'lam': 5} True
```

```mermaid
flowchart TD
  A["A check fails: refines, impl, env, verify, ..."] --> B["The constants that may change,<br/>their ranges, and a cost"]
  B --> C{"Which formulas?"}
  C -->|"G and F of one step"| D["copies: the state written n+1 times,<br/>no temporal operator"]
  C -->|"a bounded number of steps"| E["projection: the values that fail,<br/>at once (z3)"]
  C -->|"some behavior:<br/>verify, compat, consist"| W["witnesses or enumeration"]
  C -->|"LTL, C code, the rest"| F["the least cost that avoids<br/>the counterexamples found so far (z3)"]
  D --> O["the least cost (z3)"]
  E --> O
  W --> O
  O --> K["the check itself, with the values"]
  F --> G{"the check with these values<br/>(nuXmv, ESBMC)"}
  G -->|"a new counterexample"| F
  K --> R(["repaired: the values, their cost, optimal"])
  G -->|"passes"| R
  O -->|"no values"| I(["impossible"])
  F -->|"no values"| I
  G -->|"time limit"| U(["unknown"])
```
*How a repair goes. The method is chosen by the formulas, and the values
found always pass the check itself.*

The answer is `repaired` (the values, their cost, and whether it is the
least), `holds` (the present values already pass), `impossible` (no values
in the ranges pass), or `unknown` with the reason. The methods:

- `copies` (from 0.6.4): terms that are `G` or `F` of one step. A
  counterexample needs only one state per term, so the question is written
  on that many copies of the state, with no temporal operator, and solved
  exactly (Demri and Schnoebelen, Information and Computation 2002,
  Proposition 7.2).
- `projection`: formulas over a bounded number of steps; the values that
  fail are computed at once.
- `counterexamples`: the rest (LTL, C code). Each counterexample rules out
  the values it breaks; the cost of each round is a lower bound, so the
  first values that pass are the least. With several real constants it may
  not end: give `time_limit`.
- `witnesses` and `enumeration`: checks that some behavior exists
  (`verify`, `compat`, `consist`).

On the command line, `--param NAME=LOW..HIGH` (`:int` for an integer):

````
$> chase-cps repair heater.ltl --refines Room+Thermostat Comfort --param theta=60..90:int
repair      repaired  (counterexamples, 5 rounds, 0.13 s)
  theta = 74
  change 2 (optimal)
````

In a [diagram](../interfaces/diagrams.md), a click on a red tag opens the
same repair, and Apply writes the values into the file. The demos [Drone
timing](../demos/drone-timing.md), [Room thermostat](../demos/heater.md),
[Resource arbiter](../demos/deadline.md), and [Drone
climb](../demos/drone-altitude.md) repair a timing bound, a thermostat and
its C code, a deadline in LTL, and two constants at once.
