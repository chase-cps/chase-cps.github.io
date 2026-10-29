# Back ends

The contract algebra needs no solver. The verification tasks and the
synthesis go to external tools, the back ends, which CHASE runs and whose
answers it reads back:

| Back end | For | Installed with |
|---|---|---|
| [nuXmv](https://nuxmv.fbk.eu) | verification tasks: LTL over Boolean, integer, real, and word variables | `chase-cps install nuxmv --accept-license` (academic and non-commercial use) |
| [NuSMV](https://nusmv.fbk.eu) | the same without real variables, when nuXmv is not installed | `chase-cps install nusmv`; in the Docker image |
| [slugs](https://github.com/VerifiableRobotics/slugs) | GR(1) realizability and synthesis | `chase-cps install slugs` |
| [gr1c](https://github.com/tulip-control/gr1c) | GR(1) synthesis from the domain languages | in the Docker image |
| [Yosys](https://yosyshq.net/yosys/) | reading RTL as state machines | `pip install chase-cps[rtl]` |

With `backend="auto"` (the default) CHASE takes nuXmv when it is installed,
and NuSMV otherwise.

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
