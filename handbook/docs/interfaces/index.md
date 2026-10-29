# Interfaces

The same operations are available in several ways, with the same names:

| Interface | For |
|---|---|
| [Python package](python.md) | scripts and notebooks: `pip install chase-cps` |
| [Command line](command-line.md) | checking a specification file: `chase-cps check` |
| [Specification language and console](logics-tool.md) | the `.ltl` files of CHASE and the console of logics_tool |
| [SystemVerilog Assertions and RTL](systemverilog.md) | contracts read from and written as SVA, and RTL read with Yosys as state machines |
| [MCP server for AI agents](mcp.md) | the operations as tools of an agent, with a skill that tells it how to use them |

The [back ends](back-ends.md) are the tools that CHASE runs to answer the
questions on contracts: nuXmv and NuSMV for verification, slugs and gr1c for
synthesis.
