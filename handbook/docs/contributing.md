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
   CI builds and tests CHASE on Ubuntu and macOS, with AddressSanitizer, and
   runs the demos; it must pass.

The operations follow their definitions in the literature, and the names
are the terms of contract theory.

## Repositories

CHASE is developed in the [chase-cps](https://github.com/chase-cps)
organization on GitHub. [chase](https://github.com/chase-cps/chase) is the entry
point: it collects the modules below as git submodules, builds and installs
them at once, and holds the Docker image and the Python package. Each module
is developed in its own repository, and can be built on its own.

| Repository | Content |
|---|---|
| [chase](https://github.com/chase-cps/chase) | The entry point: the modules, the build, the Docker image, the Python package `chase-cps`, the documentation |
| [core-library](https://github.com/chase-cps/core-library) | The classes that represent design problems, systems, and contracts, the contract algebra, and their Python bindings |
| [chase-backends](https://github.com/chase-cps/chase-backends) | The back ends: slugs, gr1c, the SMV language of nuXmv and NuSMV, and PySTL |
| [logics_tool](https://github.com/chase-cps/logics_tool) | The logics language of CHASE and its console |
| [DSL_tool](https://github.com/chase-cps/DSL_tool) | A domain-specific language for discrete timed problems over architectures modeled as graphs |
| [third_party](https://github.com/chase-cps/third_party) | The ANTLR4 C++ runtime |
| [demos](https://github.com/chase-cps/demos) | Demonstrations and benchmarks |
| [chase-mcp](https://github.com/chase-cps/chase-mcp) | The MCP server and the skill for AI agents |

The releases are listed in the
[changelog](https://github.com/chase-cps/chase/blob/master/CHANGELOG.md). The
Python packages are [chase-cps](https://pypi.org/project/chase-cps/) and
[chase-mcp](https://pypi.org/project/chase-mcp/) on PyPI.
