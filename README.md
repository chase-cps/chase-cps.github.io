# CHASE: Contract-based Heterogeneous Analysis and Systems Exploration

CHASE is a framework for requirement capture, formalization, and validation 
for cyber-physical systems.

## Intended Use

CHASE features a modular and extensible software infrastructure that can support
different domain-specific languages, modeling formalisms, and analysis tools. 
It has been applied to industrial design examples, including control of aircraft 
power distribution networks and arbitration of a mixed-criticality automotive bus.

## Publications: 
### A paper about CHASE has been presented at the IEEE/ACM Design Automation and Test in Europe (DATE) conference 2018
Pierluigi Nuzzo, Michele Lora, Yishai Feldman, Alberto Sangiovanni-Vincentelli,  
*"CHASE: Contract-Based Requirement Engineering for Cyber-Physical System Design"*

To cite chase in an academic work, please use the following bibtex entry:

````
@inproceedings{CHASE:2018:DATE,
  title={CHASE: Contract-based requirement engineering for cyber-physical system design},
  author={Nuzzo, Pierluigi and Lora, Michele and Feldman, Yishai A and Sangiovanni-Vincentelli, Alberto L},
  booktitle={Proceendings of the Design, Automation \& Test in Europe Conference \& Exhibition (DATE) 2008},
  pages={839--844},
  year={2018},
  organization={IEEE}
} 
````

The *scalability* directory, within the *demo* directory contains the specification files used in the experimental
section of the paper.

## CHASE components and repositories

CHASE is organized in the following components, available at the corresponding
repositories:
- **core-library** (mandatory): the library providing the classes, structures
  required to represents design problems and systems using CHASE. It also
  provides a set of utility classes, functions, and methods to manimulate
  CHASE-based representations. It is the main component of the CHASE framework.
\
[Link al repository](https://github.com/chase-cps/core-library)
- **chase-backends**: collection of backends tool encoding CHASE problems into
  different external tools, *i.e.*, Slugs, GR1C, NuSMV and PySTL.
\
[Link al repository](https://github.com/chase-cps/chase-backends)
- **DSL_tool**: tool using a Domain Specification Language to specify discrete
  timed problems difened over architectures modeled using graphs. 
\
[Link al repository](https://github.com/chase-cps/DSL_tool)
- **Logics_tool**: tool providing a console to manipulate assume-guarantee
  contracts expressed using a logics-based language.
\
[Link al repository](https://github.com/chase-cps/logics_tool)


## Index
- [Requirements and Installation][INST]


## Acknowledgement

This work was supported in part by the TerraSwarm Research Center, one of six 
centers supported by the STARnet phase of the Focus Center Research Program 
(FCRP) a Semiconductor Research Corporation program sponsored by MARCO and
DARPA.
Currently, it is supported by the European Project [DeFacto] (Design automation
for smart Factories) under the grant number 
[H2020-MSCA-IF-894237](https://cordis.europa.eu/project/id/894237).

[INST]: doc/md/install.md
[DeFacto]: https://defacto-h2020.github.io/
