---
hide:
  - navigation
  - toc
---

<div class="hero" markdown>
<div class="hero-text" markdown>
<h1 class="hero-title">CHASE</h1>
<p class="hero-name">Contract-based Heterogeneous Analysis and Systems Exploration</p>
<p class="hero-tagline">Contract-based design, from circuits to systems</p>
<p class="hero-lead">CHASE writes the requirements of components and systems
as assume-guarantee contracts, composes them, checks them, and synthesizes
controllers. Contracts come from Python, a specification language,
SystemVerilog Assertions, or an AI agent; components can be formulas, state
machines, or RTL.</p>
<div class="hero-install" markdown>`pip install chase-cps`</div>

[Get started](getting-started/install.md){ .md-button .md-button--primary }
[Demos](demos/index.md){ .md-button }
[GitHub](https://github.com/chase-cps/chase){ .md-button }
</div>
<div class="hero-code" markdown>

```python
from chase_cps import Contract, refines

spec = Contract.from_strings(
    inputs=["req"], outputs=["grant"],
    assumptions=["G F !req"],
    guarantees=["G (req -> F grant)"], name="Spec")
impl = Contract.from_strings(
    inputs=["req"], outputs=["grant"],
    guarantees=["G (req -> X grant)"], name="Impl")

print(refines(impl, spec).status)   # valid
print(refines(spec, impl).status)   # invalid, with a trace
```

</div>
</div>

## What CHASE does

Each level builds on the one that contains it.

<div class="levels" markdown>
<div class="level l1" markdown>
<span class="level-name">Contract algebra</span> <span class="level-scope">for any assume-guarantee contracts</span>

Composition, conjunction, merging, quotient, separation, implication, and
the other operations that build a contract from contracts, computed in
closed form. [More](contracts/algebra.md)

<div class="level l2" markdown>
<span class="level-name">Contract-based verification</span> <span class="level-scope">for contracts in LTL, by model checking</span>

Refinement, compatibility, consistency, implementations and environments
(formulas, state machines, RTL). A failed check comes with a counterexample,
and a core gives the requirements in conflict. [More](contracts/checks.md)

<div class="level l3" markdown>
<span class="level-name">GR(1) synthesis</span> <span class="level-scope">for contracts in the GR(1) fragment of LTL</span>

Realizability, controllers, unrealizable cores, well-separation, and
vacuity: can a component be synthesized from its contract?
[More](contracts/synthesis.md)
</div>
</div>
</div>
</div>

## From circuits to systems

<div class="grid cards domains" markdown>

-   :material-chip:{ .lg .middle } **Hardware**

    ---

    Contracts read from and written as SystemVerilog Assertions, RTL read
    with Yosys, bit-vector variables. A quotient written as SVA and proven on
    the RTL of BaseJump STL with Jasper.

    [BufferSwap](demos/buffer-swap.md) · [AHB arbiter](demos/ahb.md)

-   :material-airplane:{ .lg .middle } **Cyber-physical systems**

    ---

    LTL with Boolean, integer, and real variables. Requirements of NASA and
    Lockheed Martin case studies: conflicts, timing, and the composition of
    components.

    [Lift-Plus-Cruise](demos/lift-plus-cruise.md) · [LMFSM](demos/lm-fsm.md)

-   :material-sitemap:{ .lg .middle } **Architectures and domain languages**

    ---

    Components, connections, and patterns of requirements, for electrical
    power systems and factories, turned into GR(1) specifications.

    [Power systems and factories](demos/power-systems.md)

-   :material-robot-outline:{ .lg .middle } **AI agents**

    ---

    Every operation as a tool of an MCP server, with a skill that tells an
    agent how to write, check, and fix contracts.

    [MCP server](interfaces/mcp.md)

</div>

## News

<div class="news-item" markdown>
<span class="news-date">October 28, 2026</span>

### CHASE 0.4.1: contracts for hardware

SystemVerilog Assertions in and out, RTL read with Yosys, merging and
quotient that keep the terms of the contracts, and three new demos.
[Read more](news.md#chase-041-contracts-for-hardware)
</div>

<div class="news-item" markdown>
<span class="news-date">October 28, 2026</span>

### CHASE 0.4.0: bit vectors and engines

Words as in nuXmv and SystemVerilog, past values, and the engines of nuXmv.
[Read more](news.md#chase-040-bit-vectors-and-engines)
</div>

[All news](news.md)

## The framework

<figure markdown>
![The CHASE framework: front ends, libraries, back ends](assets/chase-framework.png){ width="720" }
</figure>

CHASE started at the University of Southern California and the University of
Verona, and is developed at the University of California, Berkeley. See the
[publications](about/publications.md) and the
[repositories](about/repositories.md).
