# Tool integrations

CHASE computes the contract algebra itself, and hands the other questions on
contracts to external tools. Each integration turns contracts into the input
of a tool and reads its answer back:

| Integration | Tools | What CHASE does with them |
|---|---|---|
| [Model checking](model-checking.md) | nuXmv, NuSMV | decides the verification tasks (refinement, compatibility, consistency, implementations, environments), with counterexamples and cores |
| [GR(1) synthesis](synthesis.md) | slugs, gr1c | checks whether a component can be synthesized from a contract in the GR(1) fragment, synthesizes controllers, and explains unrealizable contracts |
| [Hardware: SVA and RTL](systemverilog.md) | any tool that reads SVA (Jasper, simulators), Yosys | reads contracts from SystemVerilog Assertions and writes them back as checker modules; reads RTL as state machines to check them against contracts |

The open-source tools are installed by CHASE (`chase-cps install nuxmv
--accept-license`, `chase-cps install slugs`, `pip install chase-cps[rtl]`
for Yosys) and are in the Docker image, except nuXmv, whose license does not
allow redistribution. The tools that read SVA are used through the files
that CHASE writes: nothing in them is specific to one tool.
