CHASE is a framework for requirement capture, formalization, and validation
for cyber-physical systems.

## Intended Use

CHASE features a modular and extensible software infrastructure that can support
different domain-specific languages, modeling formalisms, and analysis tools.
It has been applied to industrial design examples, including control of aircraft
power distribution networks and arbitration of a mixed-criticality automotive bus.

## Quick start

The [chase](https://github.com/chase-cps/chase) repository is the entry
point to CHASE: it collects all the modules and builds them at once. The
complete CHASE toolchain, including the gr1c, slugs, and NuSMV solvers, is
available as a Docker image:

````
$>  git clone --recursive https://github.com/chase-cps/chase
$>  cd chase
$>  docker build -t chase .
$>  docker run --rm -it chase
````

The container starts in the [demos](https://github.com/chase-cps/demos)
directory. To build CHASE from sources, see
[Requirements and Installation][INST].

## Python package

The `chase_cps` Python package provides contracts written in the standard LTL
syntax, the contract algebra of CHASE (composition, quotient, merging,
separation), and refinement, consistency, compatibility, and realizability
checks with nuXmv, NuSMV, and slugs. A failed check returns a counterexample
trace. From the chase repository:

````
$>  pip install .
````

````
from chase_cps import Contract, refines

spec = Contract.from_strings(inputs=["req"], outputs=["grant"],
                             assumptions=["G F !req"],
                             guarantees=["G (req -> F grant)"], name="Spec")
impl = Contract.from_strings(inputs=["req"], outputs=["grant"],
                             guarantees=["G (req -> X grant)"], name="Impl")
print(refines(impl, spec).status)
````

## Publications

### CHASE has been presented at the IEEE/ACM Design, Automation and Test in Europe (DATE) conference 2018
Pierluigi Nuzzo, Michele Lora, Yishai Feldman, Alberto Sangiovanni-Vincentelli,
*"CHASE: Contract-Based Requirement Engineering for Cyber-Physical System Design"*

To cite CHASE in an academic work, please use the following bibtex entry:

````
@inproceedings{CHASE:2018:DATE,
  title={CHASE: Contract-based requirement engineering for cyber-physical system design},
  author={Nuzzo, Pierluigi and Lora, Michele and Feldman, Yishai A and Sangiovanni-Vincentelli, Alberto L},
  booktitle={Proceedings of the Design, Automation \& Test in Europe Conference \& Exhibition (DATE) 2018},
  pages={839--844},
  year={2018},
  organization={IEEE}
}
````

The *DATE18* directory of the [demos](https://github.com/chase-cps/demos)
repository contains the specification files used in the experimental section
of the paper.

### Other publications

- Michele Lora, Pierluigi Nuzzo,
  *"A Contract-Based Requirement Engineering Framework for the Design of
  Industrial Cyber-Physical Systems"*,
  Work-in-Progress, ACM/IEEE International Conference on Cyber-Physical Systems
  (ICCPS), 2022, developed within the [DeFacto][DeFacto] project.
  [PDF](https://iris.univr.it/bitstream/11562/1077207/1/ICCPS_22_WiP_CHASE.pdf)

## CHASE components and repositories

CHASE is organized in the following components, available at the corresponding
repositories:
- **chase**: the entry point, collecting all the components as git
  submodules, with the scripts to build and install them, the Docker image,
  and the Python package.
\
[Link to the repository](https://github.com/chase-cps/chase)
- **core-library** (mandatory): the library providing the classes and structures
  required to represent design problems and systems using CHASE. It also
  provides a set of utility classes, functions, and methods to manipulate
  CHASE-based representations, and their Python bindings. It is the main
  component of the CHASE framework.
\
[Link to the repository](https://github.com/chase-cps/core-library)
- **chase-backends**: collection of backends encoding CHASE problems into
  different external tools, *i.e.*, Slugs, GR1C, NuSMV and PySTL.
\
[Link to the repository](https://github.com/chase-cps/chase-backends)
- **DSL_tool**: tool using a Domain Specific Language to specify discrete
  timed problems defined over architectures modeled using graphs.
\
[Link to the repository](https://github.com/chase-cps/DSL_tool)
- **logics_tool**: tool providing a console to manipulate assume-guarantee
  contracts expressed using a logics-based language.
\
[Link to the repository](https://github.com/chase-cps/logics_tool)
- **third_party**: third-party libraries required to build CHASE (ANTLR4 C++
  runtime).
\
[Link to the repository](https://github.com/chase-cps/third_party)
- **demos**: demonstrations and benchmarks of CHASE (DATE 2018, DATE 2021
  University Booth, CPS-IoT Week 2022, FDL 2024).
\
[Link to the repository](https://github.com/chase-cps/demos)


## Index
- [Requirements and Installation][INST]
- [Demos](https://github.com/chase-cps/demos)


## Acknowledgement

We acknowledge the support of the National Science Foundation (awards 1846524 and 2139982), the Office of Naval Research (award N00014-20-1-2258), the Defense Advanced Research Projects Agency (award HR00112010003), the Okawa Foundation, and the European Union’s Horizon 2020 research and innovation program under the [Marie Sklodowska-Curie grant agreement No. 894237](https://cordis.europa.eu/project/id/894237).

[INST]: doc/md/install.md
[DeFacto]: https://defacto-h2020.github.io/
