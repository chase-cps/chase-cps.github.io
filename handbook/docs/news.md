# News

<div class="news-item" markdown>
<span class="news-date">October 28, 2026</span>

## CHASE 0.4.1: contracts for hardware

CHASE now reads and checks hardware designs:

- contracts are read from SystemVerilog Assertions and written back as a
  checker module, with a bind statement, for any tool that reads SVA
  ([SystemVerilog](interfaces/systemverilog.md));
- RTL in Verilog or SystemVerilog is read with Yosys as a state machine, and
  checked against contracts (`pip install chase-cps[rtl]`);
- merging and quotient keep the terms of the contracts, so their results go
  straight to realizability and synthesis;
- three demos: a buffer of BaseJump STL replaced by a smaller one, with the
  contract of its place proven on the RTL with Jasper
  ([BufferSwap](demos/buffer-swap.md)); the arbiter of the AMBA AHB bus as
  two viewpoints ([AHB](demos/ahb.md)); the state machine of the Lockheed
  Martin cyber-physical challenges ([LMFSM](demos/lm-fsm.md)).
</div>

<div class="news-item" markdown>
<span class="news-date">October 28, 2026</span>

## CHASE 0.4.0: bit vectors and engines

Words (unsigned and signed bit vectors, as in nuXmv and SystemVerilog), the
value of a variable n steps before (`past(x, n)`), and the choice of the
engine of nuXmv (IC3 and BDDs at the same time by default).
</div>

<div class="news-item" markdown>
<span class="news-date">October 27, 2026</span>

## CHASE 0.3: state machines and vacuity

Implementations and environments given as state machines (SMV, JSON, or a
synthesized controller), receptiveness, vacuity in GR(1) synthesis, and
well-separation that keeps the guarantees of the component. The operations
are organized in three levels: contract algebra, contract-based
verification, and GR(1) synthesis.
</div>

<div class="news-item" markdown>
<span class="news-date">October 26, 2026</span>

## CHASE 0.2: reals, cores, and discharge

Real variables, unsat and unrealizable cores, composition that keeps the
terms of the contracts and drops the assumptions discharged by the other
components, implication and coimplication of contracts, and well-separation.
</div>

<div class="news-item" markdown>
<span class="news-date">October 25, 2026</span>

## CHASE 0.1: a Python package and an MCP server

CHASE is on PyPI (`pip install chase-cps`), with its back ends installed by
`chase-cps install`, and its operations are available to AI agents through
an MCP server (`chase-mcp`).
</div>
