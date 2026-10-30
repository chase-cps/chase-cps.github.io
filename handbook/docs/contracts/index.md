# Contract theory

An assume-guarantee contract specifies a component by what it assumes of its
environment and what it guarantees in return. The theory of contracts says
how such specifications are composed, compared, and divided, independently
of the logic in which they are written; CHASE writes them in linear temporal
logic.

<figure>
<svg viewBox="0 0 640 230" width="640" role="img" aria-label="A component M and its environment E. The environment drives the inputs x and reads the outputs y. The contract C = (A, G) assumes A of the environment and guarantees G for the component." style="max-width:100%;height:auto">
  <defs>
    <marker id="ct-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,1 L9,5 L0,9 z" fill="#17393b"/>
    </marker>
  </defs>
  <rect x="20" y="70" width="170" height="90" rx="8" fill="#f4f6f6" stroke="#8a9999" stroke-width="1.5"/>
  <text x="105" y="110" text-anchor="middle" font-size="17" font-weight="700" fill="#1f2728">Environment E</text>
  <text x="105" y="134" text-anchor="middle" font-size="14" fill="#586566">sets the inputs</text>
  <rect x="330" y="20" width="290" height="190" rx="12" fill="none" stroke="#17393b" stroke-width="1.5" stroke-dasharray="6 5"/>
  <text x="475" y="44" text-anchor="middle" font-size="15" font-weight="700" fill="#17393b">Contract C = (A, G)</text>
  <rect x="390" y="70" width="170" height="90" rx="8" fill="#e8efef" stroke="#17393b" stroke-width="1.5"/>
  <text x="475" y="110" text-anchor="middle" font-size="17" font-weight="700" fill="#1f2728">Component M</text>
  <text x="475" y="134" text-anchor="middle" font-size="14" fill="#586566">sets the outputs</text>
  <path d="M190,95 L388,95" stroke="#17393b" stroke-width="1.6" fill="none" marker-end="url(#ct-arrow)"/>
  <text x="290" y="87" text-anchor="middle" font-size="15" font-style="italic" fill="#1f2728">inputs x</text>
  <path d="M390,135 L192,135" stroke="#17393b" stroke-width="1.6" fill="none" marker-end="url(#ct-arrow)"/>
  <text x="290" y="153" text-anchor="middle" font-size="15" font-style="italic" fill="#1f2728">outputs y</text>
  <text x="475" y="186" text-anchor="middle" font-size="14" fill="#1f2728">assumes A of the environment,</text>
  <text x="475" y="204" text-anchor="middle" font-size="14" fill="#1f2728">guarantees G when A holds</text>
</svg>
<figcaption>A component and its environment. The contract assumes A of the
behaviors of the environment, and guarantees G for the behaviors of the
component when A holds.</figcaption>
</figure>

## Contracts and behaviors

A behavior is a sequence of values of the variables, the inputs x and the
outputs y. A formula denotes a set of behaviors. A contract C = (A, G) is a
pair of such sets: the assumptions A and the guarantees G. Two contracts with
the same A and the same A → G (the *saturated* guarantees) have the same
implementations and environments, so CHASE treats them as equal.

| Notion | Holds when | Meaning |
|---|---|---|
| M is an implementation of C (M ⊨<sub>M</sub> C) | M ∧ A → G | in every environment that satisfies A, M satisfies G |
| E is an environment of C (E ⊨<sub>E</sub> C) | E → A | E behaves as the contract assumes |
| C is compatible | A is satisfiable | C has an environment |
| C is consistent | A → G is satisfiable | C has an implementation |
| C1 refines C2 (C1 ⪯ C2) | A2 → A1 and (A1 → G1) → (A2 → G2) | C1 can replace C2: it assumes less and guarantees more |

Refinement is what makes design by contracts compositional: if C1 refines
C2, every implementation of C1 is an implementation of C2, and every
environment of C2 is an environment of C1. A component designed for C1 can
take the place of one designed for C2, without looking at the rest of the
system.

## Building contracts from contracts

The composition C1 ∥ C2 is the contract of two components placed side by
side, with the variables of the same name connected: it guarantees G1 ∧ G2,
under the assumptions that the environment meets both A1 and A2, unless the
components themselves violate them. If M1 implements C1 and M2 implements
C2, then M1 ∥ M2 implements C1 ∥ C2. The other operations answer other
design questions:

- The quotient C / C1: what must the missing component of a system satisfy?
- The conjunction C1 ∧ C2: what satisfies two specifications at once?
- The merging C1 • C2: what are two viewpoints of the same component,
  together?
- The separation, the implication, and the coimplication are the adjoints
  of merging, conjunction, and disjunction.

[Contract algebra](algebra.md) gives their definitions and sources.

## In CHASE

- [Formulas](formulas.md): the assumptions and the guarantees are formulas
  of linear temporal logic over Boolean, integer, real, and bit-vector
  variables, written in Python, in the CHASE specification language, or in
  SystemVerilog Assertions.
- [Contract algebra](algebra.md): the operations, computed in closed form or
  keeping the terms of the contracts.
- [Contract-based verification](checks.md): the notions of the table above,
  each reduced to the validity or the satisfiability of a formula, which a
  model checker decides, with counterexamples and cores.

For contracts in the GR(1) fragment of LTL, [GR(1) synthesis](../tools/synthesis.md)
asks whether a component can be synthesized from its contract.
