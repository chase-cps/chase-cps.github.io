# Overview

CHASE (Contract-based Heterogeneous Analysis and Systems Exploration) is a
framework for the design of systems with assume-guarantee contracts, from
circuits to cyber-physical systems. The requirements of the components and
of the system are written as contracts; CHASE composes them, checks that the
components refine the system, finds the requirements that conflict, checks
implementations (formulas, state machines, RTL) against them, and
synthesizes controllers. The contracts come from Python, the CHASE
specification language, SystemVerilog Assertions, or an AI agent through an
MCP server.

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

## Contract theory, and contracts in LTL

CHASE separates what holds for any assume-guarantee contracts from what
depends on the logic in which the contracts are written.

<div class="layers" markdown>
<div class="layer" markdown>
**Contract theory** (any assume-guarantee contracts)

- *Contract algebra*: composition, conjunction, merging, quotient,
  separation, implication, and the other operations that build a contract
  from contracts, computed in closed form, without a solver.
  [More](contracts/algebra.md)
- *Contract-based verification*: refinement, compatibility, consistency, and
  whether a component is an implementation, or an environment, of a
  contract. [More](contracts/checks.md)
</div>
<div class="layer" markdown>
**Contracts in LTL** (what CHASE decides)

- The verification tasks reduce to the validity or the satisfiability of
  [LTL formulas](contracts/formulas.md) over Boolean, integer, real, and
  bit-vector variables, which a model checker decides. A failed task comes
  with a counterexample, and a core gives the requirements in conflict.
- *GR(1) synthesis*, for contracts in the GR(1) fragment of LTL:
  realizability, controllers, unrealizable cores, well-separation, and
  vacuity. Can a component be synthesized from its contract?
  [More](contracts/synthesis.md)
</div>
<div class="base" markdown>
Front ends: the specification language and console (logics_tool), domain
languages (DSL_tool), SystemVerilog Assertions and RTL, Python, the command
line, and the MCP server for AI agents. [Back ends](contracts/back-ends.md):
nuXmv, NuSMV, slugs, gr1c, and Yosys.
</div>
</div>

## Where to start

- [Installation](getting-started/install.md): the Python package, the solvers,
  the Docker image, or the sources.
- [A first contract](getting-started/first-contract.md): write two contracts,
  compose them, check a refinement, and read a counterexample.
- [Demos](demos/index.md): design iterations on real examples, from the
  buffer of a circuit and the arbiter of a bus to the lift modes of a NASA
  aircraft and the autopilot of a Lockheed Martin challenge.
- [MCP server](interfaces/mcp.md): the operations of CHASE as tools for AI
  agents.
- [News](news.md): what each version brought, from 0.1 (October 2026) to
  0.4.1, contracts for hardware.
