# Hardware: SVA and RTL

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

The properties read: `not and or implies iff |-> |=> #-# #=# if/else nexttime
always s_always eventually s_eventually until s_until until_with
s_until_with strong weak`; the sequences of bounded length (`##n`,
`##[m:n]`, `[*m:n]`, `and`, `or`, `intersect`, `throughout`, `within`,
`first_match`); `##[m:$]` in an antecedent and in a strong sequence;
`$past`, `$rose`, `$fell`, `$stable`, `$changed`, `$onehot`, `$onehot0`,
`$countones`; `disable iff`, `default clocking`, `default disable iff`;
named properties and sequences with arguments; `assign` and `wire x = e`.

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

Not read, and listed in `skipped` with the reason: local variables, `[->n]`
and `[=n]`, unbounded repetition, unpacked arrays, `x` and `z` digits,
immediate assertions.

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

A formula `G p` is checked at every cycle, any other formula once, at the
first cycle (`initial`). Words are vectors, integer ranges `int` with their
range assumed (inputs) or asserted (outputs); real variables cannot be
written. `reset` disables the properties while it holds, and `bind` adds a
bind statement that puts the checker in a design module, its ports
connected by name. The attribute `(* chase = "output" *)` keeps the role of
each signal for `parse_sva`; tools ignore it.

## Meaning

The meaning is that of the standard, IEEE 1800-2017 (chapter 16, and Annex
F for `disable iff`), not that of a tool. Tools may differ in corner cases:
when the failure of an attempt is already decided by the values before a
reset, but a sequence of the attempt is still running when the reset comes,
the standard gives a failure and some tools (Jasper) a disabled attempt. To
compare with a tool, run its checks on the SVA.

The reading is tested against a reference interpreter of the standard on
random properties and traces, against Verilator, and against Jasper: each
property and the SVA written back from its contract were proved equivalent.
