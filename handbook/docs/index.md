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

## Contract theory, interfaces, and tool integrations

<div class="layers" markdown>
<div class="layer" markdown>
**[Contract theory](contracts/index.md)**

- [*Formulas*](contracts/formulas.md): the assumptions and the guarantees
  are formulas of linear temporal logic over Boolean, integer, real, and
  bit-vector variables.
- [*Contract algebra*](contracts/algebra.md): composition, conjunction,
  merging, quotient, separation, implication, and the other operations that
  build a contract from contracts. They hold for any assume-guarantee
  contracts and are computed in closed form, without a solver.
- [*Contract-based verification*](contracts/checks.md): refinement,
  compatibility, consistency, and whether a component is an implementation,
  or an environment, of a contract.
</div>
<div class="layer" markdown>
**[Tool integrations](tools/index.md)**: the questions on contracts that
external tools answer.

- [*Model checking*](tools/model-checking.md) with nuXmv or NuSMV decides the
  verification tasks, with counterexamples and cores.
- [*GR(1) synthesis*](tools/synthesis.md) with slugs or gr1c, for contracts in
  the GR(1) fragment of LTL: realizability, controllers, unrealizable cores,
  well-separation, and vacuity.
- [*Hardware: SVA and RTL*](tools/systemverilog.md): contracts read from and
  written as SystemVerilog Assertions for the tools that read SVA, and RTL
  read with Yosys as state machines.
</div>
<div class="base" markdown>
[Interfaces](interfaces/index.md): Python, the command line, the
specification language and console (logics_tool), domain languages
(DSL_tool), and the MCP server for AI agents.
</div>
</div>

## Where to start

- [Getting started](getting-started.md): install CHASE (the Python package,
  the solvers, the Docker image, or the sources), then write two contracts,
  compose them, check a refinement, and read a counterexample.
- [Demos](demos/index.md): design iterations on real examples, from the
  buffer of a circuit and the arbiter of a bus to the lift modes of a NASA
  aircraft and the autopilot of a Lockheed Martin challenge.
- [MCP server](interfaces/mcp.md): the operations of CHASE as tools for AI
  agents.
- [News](news.md): the changes of each version.

CHASE started at the University of Southern California and the University
of Verona, and is developed at the University of California, Berkeley. It is
open source, under the BSD 3-Clause License: see
[Contributing](contributing.md) and [Publications](publications.md).
