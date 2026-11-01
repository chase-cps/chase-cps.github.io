# Hardware: SVA and RTL

This page is for hardware designers: contracts written in SystemVerilog
Assertions, checked against RTL, and written back as checker modules for a
formal tool or a simulator.

`parse_sva` reads the `assume property` and `assert property` statements of
SystemVerilog as a contract: the assumptions and the guarantees. The text can
be a module, a bind file, or the statements alone. `to_sva` writes a contract
as a checker module, which any tool that reads SVA can check, formal or
simulator. Nothing in either is specific to a tool. In the MCP server the
tools have the same names.

```
from chase_cps import ltl, parse_sva

r = parse_sva("""
module arbiter (input logic clk, input logic rst, input logic req,
                output logic gnt, output logic [7:0] count);
  default clocking @(posedge clk); endclocking
  default disable iff (rst);
  A0: assume property (req |=> !req);
  G0: assert property (req |-> ##[1:2] gnt);
  G1: assert property (gnt |=> count == $past(count) + 1);
endmodule""")
print(r.contract.inputs, r.contract.outputs)
for p in r.properties:
    print(p.label, ltl.to_str(p.formula))
print(r.skipped)       # the statements not read, with the reason
```

## Reading

| SVA | Contract |
|---|---|
| `assert property (p)` | the guarantee `G p`: an assertion is checked at every cycle |
| `assume property (p)`, `restrict property (p)` | the assumption `G p` |
| `initial assert property (p)` | `p`, at the first cycle |
| `cover property (p)` | kept apart, in `covers` |
| `logic [7:0] x`, `logic signed [7:0] x` | `word[8]`, `signed word[8]`; a 1-bit signal is a Boolean |
| `logic [3:0][7:0] x` | `word[32]`; `x[2]` is bits 23 to 16 |
| `u1.state` | `u1__state`, mapped back in `names` |

One step of LTL is one cycle of the clock. The widths are those of Verilog:
the operands of an operation are extended to the width of the context
first, so in `count == $past(count) + 1` the sum has 32 bits (as the
constant 1) and does not wrap around; the property fails when `count` goes
from 255 to 0.

What is read:

- The property operators: `not`, `and`, `or`, `implies`, `iff`, `|->`,
  `|=>`, `#-#`, `#=#`, `if`/`else`, `nexttime`, `always`, `s_always`,
  `eventually`, `s_eventually`, `until`, `s_until`, `until_with`,
  `s_until_with`, `strong`, `weak`.
- The sequences of bounded length: `##n`, `##[m:n]`, `[*m:n]`, `and`, `or`,
  `intersect`, `throughout`, `within`, `first_match`. `##[m:$]` is read in
  an antecedent and in a strong sequence.
- The system functions `$past`, `$rose`, `$fell`, `$stable`, `$changed`,
  `$onehot`, `$onehot0`, `$countones`.
- `disable iff`, `default clocking`, and `default disable iff`.
- Named properties and sequences, with arguments.
- `assign` and `wire x = e`.

- A property that looks before the first cycle is checked from the cycle
  where the past exists (`from_cycle`): `x == $past(x)` from cycle 1.
  Values two cycles apart or more are written with `past(x, n)`.
- In a consequent, `a |-> ##[1:$] b` is weak in an assert and never fails,
  so it is not read: write `a |-> s_eventually b`.
- A contract has one clock: with several, `clock` chooses one (by default
  the clock of most properties), and the properties of the other clocks are
  skipped.
- The directions come from `inputs` or `outputs`, then from the ports of
  the module. Signals without a declaration are read as 1-bit signals and
  listed in `undeclared`.

What is not read, and listed in `skipped` with the reason:

- local variables;
- `[->n]` and `[=n]`, and unbounded repetition;
- unpacked arrays;
- the digits `x` and `z`;
- immediate assertions.

## Writing

```
from chase_cps import Contract, to_sva

c = Contract.from_dict({"name": "Arb", "inputs": {"req": "bool"},
                        "outputs": {"gnt": "bool", "count": "word[8]"},
                        "assumptions": ["G (req -> X !req)"],
                        "guarantees": ["G (req -> X gnt | X X gnt)",
                                       "G (gnt -> count' = count + 1)"]})
print(to_sva(c, reset="rst", bind="arbiter"))
```

A formula `G p` is checked at every cycle. Any other formula is checked
once, at the first cycle (`initial`). The variables are written as follows:

- a word is a vector;
- an integer range is an `int`, with its range assumed (an input) or
  asserted (an output);
- a real variable cannot be written.

The options of `to_sva`:

- `reset`: the properties are disabled while it holds.
- `bind`: adds a bind statement that puts the checker in a design module,
  with its ports connected by name.

The attribute `(* chase = "output" *)` keeps the role of each signal for
`parse_sva`; the tools ignore it.

## Meaning

The meaning is that of the standard, IEEE 1800-2017 (chapter 16, and Annex
F for `disable iff`), not that of a tool. Tools may differ in corner cases:
when the failure of an attempt is already decided by the values before a
reset, but a sequence of the attempt is still running when the reset comes,
the standard gives a failure and some tools a disabled attempt. To compare
with a tool, run its checks on the SVA.

## RTL

A Verilog or SystemVerilog module is a state machine:
`Model.from_rtl(files, top)` reads it with Yosys
(`pip install chase-cps[rtl]`), and `is_implementation`, `is_environment`,
and `is_receptive` take it. The ports are the variables of the contracts (a
1-bit port is a Boolean, a wider one a word), and one step is one cycle.

```
from chase_cps import Model, is_implementation

m = Model.from_rtl(["bsg_dff_reset.sv", "bsg_dff_en.sv", "bsg_one_fifo.sv"],
                   "bsg_one_fifo", parameters={"width_p": 4}, reset="reset_i",
                   names={"ready_and_o": "ready_o"})
print(is_implementation(m, slot).status)
```

`parameters` sets the parameters of the top module, `names` renames ports,
`defines` gives macros, and `reset` holds the reset in the first step and
checks the contracts from the step after it. The checks are those of nuXmv,
for small and medium designs. The [Buffer swap demo](../demos/buffer-swap.md)
checks the RTL of two FIFOs.
