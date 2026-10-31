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

The checks that take a `context` are:

- the queries `implies` and `is_satisfiable`;
- `is_compatible`, `is_consistent`, `verify`, and `refines`;
- `is_implementation` and `is_environment`;
- `remove_redundant` and `unsat_core`. The context is in every test of the
  core, and never in the core.

The [GR(1) synthesis](../tools/synthesis.md) checks do not take it.

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

The options of `Model.from_rtl`:

- `parameters`: the parameters of the top module.
- `names`: new names for the ports.
- `defines`: macros.
- `reset`: the reset holds in the first step, and the contracts are checked
  from the step after it.

The checks are those of nuXmv, for small and medium designs. The
[BufferSwap demo](../demos/buffer-swap.md) checks the RTL of two FIFOs.

## Results

| Check | Answers |
|---|---|
| `implies`, `refines`, `is_implementation`, `is_environment` | `valid`, `invalid` |
| `is_satisfiable`, `is_compatible`, `is_consistent`, `verify` | `sat`, `unsat` |
| `is_receptive` | `receptive`, `not_receptive` |
| any check | `unknown`, with a `reason` (time out, no tool installed) |

A trace is a list of states, `prefix` then `loop`, the loop repeated forever.
`to_dict()` gives the result as JSON.

## Formulas over a bounded number of steps

A formula with no `G`, `F`, `U`, `R` reads a bounded number of steps: `X`,
`x'`, and `past(x, n)` move by one step or by n, and the intervals of
steps (`G[0,10] p`, `F[1,3] p`, `p U[0,2] q`) are written with `X`. A
formula without any of them says something about one step: it is a
constraint, and a contract made of such formulas is a static contract (a
budget, a sizing, a choice of parts). When z3 is installed
(`pip install chase-cps[z3]`), the checks of such formulas go to z3
instead of nuXmv: `verify`, `refines`, `implies`, `is_satisfiable`, and the
others built on them. The result names `z3` as its back end; its trace has
the steps that the formulas read, the last one repeated. z3 is exact for
linear arithmetic over the integers and the reals, with any Boolean
structure (`a <= 1 | b <= 1` is not a polyhedron, and is checked as
written); words stay with nuXmv. `backend="nuxmv"` still sends them to
nuXmv, and `CHASE_BACKEND` too.

`minimize(objective, constraints)` and `maximize(objective, constraints)`
give the best value of a term where the constraints hold, and the values
of the variables that reach it. The constraints are a formula, a list of
formulas, or a contract (A & G):

```python
from chase_cps import Contract, maximize, minimize

gen = Contract.from_strings(name="Gen", inputs={"n": (0, 20)}, outputs={"p": "real"},
                            assumptions=["n <= 4"], guarantees=["p >= 2.5 * n", "p <= 30"])
best = maximize("n", gen)            # optimal, 4, with n = 4, p = 10
margin = minimize("p - 2.5 * n", gen)  # 0: the guarantee p >= 2.5 n is tight
print(best.status, best.value, best.to_dict().get("values"))
```

The status is `optimal`, `not_attained` (the bound of a strict inequality:
`minimize("x", "x > 1")` is 1), `unbounded`, `infeasible`, or `unknown`
with the reason.

When the objective is a formula, its robustness (see Robustness below) is
the objective. The smallest robustness of a property under the
constraints is its worst case: above 0, every behavior that the
constraints allow satisfies the property with that margin; below 0, the
trace of the result violates it. The atoms of the formula compare numbers.

```python
from chase_cps import minimize

# a heater: on (u up to 3) while T <= 70; the room loses 1 per step
heater = ["T = 60", "G[0,9] (u >= 0 & u <= 3)", "G[0,9] (T' = T + u - 1)",
          "G[0,9] (T > 70 -> u = 0)"]
worst = minimize("G[0,10] (T <= 75)", heater, {"T": "real", "u": "real"})
print(worst.status, worst.value)     # optimal 3: T reaches 72 at most
```

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

0 is the boundary: the formula may hold or not (`holds` says which). A
Boolean variable is `inf` when true and `-inf` when false. So the
robustness is useful only for formulas that compare numbers (integers,
reals, words): for a contract over Booleans it says no more than whether
the formula holds.

```python
from chase_cps import Contract
from chase_cps.queries import Trace
from chase_cps.robustness import holds, robustness, violated

trace = Trace(prefix=[{"p": 20}], loop=[{"p": 27.5}, {"p": 25}])  # 20, then 27.5, 25, ...
assert robustness("G (p <= 30)", trace) == 2.5      # p stays 2.5 below 30
assert robustness("F[0,1] (p >= 27.5)", trace) == 0  # reached, on the boundary
assert holds("F[0,1] (p >= 27.5)", trace)
c = Contract.from_strings(inputs={"n": (0, 9)}, outputs={"p": "real"},
                          guarantees=["G (p <= 26)", "G (p >= 10)"])
c.robustness(trace)                          # the assumptions, the guarantees, A -> G
assert violated(c.guarantees, trace, c.variables) == [{"term": "G (p <= 26)", "robustness": -1.5}]
```

A refinement that fails gives the terms that its counterexample violates
(`violated` in the result): the assumptions of the refined contract, or
the guarantees of the abstract one, each with its robustness when it
compares numbers (`None` otherwise). For instance a guarantee `G (p >= 12)`
violated with `-4` is missed by 4 at some step of the trace.

A trace whose loop is empty repeats its last state. `past(x, n)` is the
history variable of nuXmv in the trace (`chase_past2_x`) when it is there,
else the value n steps before; it has none in the first n steps.
`minimize` and `maximize` find the smallest and the largest robustness of
a formula over the behaviors that some constraints allow (see Formulas over
a bounded number of steps).

## Sampled signals: from steps to continuous time

The formulas count steps. When a step is a sample of a continuous signal,
taken every `period` seconds, and each variable changes at most its
Lipschitz constant per second, `chase_cps.sampled` says when a formula that
holds at the samples holds at every instant (Fainekos and Pappas, TCS
2009, Corollary 44). `sampled(formula, lipschitz, period)` gives the
stricter formula to check at the samples: under `F` and `U` each interval
is one step narrower at each end, under `G` and `R` one step wider, and each
comparison holds with the margin `(|a1| L1 + ... + |an| Ln) period`
(`x <= c` becomes `x + E < c`). If the stricter formula holds at the
samples, the formula holds in continuous time; if not, nothing is
concluded.

````
from chase_cps.queries import Trace
from chase_cps.sampled import continuous, sampled

print(sampled("G[0,8] (x <= 11)", {"x": 1}, 0.5))     # G[0,9] (x + 0.5 < 11)
t = Trace([{"x": i} for i in range(10)], [])
print(continuous("G[0,8] (x <= 11)", t, {"x": 1}, 1).holds)   # True
````

The intervals must span more than 3 steps, and the formula must not use
`X`, a primed variable, `past(x, n)`, `<->`, a Boolean variable, or a
comparison that is not linear (the error says which).

`sampled(formula, lipschitz, period, known=True)` gives the other side:
what the samples hold when the formula is known to hold in continuous
time. The intervals stay, and a comparison under `F`, or on the right of
`U`, is weaker by the margin: the instant that holds it may fall between
two samples.

With a period, the intervals may be written with times: with a period of
0.1 s, `G[0s,2s] p` is `G[0,20] p`. The command line checks a refinement
in continuous time:

`$> chase-cps check plant.ltl --period 1 --lipschitz x=1 --refines Plant Req`

For `R <= S`, CHASE checks at the samples the assumptions of `R` and the
guarantees of `S` made stricter, against the guarantees of `R` and the
assumptions of `S` made weaker. A term that speaks of the samples
themselves (`x' = x + u`, the model of a plant in steps) stays as it is.
The MCP tool `refines` takes `period` and `lipschitz` too.

`chase-cps view FILE --period SECONDS` (or `# view: --period SECONDS` in the
file) draws the steps of a counterexample as times, `t = step x SECONDS`.
