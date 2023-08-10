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
[Link to the repository](https://github.com/chase-cps/core-library)
- **chase-backends**: collection of backends tool encoding CHASE problems into
  different external tools, *i.e.*, Slugs, GR1C, NuSMV and PySTL.
\
[Link to the repository](https://github.com/chase-cps/chase-backends)
- **DSL_tool**: tool using a Domain Specification Language to specify discrete
  timed problems difened over architectures modeled using graphs. 
\
[Link to the repository](https://github.com/chase-cps/DSL_tool)
- **Logics_tool**: tool providing a console to manipulate assume-guarantee
  contracts expressed using a logics-based language.
\
[Link to the repository](https://github.com/chase-cps/logics_tool)


## Index
- [Requirements and Installation][INST]


## Acknowledgement

We acknowledge the support of the National Science Foundation (awards 1846524 and 2139982), the Office of Naval Research (award N00014-20-1-2258), the Defense Advanced Research Projects Agency (award HR00112010003), the Okawa Foundation, and the European Union’s Horizon 2020 research and innovation program under the [Marie Sklodowska-Curie grant agreement No. 894237](https://cordis.europa.eu/project/id/894237).

[INST]: doc/md/install.md
[DeFacto]: https://defacto-h2020.github.io/
