# Model checking

The [contract-based verification](../contracts/checks.md) tasks reduce to the
validity or the satisfiability of LTL formulas, which a model checker
decides:

| Model checker | For | Installed with |
|---|---|---|
| [nuXmv](https://nuxmv.fbk.eu) | LTL over Boolean, integer, real, and word variables | `chase-cps install nuxmv --accept-license` (academic and non-commercial use) |
| [NuSMV](https://nusmv.fbk.eu) | the same without real variables, when nuXmv is not installed | `chase-cps install nusmv`; in the Docker image |

With `backend="auto"` (the default) CHASE takes nuXmv when it is installed,
and NuSMV otherwise. A failed check comes with a counterexample, read back
from the trace of the model checker.

## Engines of nuXmv

nuXmv checks the formulas with IC3 and BDDs at the same time, and the first
verdict is taken. Both engines prove and refute, so the verdict does not
depend on which one answers; the counterexample may. One engine can be
chosen with `engine`, or in the back end, as the results name it:

| Engine | Proves | Finds counterexamples | Good for |
|---|---|---|---|
| `portfolio` (default) | yes | yes | IC3 and BDDs at the same time |
| `ic3` | yes | yes | large state spaces, words, reals |
| `bdd` | yes | yes | a counterexample that needs a long loop (a counter that goes around) |
| `bmc` | no | up to `bmc_bound` steps | short counterexamples |

```
from chase_cps import implies

r = implies("cnt = 254 & G (cnt' = cnt + 1)", "X (cnt = 0)", {"cnt": "word[8]"},
            "nuxmv/bdd")
print(r.status, r.backend)      # invalid nuxmv/bdd
```

On the command line the option is `--engine`. Formulas with `signed()` or
`unsigned()` are checked with BDDs only: IC3 of nuXmv 2.2.0 gives wrong
answers on them.

!!! note "Integers out of range"
    `load_spec` warns when an integer is compared with a constant outside its
    range, for instance `credits >= 90` with `credits` declared without a
    range (so 0 to 16): such a comparison has the same value at every step.

## SMV models with their specifications

An SMV file of nuXmv or NuSMV with `LTLSPEC` or `INVARSPEC` is read as a
component: `load_smv(path)` (in `chase_cps.smvspec`) gives
`{name: (contract, model)}`: the contract,
with no assumption and a guarantee for each specification (`LTLSPEC p` is
`p`, `INVARSPEC p` is `G p`, `next(x)` is `x'`, `V` is `R`), and the model
without the specifications as its implementation. The inputs are the IVAR
variables, the outputs the VAR and FROZENVAR ones. `chase-cps view
FILE.smv --check` (and VS Code) draws it as a component: each
specification is a term, and the one that a counterexample breaks is red.
CTL (`SPEC`, `CTLSPEC`), past operators, and specifications over a `DEFINE`
are not read. An SMV file with no specification is a model, not a
contract: it is drawn as the implementation of a contract
(`--implementation FILE.smv CONTRACT`).
