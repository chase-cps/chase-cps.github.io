# Model checking

The [contract-based verification](../contracts/checks.md) tasks reduce to the
validity or the satisfiability of LTL formulas, which a model checker
decides:

- [nuXmv](https://nuxmv.fbk.eu): LTL over Boolean, integer, real, and word
  variables. Free for academic and non-commercial use.
- [NuSMV](https://nusmv.fbk.eu): the same without real variables, used when
  nuXmv is not installed. It is in the Docker image.

Both are installed with `chase-cps install` ([Installation](../installation.md#the-tools-that-run-the-checks)).

With `backend="auto"` (the default) CHASE takes nuXmv when it is installed,
and NuSMV otherwise; the formulas over a bounded number of steps go to z3
when it is installed ([SMT and optimization](smt.md)). A failed check comes
with a counterexample, read back from the trace of the model checker.

## Engines of nuXmv

nuXmv checks the formulas with IC3 and BDDs at the same time, and the first
verdict is taken. Both engines prove and refute, so the verdict does not
depend on which one answers; the counterexample may. One engine can be
chosen with `engine`, or in the back end, as the results name it:

- `portfolio` (the default): IC3 and BDDs at the same time.
- `ic3`: proves and refutes; good for large state spaces, words, and reals.
- `bdd`: proves and refutes; good when a counterexample needs a long loop
  (a counter that goes around).
- `bmc`: finds counterexamples up to `bmc_bound` steps, and proves
  nothing; good for short counterexamples.

```
from chase_cps import implies

r = implies("cnt = 254 & G (cnt' = cnt + 1)", "X (cnt = 0)", {"cnt": "word[8]"},
            "nuxmv/bdd")
print(r.status, r.backend)      # invalid nuxmv/bdd
```

On the command line the option is `--engine`. Formulas with `signed()` or
`unsigned()` are checked with BDDs only: in our tests, IC3 of nuXmv 2.2.0
did not give the same answers as BDDs on them.

## SMV models with their specifications

An SMV file of nuXmv or NuSMV with `LTLSPEC` or `INVARSPEC` is read as a
component: `load_smv(path)` (in `chase_cps.smvspec`) gives
`{name: (contract, model)}`: the contract,
with no assumption and a guarantee for each specification (`LTLSPEC p` is
`p`, `INVARSPEC p` is `G p`, `next(x)` is `x'`, `V` is `R`), and the model
without the specifications as its implementation. The inputs are the IVAR
variables, the outputs the VAR and FROZENVAR ones. `chase-cps view
FILE.smv --check` draws it as a component: each
specification is a term, and the one that a counterexample breaks is red.
An enumerated type (`{idle, busy}`) is read as the integers 0, 1, ... in
the order written, in the contract and in the model (the traces show the
numbers), and a `DEFINE` in a specification is replaced by its definition.
CTL (`SPEC`, `CTLSPEC`), past operators, and a `DEFINE` written with
`case ... esac` are not read. An SMV file with no specification is a model, not a
contract: it is drawn as the implementation of a contract
(`--implementation FILE.smv CONTRACT`).
