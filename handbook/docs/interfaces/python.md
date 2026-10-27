# Python package

`chase_cps` is the Python interface to CHASE: `pip install chase-cps` (see
[Installation](../getting-started/install.md)). Its modules follow the three
layers:

| Layer | Module | Names |
|---|---|---|
| <span class="tag l1">1</span> Contract algebra | `chase_cps.contract` | `Contract` and its methods: `compose`, `conjoin`, `disjoin`, `merge`, `divide`, `separate`, `imply`, `coimply`, `invert`, `assume`, `ensure`, `saturate`, `simplify` |
| <span class="tag l2">2</span> Checks on contracts | `chase_cps.checks` | `refines`, `verify`, `is_compatible`, `is_consistent`, `implements`, `accepts`, `remove_redundant` |
| <span class="tag l2">2</span> Queries on formulas | `chase_cps.logic` | `implies`, `is_satisfiable`, `unsat_core` |
| <span class="tag l3">3</span> GR(1) synthesis | `chase_cps.gr1` | `is_realizable`, `synthesize`, `unrealizable_core`, `is_well_separated`, `remove_vacuous` |

All the names are also in `chase_cps` itself, and the modules of version 0.3.0
(`chase_cps.checks`, `chase_cps.cores`) still give them. `load_spec(path)`
and `parse_spec(text)` read the contracts of a
[specification file](logics-tool.md), and `to_spec(contracts)` writes one.

## Formulas

The Python package, the command line (JSON files), and the MCP server read
formulas in the standard LTL syntax: the same operators, plus `W` (weak
until) and the aliases `[]` (`G`), `<>` (`F`), `&&`, `||`, `=>`, `<=>`,
`==`. They
have the usual precedence, from the loosest: `<->`, `->`, `|`, `&`,
`U R W`, the unary operators, the relations, `+ -`, `* /`. So `G a -> b` is
`(G a) -> b`. Names cannot be keywords of either syntax (`G`, `F`, `X`, `U`,
`R`, `W`, `P`, `NAME`, `CONTRACT`, ...). Numbers may have a fraction
(`20.5`); they are read exactly.

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
