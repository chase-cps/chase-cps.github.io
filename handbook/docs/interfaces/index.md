# Interfaces

The operations of CHASE have the same names in every interface. Here is one
contract, an arbiter that grants every request when the requests stop
infinitely often, and the check that an implementation that grants at the
next step refines it, in each interface:

=== "Python"

    ```python
    from chase_cps import Contract, refines

    spec = Contract.from_strings(inputs=["req"], outputs=["grant"],
                                 assumptions=["G F !req"],
                                 guarantees=["G (req -> F grant)"], name="Spec")
    impl = Contract.from_strings(inputs=["req"], outputs=["grant"],
                                 guarantees=["G (req -> X grant)"], name="Impl")
    print(refines(impl, spec).status)    # valid
    ```

=== "Specification language"

    ```
    NAME: arbiter;

    CONTRACT Spec:
        input boolean variable req;
        output boolean variable grant;
        Assumptions:
            G(F(!req));
        Guarantees:
            G(req -> F(grant));

    CONTRACT Impl:
        input boolean variable req;
        output boolean variable grant;
        Assumptions:
            true;
        Guarantees:
            G(req -> X(grant));
    ```

=== "Command line"

    ```
    $> chase-cps check arbiter.ltl --refines Impl Spec
    refines     Impl <= Spec                             valid           0.03 s
    ```

=== "SystemVerilog Assertions"

    ```systemverilog
    module spec (input logic clk, input logic req, output logic grant);
      A1: assume property (@(posedge clk) s_eventually !req);
      G1: assert property (@(posedge clk) req |-> s_eventually grant);
    endmodule
    ```

    `parse_sva` reads this module as the contract Spec: the ports give the
    inputs and the outputs, `assume` the assumptions, and `assert` the
    guarantees.

=== "MCP (AI agents)"

    ```json
    {"tool": "refines",
     "arguments": {
       "refined":  {"name": "Impl", "inputs": {"req": "bool"}, "outputs": {"grant": "bool"},
                    "guarantees": ["G (req -> X grant)"]},
       "abstract": {"name": "Spec", "inputs": {"req": "bool"}, "outputs": {"grant": "bool"},
                    "assumptions": ["G F !req"], "guarantees": ["G (req -> F grant)"]}}}
    ```

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
