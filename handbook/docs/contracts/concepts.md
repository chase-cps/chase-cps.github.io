# Assume-guarantee contracts

A contract C = (A, G) describes a component by what it assumes of its
environment (A) and what it guarantees when the assumptions hold (G). In
CHASE, A and G are LTL formulas over the variables of the component:

- the **inputs** are controlled by the environment;
- the **outputs** are controlled by the component.

A behavior is an infinite sequence of states, each one a value of every
variable. The contract allows the behaviors of A → G: those where the
environment violates the assumptions, or the component keeps its guarantees.
The pair (A, A → G) is the **saturated** form of the contract, with the same
behaviors; CHASE reads every contract saturated (Benveniste et al., 2018).

## Refinement

C1 **refines** C2 (C1 ⪯ C2) when C1 can replace C2 in any context: it
assumes less and guarantees more,

- A2 → A1 is valid, and
- (A1 → G1) → (A2 → G2) is valid.

A refinement check that fails says which of the two fails, and gives a
behavior that violates it.

## Compatibility, consistency, implementation

- A contract is **compatible** when some environment satisfies A.
- It is **consistent** when some behavior satisfies A → G.
- A component M **implements** the contract (M satisfies C) when M ∧ A → G
  is valid, M being an LTL formula that describes its behaviors.

The satisfaction of a contract by a component is the last one,
`implements`. It is not the satisfiability of a formula, which asks whether
some behavior satisfies it (`is_satisfiable`).

## The three layers of CHASE

The operations of CHASE are grouped by what they need:

| Layer | What it needs | Examples |
|---|---|---|
| <span class="tag l1">1</span> [Contract algebra](algebra.md) | only the contracts: closed-form formulas | composition, conjunction, quotient |
| <span class="tag l2">2</span> [Checks](checks.md) | a decision procedure for the formulas of a theory | refinement, consistency, cores |
| <span class="tag l3">3</span> [GR(1) synthesis](synthesis.md) | a synthesis approach: GR(1) with slugs | realizability, controllers, well-separation |

The contract algebra holds for any assume-guarantee contracts. The checks
depend on the theory of the formulas, here LTL over Boolean, integer, and
real variables decided by nuXmv. Realizability depends on the synthesis
approach: it is a property of a contract read as a GR(1) game, not of
contracts in general.
