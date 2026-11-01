# News

<div class="news-item" markdown>
<span class="news-date">November 1, 2026</span>

## CHASE 0.6.3: repair, C programs, and continuous time

- **Repair**: when a check fails, `repair` finds the values of named
  constants that make it pass, at the least cost
  ([Repair](contracts/repair.md)); in a diagram, a click on a red tag
  offers the repairs.
- **C programs**: C functions are checked against contracts with ESBMC or
  CBMC, and the contracts can be written in the C file, in the clauses of
  ESBMC, CBMC, or ACSL ([C programs](tools/c-programs.md)).
- **SMV models with their specifications** are read as components
  (`load_smv`).
- **Continuous time**: a refinement checked on samples holds between the
  samples too, with `--period` and `--lipschitz`
  ([Sampled signals](contracts/checks.md#sampled-signals-from-steps-to-continuous-time)).
- **Formulas over a bounded number of steps** are checked by z3, with
  `minimize` and `maximize`.
- Fixed: the counterexamples of nuXmv for models with inputs, which could
  show a loop that does not break the contract.
</div>

<div class="news-item" markdown>
<span class="news-date">October 30, 2026</span>

## CHASE 0.5.0: diagrams

CHASE draws contracts, components, and systems as a web page, with the
results of the checks on the boxes ([Diagrams](interfaces/diagrams.md)),
from Python, from `chase-cps view`, or from the MCP server.
</div>

## Earlier versions

- October 28, 2026, **0.4.2**: `is_implementation` and `is_environment`
  (the new names of `implements` and `accepts`), and the Docker image.
- October 28, 2026, **0.4.1**: contracts read from SystemVerilog
  Assertions, and RTL checked against contracts
  ([Hardware](tools/systemverilog.md)).
- October 28, 2026, **0.4.0**: bit vectors (words), `past(x, n)`, and the
  choice of the engine of nuXmv.
- October 27, 2026, **0.3**: implementations and environments as state
  machines, receptiveness, vacuity in GR(1) synthesis.
- October 26, 2026, **0.2**: real variables, unsat and unrealizable cores,
  composition with discharge.
- October 25, 2026, **0.1**: the Python package on PyPI and the MCP server.

Every change of each version is in the
[changelog](https://github.com/chase-cps/chase/blob/master/CHANGELOG.md).
