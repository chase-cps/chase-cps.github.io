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
```

A contract argument is `NAME`, or `NAME+NAME+...` for the composition of the
contracts. The options are grouped by layer:

| Group | Options |
|---|---|
| <span class="tag l2">2</span> checks on contracts (nuXmv) | `--verify` (the default), `--compatible`, `--consistent`, `--refines REFINED ABSTRACT` |
| <span class="tag l3">3</span> GR(1) synthesis (slugs) | `--realizable C`, `--synthesize C`, `--well-separated C` |
| all | `--core` (a minimal set of terms that explains a failure), `--json`, `--timeout`, `--backend` |

The exit status is 0 when every check passes, 1 when a check fails or does not
finish, and 2 on an error in the input.

## Installing the solvers

```
$> chase-cps install nuxmv --accept-license
$> chase-cps install slugs
$> chase-cps install nusmv          # Linux x86_64, where nuXmv cannot be used
$> chase-cps doctor                 # the CHASE library and the tools found
```
