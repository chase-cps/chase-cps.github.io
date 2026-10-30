# Command line

The Python package installs the `chase-cps` command, with four commands:
`check`, `view`, `install`, and `doctor`.

In the options, a contract is `NAME`, or `NAME+NAME+...` for the
composition of the contracts. A model is a state machine in an SMV file, or
in a JSON file (a state machine, or a controller of slugs synthesized from
the contract).

## Checking a specification

`chase-cps check` checks the contracts of a [specification file](logics-tool.md)
in the logics language of CHASE, or of a JSON file (one contract, a list of
contracts, or `{"contracts": [...]}`, each in the format of
`Contract.from_dict`), and prints the counterexamples.

>**Usage**
>
> `chase-cps check FILE [options]`

> **Parameters:**
>
> Contract-based verification (nuXmv):
>
> - `--verify` _The assumptions and the guarantees can hold together (A ∧ G
>   satisfiable). It is the default when no check is given._
> - `--compatible` _Some environment satisfies the assumptions._
> - `--consistent` _Some behavior satisfies A → G._
> - `--contracts C...` _The contracts checked by the three options above
>   (default: all)._
> - `--refines R A` _R refines A. It may be repeated._
> - `--implementation MODEL C` _The model is an implementation of C._
> - `--environment MODEL C` _The behaviors of the model satisfy the
>   assumptions of C._
> - `--receptive MODEL C` _The model accepts every input that the
>   assumptions of C allow._
>
> GR(1) synthesis (slugs):
>
> - `--realizable C` _C is realizable. It may be repeated._
> - `--synthesize C` _Synthesizes a controller for C. It may be repeated._
> - `--well-separated C` _The component cannot win by forcing the
>   environment to violate its assumptions._
> - `--vacuous C` _The component can win without an output that a liveness
>   guarantee asks for._
>
> For every check:
>
> - `--core` _When a check fails, gives a minimal set of terms that explains
>   it._
> - `--json` _Prints the results as JSON._
> - `--timeout S` _Seconds for each check._
> - `--backend auto|nuxmv|nusmv` _The model checker._
> - `--engine auto|ic3|bdd|bmc|portfolio` _The engine of the model checker._

For instance:

```
$> chase-cps check specs.ltl                                    # verify every contract
$> chase-cps check specs.ltl --refines Joint1+Joint2 Joints      # the composition refines Joints
$> chase-cps check specs.ltl --realizable Joint1 --json
$> chase-cps check specs.ltl --implementation joint1.smv Joint1 --receptive joint1.smv Joint1
```

The exit status is 0 when every check passes, 1 when a check fails or does
not finish, and 2 on an error in the input.

## Drawing a specification

`chase-cps view` writes the [diagram](diagrams.md) of a file as a web page.
The file is a specification in the logics language, in JSON, or in
SystemVerilog Assertions (`.sv`), or a Verilog module (`.v`, or `.sv`
without assertions), drawn with its state machine.

>**Usage**
>
> `chase-cps view FILE [options]`

> **Parameters:**
>
> What is drawn:
>
> - `--contracts C...` _The contracts drawn. By default, all the contracts of
>   the file, but those drawn inside another box._
> - `--refines R A` _Draws R inside A. It may be repeated._
> - `--implementation MODEL C` _Draws C as a component with its model: SMV,
>   JSON, or RTL read with Yosys (`FILE:MODULE` for a file with several
>   modules). It may be repeated._
> - `--environment MODEL C` _Draws the model as an environment of C, on its
>   left. It may be repeated._
> - `--open C...` _Draws these contracts open: their terms, and the core of
>   a check that fails._
>
> The checks:
>
> - `--check` _Checks that the assumptions and the guarantees of each
>   contract can hold together (A∧G, with the core when they cannot), and
>   the refinements, the implementations, and the environments drawn (nuXmv
>   or NuSMV)._
> - `--verify` _Checks that each contract drawn is compatible and
>   consistent._
> - `--realizable` _Checks that each contract drawn is realizable (slugs);
>   when it is not, marks the guarantees of the core._
> - `--timeout S` _Seconds for each check._
> - `--budget S` _No check starts after S seconds; the checks left are not
>   marked._
> - `--results FILE` _Where the results of `--check` are kept (default: next
>   to the file, `charger.ltl` → `charger.results.json`). A check of
>   contracts that have not changed is read from it, not run again._
> - `--no-results` _Keeps no results._
> - `--progress` _Writes each result on the standard error as soon as it is
>   known, for an editor that shows them one by one._
> - `--no-checks` _Leaves the three checks above out._
>
> The page:
>
> - `-o PAGE` _The page written (default: FILE with `.html`)._
> - `--format html|json` _The page, or the data of the diagram._
> - `--elk PATH` _Puts a local `elk.bundled.js` in the page, which then
>   works offline (default: ELK from a CDN)._
> - `--serve` _Serves the page on this computer, and draws it again whenever
>   the file changes. When the file cannot be drawn, the page keeps the last
>   diagram and says why._
> - `--host HOST`, `--port PORT` _Where the page is served._

For instance:

```
$> chase-cps view specs.ltl                                       # writes specs.html
$> chase-cps view specs.ltl --refines Joint1+Joint2+Joint3 Joints --check --realizable
$> chase-cps view specs.ltl --open Joints --serve                 # drawn again on each change
$> chase-cps view arbiter.v                                       # the module and its states
```

Without `--refines` and `--contracts`, the contracts are put together by
their ports:

- an output and an input with the same name are wired;
- contracts with the same inputs and outputs are versions of one part
  (fixes, or candidates): the first one in the file is wired, the others
  are drawn apart;
- a contract whose outputs are driven by several parts, which read from
  outside only its inputs, is the contract of their composition: the parts
  are drawn inside it, and `--check` checks the refinement;
- when two parts or more are written but some outputs of the contract are
  driven by none, the part not written yet is drawn as a hole: the
  quotient of the contract by the parts.

The options can also be written at the top of the file, in comments
(`// view:` in Verilog). The files named there are taken from the folder of
the file:

```
# view: --implementation models/arb.json Arb --check --open Arb
CONTRACT Arb ...
```

## Installing the solvers

```
$> chase-cps install nuxmv --accept-license
$> chase-cps install slugs
$> chase-cps install nusmv          # Linux x86_64, where nuXmv cannot be used
$> chase-cps doctor                 # the CHASE library and the tools found
```
