# Installation

There are three ways to install CHASE: the Python package (the quickest), the
Docker image (everything, including the demos and all the solvers), or the
sources.

## Python package

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

## Docker image

The image has the whole toolchain: the CHASE tools, the Python package, the
demos, gr1c, slugs, and nuXmv (installed only when its license is accepted).

```
$> git clone --recursive https://github.com/chase-cps/chase
$> cd chase
$> docker build --build-arg ACCEPT_NUXMV_LICENSE=yes -t chase .
$> docker run --rm -it chase
```

The container starts in the directory of the demos. All the demos are run and
checked with:

```
$> docker run --rm chase /opt/chase/tests/demo-suite.sh
```

nuXmv is distributed for Linux only for x86_64. On ARM machines (e.g. Apple
Silicon), add `--platform linux/amd64` to `docker build` and `docker run`.

## From the sources

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
