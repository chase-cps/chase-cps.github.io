# Command line

The Python package installs the `chase-cps` command.

## Checking a specification

`chase-cps check` checks the contracts of a [specification file](logics-tool.md)
in the logics language of CHASE, or of a JSON file (one contract, a list of
contracts, or `{"contracts": [...]}`, each in the format of
`Contract.from_dict`), and prints the counterexamples:

```
$> chase-cps check specs.ltl                                    # verify every contract
$> chase-cps check specs.ltl --refines Joint1+Joint2 Joints      # the composition refines Joints
$> chase-cps check specs.ltl --realizable Joint1 --json
$> chase-cps check specs.ltl --implementation joint1.smv Joint1 --receptive joint1.smv Joint1
```

A contract argument is `NAME`, or `NAME+NAME+...` for the composition of the
contracts. A model is a state machine in an SMV file, or in a JSON file (a
state machine, or a controller of slugs synthesized from the contract). The options are grouped as follows:

| Group | Options |
|---|---|
| contract-based verification (nuXmv) | `--verify` (the default: A ∧ G satisfiable), `--compatible`, `--consistent`, `--refines REFINED ABSTRACT`, `--implementation MODEL C`, `--environment MODEL C`, `--receptive MODEL C` |
| GR(1) synthesis (slugs) | `--realizable C`, `--synthesize C`, `--well-separated C`, `--vacuous C` |
| all | `--core` (a minimal set of terms that explains a failure), `--json`, `--timeout`, `--backend` |

The exit status is 0 when every check passes, 1 when a check fails or does not
finish, and 2 on an error in the input.

## Drawing a specification

`chase-cps view` writes the [diagram](diagrams.md) of a specification as a
web page, with the results of the checks it is asked for:

```
$> chase-cps view specs.ltl                                       # writes specs.html
$> chase-cps view specs.ltl --refines Joint1+Joint2+Joint3 Joints --check --realizable
$> chase-cps view specs.ltl --open Joints --serve                 # drawn again on each change
```

`--contracts C...` chooses the contracts drawn, `--refines R A` draws R inside
A, `--environment MODEL C` draws an environment, `--check` checks the
refinements and the environments, `--verify` and `--realizable` mark the
checks of each contract, `--open C...` draws contracts open, and `-o PAGE`
names the page. With `--serve` the page is served on this computer
(`--host`, `--port`) and drawn again whenever the file changes.

## Installing the solvers

```
$> chase-cps install nuxmv --accept-license
$> chase-cps install slugs
$> chase-cps install nusmv          # Linux x86_64, where nuXmv cannot be used
$> chase-cps doctor                 # the CHASE library and the tools found
```
