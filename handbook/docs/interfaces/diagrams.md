# Diagrams

CHASE draws contracts, components, and systems as a web page, with the
results of the checks on the boxes. The page opens in a browser and works
offline with a local copy of ELK, the layout library.

[![A quotient, drawn as a dashed box, with the part that refines it inside](../assets/demos/payment-assistant/quotient-q3-text-refines.png)](../assets/demos/payment-assistant/quotient-q3-text-refines.png)
_A quotient, drawn as a dashed box, with the part that refines it inside ([Payment assistant agent](../demos/payment-assistant.md))._

## What is drawn

- A rounded box is a contract; a square box also has a model: RTL read
  with Yosys, a state machine in JSON or SMV, or a controller synthesized
  by slugs. A model with few states opens on its state graph.
- A box drawn inside another is checked against it, on as many levels as
  there are refinements: the ⪯ tag says whether it refines it. The button
  at the top right of a box folds what is inside.
- Inside an open box, the dark A and G mark its assumptions and its
  guarantees.
- The note under a name says how the contract is built: ⊗ composition,
  ∧ conjunction, • merging (viewpoints of one component), / quotient.
- A dashed box is a quotient (the missing part, ? in the note), with the
  part checked against it inside.
- An environment is a grey box on the left of what it drives.
- The tags are the results of the checks, green when the check holds and
  red when it does not: ⪯ refinement, A compatible, G consistent, A∧G
  feasible, R realizable, WS well separated, ¬V not vacuous, M ⊨ C the
  model implements the contract, E ⊨ A the environment meets the
  assumptions. A click on a red tag highlights its core in red.
- A term of a specification file shows its line when the pointer rests on
  it.

Drag to move the diagram, and use the wheel (or a pinch) to zoom; the key 0
fits it to the window. A box keeps its row when a box is opened. The button
with an arrow saves the whole diagram as SVG, PNG, or PDF.

## Python

```python
from chase_cps import Component, Contract, System, refines, viz

a = Contract.from_strings(name="A", inputs=["x"], outputs=["y"],
                          guarantees=["G (x -> X y)"])
b = Contract.from_strings(name="B", inputs=["y"], outputs=["z"],
                          guarantees=["G (y -> z)"])
top = Contract.from_strings(name="Top", inputs=["x"], outputs=["y", "z"],
                            guarantees=["G (x -> X z)"])
s = System("S", [Component("a", a), Component("b", b)], contract=top)
s.check()                          # the composition against Top
q = top.divide(a, name="Q")        # what the part next to a must do
refines(b, q)                      # the result is kept on b
d = viz.diagram(s, q, refines=[(b, q)], open=[q])
viz.save(d, "plan.html")           # viz.show(d) opens a browser
```

The options of `viz.diagram`:

- `refines` lists the pairs (R, A) where R is drawn inside A.
- `environments` lists the environments, each with what it drives.
- `open` lists the boxes drawn open when the page loads.
- `checks` lists results of checks to draw. It is usually not needed: each
  check keeps its result on the contract it checks, and the diagram draws
  the results of the contracts that have not changed since.

In Jupyter, a system or a contract draws itself.

## Command line, MCP, and VS Code

- Command line: `chase-cps view FILE` draws a specification file, or a
  Verilog module. Its options are listed in
  [Command line](command-line.md#drawing-a-specification).
- MCP: the `visualize` tool of the [MCP server](mcp.md) draws the same
  diagrams for an AI agent.
- VS Code: an extension, not released yet, shows the diagram beside the
  editor:
    - the diagram is drawn again as you type, without the checks; the
      checks run when the file is saved;
    - the errors are marked in the text;
    - a double click on a box, or on a term, goes to its line in the file;
    - the cursor marks its box, and its term, in the diagram.
