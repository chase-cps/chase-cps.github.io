# Contributing

CHASE is open source, under the BSD 3-Clause License, and contributions are
welcome: reports of bugs, questions, demos, documentation, and code. The
full guide is
[CONTRIBUTING.md](https://github.com/chase-cps/chase/blob/master/CONTRIBUTING.md)
in the repository of CHASE.

## Reporting a bug or asking a question

Open an issue on [chase-cps/chase](https://github.com/chase-cps/chase/issues),
with the version (`chase-cps --version`), the back ends found
(`chase-cps doctor`), the smallest specification or script that shows the
problem, what CHASE answered, and what you expected. A wrong verdict is the
most serious kind of bug: please report it even if you are not sure.

## Proposing a change

1. For anything larger than a fix, open an issue first, so that we can agree
   on the design and the names.
2. Make the change on a branch, with tests: for a change to the contract
   algebra or to a check, a property test that compares it with its
   definition.
3. Update the documentation and the changelog, and open a pull request. The
   CI builds and tests CHASE on Ubuntu and macOS, and runs the demos; it
   must pass.

The operations follow their definitions in the literature, and the names
are the terms of contract theory.

## Sending a pull request

Pull requests are sent on GitHub, to the repository of the part that
changes, against its default branch:

| What changes | Repository | Branch |
|---|---|---|
| the Python package, the command line, the build<!-- DOCKER (restore when the image is public): "the command line, the Docker image, the build" --> | [chase](https://github.com/chase-cps/chase/pulls) | `master` |
| the C++ representation and the contract algebra | [core-library](https://github.com/chase-cps/core-library/pulls) | `main` |
| the printers for the back ends | [chase-backends](https://github.com/chase-cps/chase-backends/pulls) | `main` |
| the specification language and its console | [logics_tool](https://github.com/chase-cps/logics_tool/pulls) | `main` |
| the domain languages | [DSL_tool](https://github.com/chase-cps/DSL_tool/pulls) | `main` |
| the MCP server and its skill | [chase-mcp](https://github.com/chase-cps/chase-mcp/pulls) | `main` |
| the demos | [demos](https://github.com/chase-cps/demos/pulls) | `main` |
| the website | [chase-cps.github.io](https://github.com/chase-cps/chase-cps.github.io/pulls) | `master` |

1. Fork the repository on GitHub, and clone your fork (for `chase`, with
   `--recursive`).
2. Make the change on a new branch, commit it, and push the branch to your
   fork.
3. Open the pull request from that branch ("Compare & pull request" on
   GitHub), and give the number of the issue it answers.

A change to a C++ module goes to the repository of the module; once it is
merged, the submodule is moved in `chase` (the maintainers do it, or a second
pull request to `chase` does).

## Repositories

The repositories are those of the table above, in the
[chase-cps](https://github.com/chase-cps) organization on GitHub; `chase`
collects the others as git submodules, with the scripts to build them.
The releases are listed in the
[changelog](https://github.com/chase-cps/chase/blob/master/CHANGELOG.md). The
Python packages are [chase-cps](https://pypi.org/project/chase-cps/) and
[chase-mcp](https://pypi.org/project/chase-mcp/) on PyPI.
