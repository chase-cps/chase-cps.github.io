CHASE is composed of multiple modules, available in the different repositories
available in this GitHub organization. The main component of chase is the 
***core library***, which is the only part that can be compiled and used as a
stand-alone software library. The core library defines all the classes necessary
to represent problems using CHASE. Furthermore, it provides a set of utilities
function to facilitate the manipulation of objects in CHASE.

The other components of CHASE require to install the core library first.
The following of this page describes the steps required to install the
components of CHASE.

## Docker image

All the components of CHASE, together with the external tools used by the
backends (gr1c, slugs and NuSMV), are available in a Docker image. The
`Dockerfile` is in the [chase](https://github.com/chase-cps/chase) repository,
which collects all the components:

````
$>  git clone --recursive https://github.com/chase-cps/chase
$>  cd chase
$>  docker build -t chase .
$>  docker run --rm -it chase
````

The same repository builds and installs all the components at once from
sources:

````
$>  ./install.sh /path/to/install/directory
````

The rest of this page describes how to build each component separately.

NuSMV is distributed only for x86_64. On ARM machines (e.g., Apple Silicon),
add `--platform linux/amd64` to both `docker` commands to have it in the image.

## Installation

CHASE has been developed on Unix-based systems. It has been tested on Ubuntu
20.04 and 22.04 (also in the Windows Subsystem for Linux) and on macOS. CHASE is mainly written in C++, with some parts
using Python 3. The compilation of CHASE is based on CMake.

### Dependencies

The following software is required to be installed in the machine where CHASE is
to be installed to compile the source code:
- A modern C++ compiler supporting the C++17 standard (either g++ or clang);
- CMake 3.18+;
- Doxygen, required to compile the documentation;
- Pybind11, required to compile the Python 3 interface. It can be installed
  using its source code, available [here](https://github.com/pybind/pybind11).

Furthermore, the **logics_tool** and the **DSL_tool** require to install the
C++ runtime of ANTLR4, version 4.5.4. Due to possible difficulties in finding
the correct version, we made it available at the following address:
https://github.com/chase-cps/third_party. On Linux, the runtime requires
`libuuid` (e.g., the `uuid-dev` package on Ubuntu).

The backends generate the input files of the following tools, which must be
installed to analyze the specifications:
- [gr1c](https://github.com/tulip-control/gr1c) and
  [slugs](https://github.com/VerifiableRobotics/slugs), for the realizability
  check and the synthesis of GR(1) specifications;
- [NuSMV](https://nusmv.fbk.eu/), to verify refinement, consistency and
  compatibility of contracts.

### Preliminaries

All the libraries, tools and documentation of CHASE must be installed all in the
same directory. The directory can be set before compiling and installing CHASE
by setting the environment variable: `CHASE_INSTALL_DIR`. To set the variable in
a Linux-based environment, using bash:

````
$>  export CHASE_INSTALL_DIR=</absolute/path/to/install/directory>
````

The installation of all the CHASE libraries and tools requires to know the
location of the pybind11 library. In the following of these installation
instructions we identify as `<path_to_pybind>` the absolute path to the directory
containing the `pybind11Config.cmake` file of your pybind11 installation.

### Installation order

It is important to install the different CHASE modules in an appropriate order.
In particular, the first component to be installed is the **core-library**.

Once the `core-library` is installed, the other modules can be installed in any
order. However, the installation of the **DSL_tool** and the **logics_tool**
requires to install the antlr4 runtime (available in the `third_party`
repository), and the **chase-backends** package first.

### Compilation of a CHASE module.

Let's create a directory `<module>` where to compile a CHASE module, and
clone the module repository in it, in a directory called `repo`:
````
$>  mkdir <module> && cd <module>
$>  git clone https://github.com/chase-cps/<module> repo
$>  mkdir build && cd build
````
Then, configure and compile:
````
$>  cmake ../repo -Dpybind11_DIR=<path_to_pybind>
$>  make
````
The modules are compiled in `Release` mode by default. To compile them in
`Debug` mode, add `-DCMAKE_BUILD_TYPE=Debug` to the `cmake` command. When
several Python interpreters are installed, add
`-DPython_EXECUTABLE=<path_to_python>` to choose the one the Python modules are
built for.

For the core-library, it is possible to create the Doxygen-based documentation:
````
$>  make doc
````
Finally, the module can be installed in the `CHASE_INSTALL_DIR` directory:
````
$>  make install
````

Third party dependencies will be installed in the
`CHASE_INSTALL_DIR/third_party` directory.
The CHASE modules will be installed in the `CHASE_INSTALL_DIR/chase` directory.
The libraries (both for the C++ and Python interfaces) will be installed in the
`CHASE_INSTALL_DIR/chase/lib` directory; the header files will be installed in
the `CHASE_INSTALL_DIR/chase/include`; the executables will be installed in the
`CHASE_INSTALL_DIR/chase/bin` directory. Finally, the documentation will be
available in the `CHASE_INSTALL_DIR/chase/doc` directory.
