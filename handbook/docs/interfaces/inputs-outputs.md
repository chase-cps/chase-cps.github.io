---
wide: true
---

# Inputs and outputs

What CHASE reads, what it does with each, and what it gives back. The
[Diagrams](diagrams.md) page says what the boxes and tags mean; the
[demos](../demos/index.md) use each input. Every
input becomes the same `Contract` (and, for a design, a `Model` or a C
function as its implementation), so every check works on all of them.

| Input | What it says | Read by | Drawn by `chase-cps view` | Checked with |
|---|---|---|---|---|
| `.ltl` (the specification language) | contracts: variables, assumptions, guarantees, named constants | the parser of CHASE (C++) | the contracts, composed by their ports, refinements, quotients; box and line of the file both ways | nuXmv or NuSMV (LTL), z3 (bounded formulas, reals), slugs (GR(1)) |
| `.json` | contracts (`Contract.to_dict`) | `Contract.from_dict` | the same, without lines | the same |
| `.sv`, `.sva` with `assume` / `assert property` | contracts in SystemVerilog Assertions | `parse_sva` | the contract of each module | the same |
| `.v`, `.sv` with no assertion | an RTL module (a model) | Yosys (YoWASP) | the module: ports and register state machine | nuXmv (M ⊨ C) |
| `.c` with clauses (ESBMC, CBMC, ACSL) | a contract and an implementation for each function | `load_c` | each function as a component, with its code; a function with no clause is checked as code alone (`safe`) | ESBMC or CBMC |
| `FILE.c:FUNCTION` | a C function (a model): one call, or one call per step | `CFunction` | inside the box of its contract, with its code | ESBMC or CBMC |
| `.smv` with `LTLSPEC`, `INVARSPEC` | a model and its specifications | `load_smv` | the module as a component, each specification a term | nuXmv or NuSMV |
| `.smv`, JSON state machine, slugs controller | a model | `Model.from_smv`, `Model.from_dict`, `Model.from_controller` | inside its contract (`--implementation`) or beside it (`--environment`): the state machine | nuXmv or NuSMV (M ⊨ C, E ⊨ A) |
| domain-specific language (`dsl_tool`) | requirements from patterns | `load_dsl` | from Python (`viz.show`) | slugs |
| Python | any of the above | `chase_cps` | `viz.show` | all |

| Output | Given by | Where |
|---|---|---|
| verdict (`valid`, `invalid`, `sat`, `unsat`, `realizable`, ..., `unknown` with a reason) | every check | `Result.status`; a line of `chase-cps check`; the tag of a box (green, red) |
| counterexample (the states of a prefix, then of a loop repeated forever) | a check that fails | `Result.trace`; the table of the panel and the values on the wires of the diagram |
| core (the terms in conflict) | `unsat_core`, `unrealizable_core`, `verify(core=True)` | `Core.core`; the terms in red in the box |
| controller (a state machine) | `synthesize` | a `Model`; JSON; drawn as a state machine |
| counter-strategy of the environment | `is_realizable`, `synthesize` on an unrealizable contract | `Result.counter_strategy` |
| values of named constants | `repair` | `Repair.values`; the panel (Apply writes them into the file) |
| robustness (how much a trace satisfies a formula) | `robustness` | a number |
| results kept | `chase-cps view --check` | `FILE.results.json`, next to the file |
| diagram | `chase-cps view`, `viz.show` | an HTML page, its JSON (`--format json`), SVG and PNG from the page |
| files for other tools | `to_smv`, `to_smt`, `to_gr1`, `to_sva`, `to_c` | SMV (nuXmv, NuSMV), SMT-LIB, slugs and gr1c, SVA checkers (Jasper), C programs (ESBMC, CBMC) |
