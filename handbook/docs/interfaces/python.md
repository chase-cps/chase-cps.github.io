# Python package

`chase_cps` is the Python interface to CHASE: `pip install chase-cps` (see
[Installation](../getting-started.md#installation)). Its modules are grouped as
follows:

| Group | Module | Names |
|---|---|---|
| Contract algebra | `chase_cps.contract` | `Contract` and its methods: `compose`, `conjoin`, `disjoin`, `merge`, `divide`, `separate`, `imply`, `coimply`, `invert`, `assume`, `ensure`, `saturate`, `simplify` |
| Contract-based verification | `chase_cps.checks`, `chase_cps.models` | `refines`, `verify`, `is_compatible`, `is_consistent`, `is_implementation`, `is_environment`, `is_receptive`, `remove_redundant`; `Model` (state machines) |
| Queries on formulas | `chase_cps.logic` | `implies`, `is_satisfiable`, `unsat_core` |
| GR(1) synthesis | `chase_cps.gr1` | `is_realizable`, `synthesize`, `unrealizable_core`, `is_well_separated`, `is_vacuous`; `remove_redundant(c, synth=True)` |

All the names are also in `chase_cps` itself, and the modules of version 0.3.0
(`chase_cps.checks`, `chase_cps.cores`) still give them. `load_spec(path)`
and `parse_spec(text)` read the contracts of a
[specification file](logics-tool.md), and `to_spec(contracts)` writes one.
`parse_sva(text)` reads the assertions of SystemVerilog as a contract, and
`to_sva(contract)` writes a contract as a checker module (see
[SystemVerilog Assertions](systemverilog.md)).

## Formulas

The Python package, the command line (JSON files), and the MCP server read
formulas in the standard LTL syntax, over Boolean, integer, real, and word
variables. The operators, the types, and the precedence are in
[Formulas](../contracts/formulas.md).

A contract is built from strings or from a dictionary (the JSON format of
the command line and of the MCP server):

```
from chase_cps import Contract

c = Contract.from_strings(inputs=["req"], outputs=["grant"],
                          assumptions=["G F !req"],
                          guarantees=["G (req -> F grant)"], name="Spec")
d = Contract.from_dict({"name": "Spec", "inputs": {"req": "bool", "n": [0, 3], "v": "real"},
                        "outputs": {"grant": "bool"},
                        "assumptions": ["G F !req"],
                        "guarantees": ["G (req -> F grant)"]})
```


## Results

Every check returns a result with a `status` (`valid`, `invalid`, `sat`,
`unsat`, `realizable`, `unrealizable`, or `unknown` with a `reason`), the
`trace` of a failed check, and `to_dict()` for JSON. The details are in
[Checks](../contracts/checks.md#results).

The full API, generated from the docstrings, is in the
[API reference](https://chase-cps.github.io/api/).
