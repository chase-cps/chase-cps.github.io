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

## Sending a pull request

Pull requests are sent on GitHub, to the repository of the part that
changes, against its default branch:

| What changes | Repository | Branch |
|---|---|---|
| the Python package, the command line, the Docker image, the build | [chase](https://github.com/chase-cps/chase/pulls) | `master` |
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

CHASE is developed in the [chase-cps](https://github.com/chase-cps)
organization on GitHub. CHASE is organized in the following components,
available at the corresponding repositories. Each module is developed in its
own repository, and can be built on its own.

- **chase**: the entry point. It collects all the components as git
  submodules, with the scripts to build and install them, the Docker image,
  the Python package `chase-cps`, and the documentation.
  [Link to the repository](https://github.com/chase-cps/chase)
- **core-library**: the library providing the classes and structures
  required to represent design problems, systems, and contracts using
  CHASE, the contract algebra, and their Python bindings. It is the main
  component of the CHASE framework.
  [Link to the repository](https://github.com/chase-cps/core-library)
- **chase-backends**: collection of backends encoding CHASE problems into
  different external tools, *i.e.*, slugs, gr1c, and the SMV language of
  nuXmv and NuSMV. A printer for PySTL, written for an early version of
  PyCASSE, is kept but does not run with the current one.
  [Link to the repository](https://github.com/chase-cps/chase-backends)
- **logics_tool**: tool providing a console to manipulate assume-guarantee
  contracts expressed using a logics-based language.
  [Link to the repository](https://github.com/chase-cps/logics_tool)
- **DSL_tool**: tool using a Domain Specific Language to specify discrete
  timed problems defined over architectures modeled using graphs.
  [Link to the repository](https://github.com/chase-cps/DSL_tool)
- **third_party**: third-party libraries required to build CHASE (ANTLR4 C++
  runtime).
  [Link to the repository](https://github.com/chase-cps/third_party)
- **demos**: demonstrations and benchmarks of CHASE.
  [Link to the repository](https://github.com/chase-cps/demos)
- **chase-mcp**: the MCP server and the skill for AI agents.
  [Link to the repository](https://github.com/chase-cps/chase-mcp)

The releases are listed in the
[changelog](https://github.com/chase-cps/chase/blob/master/CHANGELOG.md). The
Python packages are [chase-cps](https://pypi.org/project/chase-cps/) and
[chase-mcp](https://pypi.org/project/chase-mcp/) on PyPI.
