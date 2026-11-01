# Formulas

The assumptions and the guarantees of a contract are formulas of linear
temporal logic (LTL) over variables of four types. The Python package, the
command line (JSON files), and the MCP server read them in the standard LTL
syntax described here; the specification files of `logics_tool` use the
[logics language](../interfaces/logics-tool.md), with the same operators and
the same precedence. Assertions written in SystemVerilog are read as the same
formulas (see [SystemVerilog Assertions](#systemverilog-assertions) below).

## Variables

| Type | Written | Values |
|---|---|---|
| Boolean | `"bool"` | true, false |
| Integer range | `[0, 3]` (in the logics language `integer (0:3)`) | the integers from 0 to 3 |
| Real | `"real"` | any real number |
| Word | `"word[8]"`, `"signed word[8]"` | a bit vector of 8 bits, unsigned (0 to 255) or in two's complement (-128 to 127) |

The inputs are controlled by the environment, the outputs by the component.
Names start with a letter and are not keywords (`G`, `F`, `X`, `U`, `R`, `W`,
`P`, `NAME`, `CONTRACT`, `mod`, `xor`, ...).

```
from chase_cps import Contract

counter = Contract.from_dict({"name": "Counter", "inputs": {"inc": "bool", "step": [1, 3]},
                              "outputs": {"n": "word[8]", "k": [0, 9]},
                              "assumptions": ["G F inc"],
                              "guarantees": ["G (inc -> n' = n + 1)",
                                             "G (k <= 9 - step -> k' = k + step)"]})
tank = Contract.from_dict({"name": "Tank", "inputs": {"flow": "real"},
                           "outputs": {"level": "real"},
                           "assumptions": ["G (0 <= flow & flow <= 1.5)"],
                           "guarantees": ["G (level' = level + 0.5 * flow)"]})
```

## Logic

| Operators | Meaning |
|---|---|
| `!`, `&`, `\|`, `->`, `<->`, `xor`, `true`, `false` | the Boolean connectives |
| `X p` | p holds at the next step |
| `G p`, `F p` | p holds at every step, at some step |
| `p U q`, `p R q`, `p W q` | until, release, weak until |
| `G[a,b] p`, `F[a,b] p`, `p U[a,b] q` | the same over the steps a to b |
| `x'` | the value of x at the next step |
| `past(x, n)` | the value of x n steps before (any value in the first n steps) |

The aliases are:

- `[]` and `<>` for `G` and `F`;
- `&&`, `||`, `=>`, `<=>`, and `==` for `&`, `|`, `->`, `<->`, and `=`.

The temporal operators apply to formulas. Inside a relation or an
arithmetic expression, the value at the next step is written `x'`, not
`X x`. For instance, `G X X (y = past(x, 2))` says that y is x delayed by
two steps; `past` is written under `X`, so that it never reads before the
first step.

## Relations and arithmetic

The relations `= != < <= > >=` compare two expressions of the same type; a
Boolean is compared only with `=` and `!=`.

| Type | Operators | Notes |
|---|---|---|
| Integer | `+ - * / mod` | the values stay in the range of the variables; a constant compared with an integer should be in its range |
| Real | `+ - * /` | constants with a fraction (`20.5`) are read exactly; linear arithmetic is decided exactly, nonlinear may not finish |
| Word | `+ - * / mod` | modulo 2^n: for a `word[8]` equal to 255, x + 1 = 0 |
| Word | `& \| xor !` | bitwise; in a relation, parenthesize them: `(x & y) = 0` |
| Word | `<< >>` | shifts by a number (`>>` keeps the sign of a signed word) |
| Word | `x :: y` | concatenation, x on the high bits |
| Word | `x[7:4]`, `x[3]` | bits; a single bit can be used as a Boolean |
| Word | `extend(x, n)`, `signed(x)`, `unsigned(x)` | n more bits; the same bits read as signed or unsigned |

Both operands of an operation on words have the same width and signedness,
and an integer constant takes the type of the other operand: `x + 1` with
`x : word[8]` is a `word[8]`. A word does not go with an integer variable;
make both words. A formula that does not type is refused when
the contract is built, with the reason.

## Precedence

From the loosest to the tightest: `<->`, `->`, `|` `xor`, `&`, `U R W`, the
unary operators (`! G F X`), the relations, `<< >>`, `+ -`, `* / mod`, `::`,
the bits `x[7:0]`. `->` and `U R W` group to the right, the other binary
operators to the left. So `G a -> b` is `(G a) -> b`; write `G (a -> b)`.
This is the precedence of LTL tools such as Spot, NuSMV, and nuXmv, and of
the logics language.

## What takes which formulas

| | Checks (nuXmv) | Contract algebra | GR(1) synthesis (slugs) | Logics language |
|---|---|---|---|---|
| Booleans, integers | yes | yes | yes, in the GR(1) fragment | yes |
| Reals | yes | yes | real variables compared with constants | yes |
| Words | yes | yes | no | no |
| `past(x, n)` | yes | yes | no | no |

The checks are exact for Booleans, integers, and words. For reals, the
[checks](checks.md#real-variables) say how they are decided. Reals and words
are not checked in the same formula. GR(1)
synthesis needs [formulas in the GR(1) fragment](../tools/synthesis.md).

## SystemVerilog Assertions

`parse_sva` reads the `assume property` and `assert property` statements of
SystemVerilog as the assumptions and the guarantees of a contract, and
`to_sva` writes a contract back as a checker module: see
[Hardware: SVA and RTL](../tools/systemverilog.md).
