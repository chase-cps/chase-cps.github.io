CHASE is composed of multiple modules, available in the different repositories
available in this GitHub organization. The main component of chase is the 
***core library***, which is the only part that can be compiled and used as a
stand-alone software library. The core library defines all the classes necessary
to represent problems using CHASE. Furthermore, it provides a set of utilities
function to facilitate the manipulation of objects in CHASE.

The other components of CHASE requires to install the core library first. 
The following of this page describes the steps required to install the
components of CHASE.

## Installation

CHASE has been developed on Unix-based systems. Currently, it is being developed
and tested on the Ubuntu 20.04 distribution available in 
Windows Subsystem for Linux. CHASE is mainly written in C++, with some parts
using Python 3. The compilation of CHASE is based on CMake.

### Dependencies

The following software is required to be installed in the machine where CHASE is
to be installed to compile the source code:
- A modern C++ compiler supporting the C++11 standard (either g++ or clang);
- CMake 3.10+;
- Doxygen, required to compile the documentation;
- Pybind11, required to compile the Python 3 interface. It can be installed
  using its source code, available [here](https://github.com/pybind/pybind11).

Furthermore, the **Logic_tool** and the **DSL_tool** requires to install the
C++ runtime of ANTLR4, version 4.5.4. Due to possible difficulties in finding
the correct version, we made it available at the following address:
https://github.com/chase-cps/third_party.

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





