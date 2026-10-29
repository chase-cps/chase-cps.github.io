# Getting started

This page installs CHASE, then writes a first contract: a system contract and
two component contracts, composed and checked.

## Installation

There are three ways to install CHASE: the Python package (the quickest), the
Docker image (everything, including the demos and all the solvers), or the
sources.

### Python package

```
$> pip install chase-cps
```

Wheels are available for Python 3.10 to 3.15 on Linux (x86_64 and aarch64,
glibc 2.28 or later) and macOS 11 or later (arm64 and x86_64). Windows is not
supported: use WSL or the Docker image.

The package contains the CHASE library. The checks call external tools, which
are installed separately:

- [nuXmv](https://nuxmv.fbk.eu/) for contract-based verification and for
  `remove_redundant`. nuXmv is free for academic and non-commercial use.
- [slugs](https://github.com/VerifiableRobotics/slugs) for the other analyses
  of GR(1) synthesis.

`chase-cps install` downloads nuXmv from its site, and builds slugs from its
sources, into `~/.chase`:

```
$> chase-cps install nuxmv --accept-license    # Linux x86_64, macOS arm64
$> chase-cps install slugs                     # needs a C++ compiler, make, and Boost
$> chase-cps doctor                            # the tools found, and how to install the others
```

On macOS, nuXmv needs the libraries of Homebrew (`brew install libxml2 gmp
libedit`). On Linux it needs `libxml2` and `libedit2`, and the C++ library of
GCC 13 or later (Ubuntu 24.04, Debian 13, Fedora 39, or newer). The tools can
also be installed by hand: they are looked up in the `PATH` and in
`~/.chase/bin`, or given with the environment variables `CHASE_NUXMV` and
`CHASE_SLUGS`.

!!! note "Without nuXmv"
    Where nuXmv cannot be used (e.g. for commercial purposes), the checks run
    with [NuSMV](https://nusmv.fbk.eu/) (LGPL) instead: `chase-cps install
    nusmv` installs it on Linux x86_64, or set `CHASE_NUSMV`. NuSMV has no
    real type: the real variables are then checked with exact regions when
    they are only compared with constants, and with predicate abstraction
    otherwise.

For the real variables, z3 refines the predicate abstraction when it is
installed: `pip install chase-cps[reals]`.

### Docker image

The image has the whole toolchain: the CHASE tools, the Python package, the
demos, gr1c, slugs, NuSMV, and Yosys. It has no nuXmv, whose license does
not allow redistribution; in a container, `chase-cps install nuxmv
--accept-license` installs it (x86_64 only).

```
$> docker pull ghcr.io/chase-cps/chase
$> docker run --rm -it ghcr.io/chase-cps/chase
```

The container starts in the directory of the demos. All the demos are run and
checked with:

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

### From the sources

CHASE requires CMake 3.18 or later, a C++17 compiler, Python 3 with its
development files, and pybind11:

=== "Ubuntu"

    ```
    $> sudo apt-get install build-essential cmake git python3-dev pybind11-dev uuid-dev
    ```

=== "macOS"

    ```
    $> brew install cmake pybind11
    ```

Then clone the repository with its submodules and run the installation script:

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
environment variable (by default `python3`). `pip install .` in the
repository builds and installs the Python package from the sources.

## A first contract

This page writes a system contract and two component contracts, composes the
components, checks that they refine the system, reads a counterexample, and
finds requirements in conflict. It needs `pip install chase-cps` and nuXmv
(`chase-cps install nuxmv --accept-license`). The outputs below are those of
chase-cps 0.3.1.

### The contracts

A contract has inputs (controlled by the environment), outputs (controlled by
the component), assumptions on the environment, and guarantees of the
component, written in LTL.

```python
from chase_cps import Contract, refines, verify, unsat_core

# Every request is eventually granted, if requests stop infinitely often.
system = Contract.from_strings(
    inputs=["req"], outputs=["grant"], name="System",
    assumptions=["G F !req"],
    guarantees=["G (req -> F grant)"])

# A queue that forwards each request, and a server that answers it.
queue = Contract.from_strings(
    inputs=["req"], outputs=["fwd"], name="Queue",
    guarantees=["G (req -> X fwd)"])
server = Contract.from_strings(
    inputs=["fwd"], outputs=["grant"], name="Server",
    guarantees=["G (fwd -> X grant)"])
```

### Composition and refinement

Variables with the same name are connected: the output `fwd` of the queue is
the input of the server. The composition is computed in closed form by the
core library ([contract algebra](contracts/algebra.md)); the refinement is
checked by nuXmv ([contract-based verification](contracts/checks.md)).

```python
both = queue.compose(server)
print(refines(both, system).status)
```

```
valid
```

### A counterexample

A server that may stop answering for good does not refine the system:

```python
lazy = Contract.from_strings(
    inputs=["fwd"], outputs=["grant"], name="Lazy",
    guarantees=["G (fwd -> F grant) | F G !grant"])
r = refines(queue.compose(lazy), system)
print(r.status, r.failed)
print(r.guarantees.trace)
```

```
invalid guarantees
  0: req=True, fwd=True, grant=False
  1: req=False, fwd=True, grant=False  <- loop starts
  2: req=False, fwd=True, grant=False
```

The guarantees fail: at step 0 there is a request, and `grant` stays false
forever in the loop, which the lazy server allows (`F G !grant`) and the
system forbids. A trace is a prefix followed by a loop repeated forever.

### Requirements in conflict

```python
bad = Contract.from_strings(
    inputs=["req"], outputs=["grant"], name="Bad",
    guarantees=["G (req -> X grant)", "G !grant", "F req"])
print(verify(bad).status)
print(unsat_core(bad).core)
```

```
unsat
CONTRACT Bad_core
  input req : bool
  output grant : bool
  Assumptions:
    true
  Guarantees:
    G (req -> X grant)
    G !grant
    F req
```

`verify` checks that the assumptions and the guarantees can hold together
(A ∧ G satisfiable), which implies compatibility and consistency; here the
guarantees cannot hold together. `unsat_core` gives a minimal set of terms that cannot hold
together: removing any of them makes the rest satisfiable.

### Next

- The [contract algebra](contracts/algebra.md), the [checks](contracts/checks.md),
  and [GR(1) synthesis](contracts/synthesis.md).
- The same operations from a [specification file](interfaces/logics-tool.md)
  with the [command line](interfaces/command-line.md), or from an AI agent
  with the [MCP server](interfaces/mcp.md).

## Where the code is

CHASE is developed in the [chase-cps](https://github.com/chase-cps)
organization on GitHub. [chase](https://github.com/chase-cps/chase) holds the
Python package, the build of the C++ modules, the Docker image, and the
documentation; [chase-mcp](https://github.com/chase-cps/chase-mcp) the MCP
server; [demos](https://github.com/chase-cps/demos) the demos. The other
repositories and how to contribute are on the [Contributing](contributing.md)
page.
