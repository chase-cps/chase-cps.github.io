# SMT and optimization (z3)

This page is for readers whose contracts compare numbers: budgets, sizings,
timing bounds, signals over a bounded horizon. CHASE gives such questions,
and every optimization, to the SMT solver
[z3](https://github.com/Z3Prover/z3), installed with the package:

```
$> pip install "chase-cps[z3]"
```

## Checks of formulas over a bounded number of steps

A formula with no `G`, `F`, `U`, or `R` reads a bounded number of steps:
`X`, `x'`, `past(x, n)`, and intervals such as `G[0,10] p` or `F[1,3] p`.
A contract made of such formulas is a static contract (one step) or a
contract of signal temporal logic in discrete time. Its checks are questions
of arithmetic over the values of the variables at each step, which z3
answers exactly for linear arithmetic over integers and reals, with any
Boolean structure.

With z3 installed, CHASE sends these formulas to z3 by itself, in every
check of [contract-based verification](../contracts/checks.md), and the
result names the back end `z3`. Formulas with `G`, `F`, `U`, or `R` over the
whole behavior go to the [model checker](model-checking.md), and so do
words (bit vectors).

## Optimization: the problems of a MILP

The optimization questions of CHASE are linear problems over integers,
reals, and Boolean structure, the problems that a mixed-integer linear
program (MILP) solves:

- `minimize` and `maximize`: the best value of a term where the
  constraints of a contract hold, and the values that reach it
  ([formulas over a bounded number of steps](../contracts/checks.md#formulas-over-a-bounded-number-of-steps));
- the worst case of a formula under constraints, its
  [robustness](../contracts/checks.md#robustness), as for the latency
  bounds of ContrACT in the [Drone timing](../demos/drone-timing.md) demo;
- the values of named constants at the least cost, in
  [repair](../contracts/repair.md).

z3 solves them with its optimization engine (νZ: Bjørner, Phan, and
Fleckenstein, TACAS 2015). It computes with rational numbers, so the optimum
is exact and a strict inequality is kept as it is (an optimum that is not
reached is reported as such); a disjunction or an implication is written as
it is, with no big-M constant; and the variables need no bounds. Each
optimum is checked again by the solver before it is given.

Dedicated MILP solvers (SCIP, HiGHS) are planned for problems with
thousands of variables, with z3 checking their answers.

## Running another solver

`chase-cps export FILE --to smt` writes a check as SMT-LIB 2, for z3, cvc5,
or another solver you run yourself ([command line](../interfaces/command-line.md#repairing-and-exporting)).
When the checks run with NuSMV, which has no real type, z3 also refines the
abstraction of the comparisons of reals
([real variables](../contracts/checks.md#real-variables)).

The demos [Drone climb](../demos/drone-altitude.md), [Room
thermostat](../demos/heater.md), and [Drone timing](../demos/drone-timing.md)
are checked and optimized by z3.
