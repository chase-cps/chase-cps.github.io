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
- [SMT and optimization](smt.md), with z3: the formulas over a bounded
  number of steps (static contracts, signal temporal logic), and the
  optimization problems of CHASE (best values, worst cases, repair), which
  are the problems of a MILP.

How to install each tool, and which ones the Docker image has, is on the
[Installation](../installation.md#the-tools-that-run-the-checks) page.
