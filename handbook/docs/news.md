# News

<div class="news-item" markdown>
<span class="news-date">October 30, 2026</span>

## CHASE 0.5.0: diagrams

CHASE now draws contracts, components, and systems as a web page
([Diagrams](interfaces/diagrams.md)):

- a box drawn inside another is checked against it;
- a quotient is a dashed box, with the part checked against it inside;
- a model opens on its states;
- the results of the checks are tags on the boxes, and a failed check
  highlights its core;
- the diagrams are drawn by `chase_cps.viz` in Python, by `chase-cps view`
  for a specification file or a Verilog module, and by the `visualize` tool
  of the MCP server;
- each term drawn from a file knows its line, and the diagram is saved as
  SVG, PNG, or PDF.

Also in this version:

- every demo page shows each step with its diagram;
- the power system demos are read in Python with `load_dsl`
  ([Power systems](demos/date18.md));
- `to_gr1(c, format="slugs" | "gr1c")` writes a GR(1) contract for a solver
  that you run yourself ([GR(1) synthesis](tools/synthesis.md)).

Fixed:

- `R` (release) in a specification file;
- intervals such as `G[0,3]`, which were dropped when read, and lost by the
  operations of the console;
- negative constants in the operations of the C++ library;
- two crashes of the console.
</div>

<div class="news-item" markdown>
<span class="news-date">October 28, 2026</span>

## CHASE 0.4.2: names after the theory, and a Docker image

- `is_implementation(m, c)` and `is_environment(e, c)` are the new names of
  `implements` and `accepts`. The old names still work, with a warning.
- Conjunction can keep the terms of the contracts (`discharge=True`).
- The Docker image is published at each release, with NuSMV and Yosys:
  `docker pull ghcr.io/chase-cps/chase`.
</div>

<div class="news-item" markdown>
<span class="news-date">October 28, 2026</span>

## CHASE 0.4.1: contracts for hardware

CHASE now reads and checks hardware designs:

- contracts are read from SystemVerilog Assertions and written back as a
  checker module, with a bind statement, for any tool that reads SVA
  ([SystemVerilog](tools/systemverilog.md));
- RTL in Verilog or SystemVerilog is read with Yosys as a state machine, and
  checked against contracts (`pip install chase-cps[rtl]`);
- merging and quotient keep the terms of the contracts, so their results go
  straight to realizability and synthesis;
- three demos:
    - [BufferSwap](demos/buffer-swap.md): a buffer of BaseJump STL replaced
      by a smaller one, with the contract of its place proven on the RTL
      with Jasper;
    - [AHB](demos/ahb.md): the arbiter of the AMBA AHB bus as two
      viewpoints;
    - [LMFSM](demos/lm-fsm.md): the state machine of the Lockheed Martin
      cyber-physical challenges.
</div>

## Earlier versions

- October 28, 2026, **0.4.0**: bit vectors (words), `past(x, n)`, and the
  choice of the engine of nuXmv.
- October 27, 2026, **0.3**: implementations and environments as state
  machines, receptiveness, vacuity in GR(1) synthesis.
- October 26, 2026, **0.2**: real variables, unsat and unrealizable cores,
  composition with discharge.
- October 25, 2026, **0.1**: the Python package on PyPI and the MCP server.

Every change of each version is in the
[changelog](https://github.com/chase-cps/chase/blob/master/CHANGELOG.md).
