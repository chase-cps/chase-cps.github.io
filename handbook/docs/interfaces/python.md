# Python package

`chase_cps` is the Python interface to CHASE. It is installed with
`pip install chase-cps` (see [Installation](../installation.md)).
Its modules are grouped as follows:

- **Contract algebra** (`chase_cps.contract`): the class `Contract`, with the
  methods `compose`, `conjoin`, `disjoin`, `merge`, `divide`, `separate`,
  `imply`, `coimply`, `invert`, `assume`, `ensure`, `saturate`, and
  `simplify`.
- **Contract-based verification** (`chase_cps.checks`, `chase_cps.models`):
  `refines`, `verify`, `is_compatible`, `is_consistent`,
  `is_implementation`, `is_environment`, `is_receptive`, and
  `remove_redundant`; the class `Model`, for state machines.
- **Queries on formulas** (`chase_cps.logic`): `implies`, `is_satisfiable`,
  and `unsat_core`.
- **GR(1) synthesis** (`chase_cps.gr1`): `is_realizable`, `synthesize`,
  `unrealizable_core`, `is_well_separated`, `is_vacuous`, and
  `remove_redundant(c, synth=True)`.
- **Repair and optimization** (`chase_cps.repair`, `chase_cps.optimize`):
  `repair`, `minimize`, `maximize` ([Repair](../contracts/repair.md),
  [SMT and optimization](../tools/smt.md)).
- **Continuous time** (`chase_cps.sampled`): `sampled`, the stricter
  formula to check at the samples
  ([sampled signals](../contracts/checks.md#sampled-signals-from-steps-to-continuous-time)).

All the names are also in `chase_cps` itself.

The contracts are read and written in other formats with:

- `load_spec(path)`, `parse_spec(text)`: read the contracts of a
  [specification file](logics-tool.md); `to_spec(contracts)` writes one.
- `parse_sva(text)`: reads SystemVerilog Assertions as a contract;
  `to_sva(contract)` writes a contract as a checker module (see
  [SystemVerilog Assertions](../tools/systemverilog.md)).
- `to_gr1(contract, format=...)`: writes a GR(1) contract for slugs or gr1c
  (see [GR(1) synthesis](../tools/synthesis.md)).
- `load_dsl(path)`: reads a problem written in the domain-specific language
  of CHASE.
- `load_smv(path)` and `load_c(path)`: read an SMV model with its
  specifications, and the functions of a C file with their clauses, as
  contracts with their implementations ([Model
  checking](../tools/model-checking.md), [C programs](../tools/c-programs.md)).

`chase_cps.viz` draws contracts, components, and systems (see
[Diagrams](diagrams.md)).

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

The full API is in the docstrings: `help(chase_cps.refines)`,
`help(chase_cps.repair)`, and so on, and in the
[API reference](https://chase-cps.github.io/api/chase_cps.html) made from them.
