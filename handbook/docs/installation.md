# Installation

The [Getting started](getting-started.md) page installs CHASE in two
commands. This page has the rest, by what you want to do:

- [the Python package](#the-python-package), with its optional parts;
- [the tools that run the checks](#the-tools-that-run-the-checks);
- [the Docker image](#the-docker-image), with everything;
- [the sources](#from-the-sources): all the modules at once, or one by one;
- [AI agents](#ai-agents), through the MCP server.

## The Python package

```
$> pip install chase-cps
```

The package has the CHASE library (the C++ core library and its Python
interface), the parsers of the [specification files](interfaces/logics-tool.md)
and of the DSL, the `chase-cps` [command](interfaces/command-line.md), and the
[diagrams](interfaces/diagrams.md). Wheels are available for Python 3.10 to
3.15 on Linux (x86_64 and aarch64, glibc 2.28 or later) and macOS 11 or later
(arm64 and x86_64). Windows is not supported: use WSL or the Docker image.

Two parts are optional, installed with the package:

```
$> pip install "chase-cps[z3,rtl]"
```

- `z3` (the solver z3) checks the formulas over a bounded number of steps
  (static contracts, signal temporal logic) and the real variables, and is
  needed for [repair](contracts/repair.md) and optimization.
- `rtl` (Yosys, compiled to WebAssembly) reads Verilog and SystemVerilog, for
  the [hardware](tools/systemverilog.md) checks.

## The tools that run the checks

The checks call external tools, installed apart from the package:

- nuXmv for the checks of contracts and LTL (refinement, consistency,
  compatibility, implementation, cores). NuSMV can replace it.
- slugs for GR(1) realizability and synthesis.
- ESBMC or CBMC for the [C programs](tools/c-programs.md).

`chase-cps install` installs them into `~/.chase`, and `chase-cps doctor`
lists the tools found, what each is needed for, and how to install the
others:

```
$> chase-cps install nuxmv --accept-license    # Linux x86_64, macOS arm64
$> chase-cps install nusmv                     # Linux x86_64
$> chase-cps install slugs                     # needs a C++ compiler, make, and Boost
$> chase-cps install esbmc                     # Linux; on macOS: brew install esbmc
$> chase-cps doctor
```

CBMC comes from its packages (`brew install cbmc`, `apt install cbmc`).
gr1c is needed only for the specifications that CHASE writes for it, and is
installed from [its sources](https://github.com/tulip-control/gr1c).

The tools are looked up in the `PATH` and in `~/.chase/bin`, or given with
the environment variables `CHASE_NUXMV`, `CHASE_NUSMV`, `CHASE_SLUGS`,
`CHASE_ESBMC`, and `CHASE_CBMC`.

On macOS, nuXmv needs the libraries of Homebrew (`brew install libxml2 gmp
libedit`). On Linux it needs `libxml2` and `libedit2`, and the C++ library of
GCC 13 or later (Ubuntu 24.04, Debian 13, Fedora 39, or newer).

!!! note "Without nuXmv"
    nuXmv is free for academic and non-commercial use only. Otherwise the
    checks run with [NuSMV](https://nusmv.fbk.eu/) (LGPL) instead. NuSMV has
    no real type: the real variables are then checked with exact regions when
    they are only compared with constants, and with predicate abstraction
    otherwise.

## The Docker image

The image has the whole toolchain: the CHASE console tools, the Python
package with z3 and Yosys, the demos, gr1c, slugs, NuSMV, and ESBMC. It has
no nuXmv, whose license does not allow redistribution; in a container,
`chase-cps install nuxmv --accept-license` installs it.

```
$> docker pull ghcr.io/chase-cps/chase
$> docker run --rm -it ghcr.io/chase-cps/chase
```

The container starts in the directory of the demos. All the demos are run
and checked with:

```
$> docker run --rm ghcr.io/chase-cps/chase /opt/chase/tests/demo-suite.sh
```

The image is built for x86_64; on ARM machines (e.g. Apple Silicon), add
`--platform linux/amd64` to `docker run`. It can also be built from the
sources, with nuXmv when its license is accepted:

```
$> git clone --recursive https://github.com/chase-cps/chase
$> cd chase
$> docker build --build-arg ACCEPT_NUXMV_LICENSE=yes -t chase .
```

## From the sources

The sources are needed for the console tools `logics_tool` and `dsl_tool`,
for the C++ library, and to work on CHASE. They need CMake 3.18 or later, a
C++17 compiler, Python 3 with its development files, and pybind11:

=== "Ubuntu"

    ```
    $> sudo apt-get install build-essential cmake git python3-dev pybind11-dev uuid-dev
    ```

=== "macOS"

    ```
    $> brew install cmake pybind11
    ```

### All the modules at once

The [chase](https://github.com/chase-cps/chase) repository has every module
as a submodule, and a script that builds and installs them in order:

```
$> git clone --recursive https://github.com/chase-cps/chase
$> cd chase
$> ./install.sh /path/to/install/directory
```

At the end, the script prints the lines to add to the shell configuration:

```
export PATH="/path/to/install/directory/chase/bin:$PATH"
export PYTHONPATH="/path/to/install/directory/chase/lib:$PYTHONPATH"
```

The Python modules are built for the interpreter given by the `PYTHON`
environment variable (by default `python3`). In the same repository,
`pip install .` builds and installs the Python package.

### One module at a time

Each module is a repository of the
[chase-cps](https://github.com/chase-cps) organization, and only the ones a
task needs have to be cloned:

- [core-library](https://github.com/chase-cps/core-library): the C++
  library that represents contracts and computes their algebra, with its
  Python interface. Every other module needs it.
- [chase-backends](https://github.com/chase-cps/chase-backends): writes the
  inputs of nuXmv, slugs, and gr1c from the contracts.
- [third_party](https://github.com/chase-cps/third_party): the runtime of
  ANTLR4 (version 4.5.4), used by the two parsers below.
- [logics_tool](https://github.com/chase-cps/logics_tool): reads the
  specification files and runs the console.
- [DSL_tool](https://github.com/chase-cps/DSL_tool): reads the
  design-pattern language (DSL) of the power systems.

For the C++ library alone, core-library is enough; to write the inputs of
the tools, add chase-backends; for `logics_tool` or `dsl_tool`, add
third_party and the tool. All the modules are installed in one directory,
given by the variable `CHASE_INSTALL_DIR`:

```
$> export CHASE_INSTALL_DIR=/absolute/path/to/install/directory
```

core-library comes first; then chase-backends and third_party; then
logics_tool and DSL_tool. Each module is built the same way:

```
$> git clone https://github.com/chase-cps/<module> <module>
$> cmake -S <module> -B <module>/build -Dpybind11_DIR=<path to pybind11Config.cmake>
$> cmake --build <module>/build
$> cmake --install <module>/build
```

The modules are built in `Release` mode; `-DCMAKE_BUILD_TYPE=Debug` builds
them for debugging, and `-DPython_EXECUTABLE=<python>` chooses the Python
interpreter. On macOS with Homebrew, `-DCMAKE_PREFIX_PATH=$(brew --prefix)`
finds pybind11 in place of `-Dpybind11_DIR`. `cmake --build
core-library/build --target doc` writes the documentation of the C++ library
with Doxygen.

The libraries are installed in `CHASE_INSTALL_DIR/chase/lib`, the headers in
`CHASE_INSTALL_DIR/chase/include`, the console tools in
`CHASE_INSTALL_DIR/chase/bin`, and ANTLR4 in `CHASE_INSTALL_DIR/third_party`.

## AI agents

The [MCP server](interfaces/mcp.md) gives the operations of CHASE to an AI
agent (Claude Code, Codex, Cursor, and other clients). With
[uv](https://docs.astral.sh/uv/), nothing is installed by hand:

```
$> claude mcp add chase -- uvx chase-mcp
```

or `pip install chase-mcp` and the command `chase-mcp`. The agent skill,
which tells the agent how to use the tools, and the settings of the other
clients are on the [MCP server](interfaces/mcp.md) page. The server needs
the same tools as the checks (`chase-cps doctor`).

An extension for VS Code, which draws the diagrams in the editor, is in
preparation.
