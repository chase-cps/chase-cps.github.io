# Overview

CHASE (Contract-based Heterogeneous Analysis and Systems Exploration) is a
framework for requirement capture, formalization, and validation for
cyber-physical systems. It features a modular and extensible software
infrastructure that can support different domain-specific languages,
modeling formalisms, and analysis tools. It has been applied to industrial
design examples, including the control of aircraft power distribution
networks and the arbitration of a mixed-criticality automotive bus.

The requirements of the components and of the system are written as
assume-guarantee contracts. With them, CHASE:

- composes the contracts, and checks that the components refine the system;
- finds the requirements that are in conflict;
- checks implementations (formulas, state machines, RTL) against the
  contracts;
- synthesizes controllers.

The contracts are written in Python, in the specification language of
CHASE, or in SystemVerilog Assertions, or by an AI agent through the MCP
server.

<figure markdown>
![The CHASE framework: front ends, libraries, back ends](assets/chase-framework.png){ width="600" }
<figcaption>The front ends build the CHASE representation of a design problem, the libraries manipulate systems and contracts, and the back ends translate the problems for the verification and synthesis tools.</figcaption>
</figure>

```
$> pip install chase-cps
```

```python
from chase_cps import Contract, refines

spec = Contract.from_strings(inputs=["req"], outputs=["grant"],
                             assumptions=["G F !req"],
                             guarantees=["G (req -> F grant)"], name="Spec")
impl = Contract.from_strings(inputs=["req"], outputs=["grant"],
                             guarantees=["G (req -> X grant)"], name="Impl")
print(refines(impl, spec).status)    # valid
```

## Where to start

- [Getting started](getting-started.md): install CHASE, and write a first
  contract.
- [Demos](demos/index.md): design problems, from their requirements to a
  result.
- [MCP server](interfaces/mcp.md): CHASE for AI agents.

CHASE started at the University of Southern California and the University
of Verona, and is developed at the University of California, Berkeley. It is
open source, under the BSD 3-Clause License: see
[Contributing](contributing.md) and [Publications](publications.md).
