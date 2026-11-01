# Tool integrations

CHASE computes the contract algebra itself, and gives the other questions
on contracts to external tools. Each integration writes the contracts as the
input of a tool, and reads its answer back:

- [Model checking](model-checking.md), with nuXmv or NuSMV: the
  verification tasks (refinement, compatibility, consistency,
  implementations, environments), with counterexamples and cores.
- [GR(1) synthesis](synthesis.md), with slugs or gr1c: whether a component
  can be synthesized from a contract in the GR(1) fragment, the controllers,
  and the explanation of an unrealizable contract.
- [C programs](c-programs.md), with ESBMC or CBMC: C functions checked
  against contracts, written in Python or in the clauses of the C file.
- [Hardware: SVA and RTL](systemverilog.md), with any tool that reads SVA
  (Jasper, simulators) and with Yosys: contracts read from SystemVerilog
  Assertions and written back as checker modules, and RTL read as state
  machines and checked against contracts.

The tools are installed as follows:

- nuXmv: `chase-cps install nuxmv --accept-license`. Its license does not
  allow redistribution, so it is not in the Docker image.
- slugs: `chase-cps install slugs`.
- Yosys: `pip install chase-cps[rtl]`.

The Docker image has slugs, gr1c, NuSMV, and Yosys. The tools that read SVA
are used through the files that CHASE writes; nothing in these files is
specific to one tool.
