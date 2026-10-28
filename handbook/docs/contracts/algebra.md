# 1. Contract algebra

The operations that build a contract from contracts. They hold for any
assume-guarantee contracts, and the CHASE core library computes them in
closed form, without a solver. In Python they are methods of `Contract`, and
each one returns a new contract.

## Assume-guarantee contracts

A contract C = (A, G) describes a component by what it **assumes** of its
environment (A) and what it **guarantees** when the assumptions hold (G). In
CHASE, A and G are LTL formulas over the variables of the component: the
inputs are set by the environment, the outputs by the component. The contract
allows the behaviors of A → G, and (A, A → G) is its **saturated** form, with
the same behaviors; CHASE reads every contract saturated.

## The operations

C1 = (A1, G1) and C2 = (A2, G2) are saturated contracts.

| Operation | Result (A, G) | Python |
|---|---|---|
| composition C1 ∥ C2 | <span class="f">((A1∧A2) ∨ ¬(G1∧G2), G1∧G2)</span> | `c1.compose(c2)` |
| conjunction C1 ∧ C2 | <span class="f">(A1∨A2, G1∧G2)</span> | `c1.conjoin(c2)` |
| disjunction C1 ∨ C2 | <span class="f">(A1∧A2, G1∨G2)</span> | `c1.disjoin(c2)` |
| merging C1 • C2 | <span class="f">(A1∧A2, (G1∧G2) ∨ ¬(A1∧A2))</span> | `c1.merge(c2)` |
| quotient C1 / C2 | <span class="f">(A1∧G2, (G1∧A2) ∨ ¬(A1∧G2))</span> | `c1.divide(c2)` |
| separation C1 ÷ C2 | <span class="f">((A1∧G2) ∨ ¬(G1∧A2), G1∧A2)</span> | `c1.separate(c2)` |
| implication C1 → C2 | <span class="f">((A2∧¬A1) ∨ (G1∧¬G2), G2 ∨ ¬G1)</span> | `c1.imply(c2)` |
| coimplication | <span class="f">(A2 ∨ ¬A1, (G2∧¬G1) ∨ (A1∧¬A2))</span> | `c1.coimply(c2)` |
| reciprocal C⁻¹ | <span class="f">(G, A)</span> | `c.invert()` |
| adding an assumption b·C | <span class="f">(b∧A, b → G)</span> | `c.assume(b)` |
| adding a guarantee C·b | <span class="f">(b → A, b∧G)</span> | `c.ensure(b)` |
| saturation | <span class="f">(A, A → G)</span> | `c.saturate()` |
| simplification | the same contract, with simpler formulas | `c.simplify()` |

The same operations are commands of the [console](../interfaces/logics-tool.md)
and tools of the [MCP server](../interfaces/mcp.md), with the same names.

## What each one is for

**Putting components together**

- **Composition**: the contract of two components connected together;
  variables with the same name are connected.
- **Conjunction**: one component that meets two specifications at once (the
  greatest lower bound).
- **Merging**: two viewpoints of the same component, such as its function and
  its timing.

**Finding a missing part**

- **Quotient**: the largest contract C of a missing component such that
  C2 ∥ C refines C1. Any component that refines C completes the design.
- **Separation**: the same for merging: the smallest C such that C1 refines
  C2 • C.

**Reasoning about specifications**

- **Implication** C1 → C2: the largest C such that C ∧ C1 refines C2.
- **Disjunction** and **coimplication**: the least upper bound, and its
  adjoint.

**Changing one contract**

- **Reciprocal**: the contract seen from its environment; the inputs become
  outputs and the outputs inputs.
- **Adding an assumption** gives an abstraction of the contract;
  **adding a guarantee** gives a refinement of it.
- **Saturation** and **simplification** give an equivalent contract.

## Example: the contract of a missing component

The system must grant every request; a queue forwards each request as `fwd`.
What must the server between `fwd` and `grant` do?

```python
from chase_cps import Contract, refines

system = Contract.from_strings(inputs=["req"], outputs=["grant"], name="System",
                               assumptions=["G F !req"],
                               guarantees=["G (req -> F grant)"])
queue = Contract.from_strings(inputs=["req"], outputs=["fwd"], name="Queue",
                              guarantees=["G (req -> X fwd)"])

missing = system.divide(queue)       # the quotient
server = Contract.from_strings(inputs=["fwd"], outputs=["grant"], name="Server",
                               guarantees=["G (fwd -> X grant)"])
lazy = Contract.from_strings(inputs=["fwd"], outputs=["grant"], name="Lazy",
                             guarantees=["G (fwd -> F grant) | F G !grant"])
print(refines(server, missing).status, refines(lazy, missing).status)
```

```
valid invalid
```

The server that answers each `fwd` at the next step can fill the gap; the lazy
one, which may stop answering, cannot. The two refinement checks are
[layer 2](checks.md).

## Composition with discharge

`c1.compose(c2, discharge=True)` is a simplification of the composition. The
closed form puts all the terms of the two contracts into one large formula;
with discharge the result keeps each term, and drops the assumptions of one
contract that the other one guarantees (Incer, PhD thesis 2022, Algorithm 2):

- when c1 drives the inputs of c2, and not the reverse, the assumptions of c2
  implied by the assumptions and guarantees of c1 are dropped;
- when the two feed each other, the discharge goes in one direction only, the
  one that drops more assumptions;
- then the terms implied by the others are dropped.

!!! note "This variant uses layer 2"
    Each drop is decided by an implication check with nuXmv. The result is an
    abstraction of the composition: a refinement proved on it holds for the
    composition, one that fails on it may still hold. The
    [Charger demo](../demos/charger.md) uses it.

## Merging and quotient with discharge

`c1.merge(c2, discharge=True)` and `c1.divide(c2, discharge=True)` keep the
terms too, and here the result is the same contract as the closed form:

- the merge is (A1 ∧ A2, G1 ∧ G2), whose saturation is the merge;
- the quotient assumes A1 and the guarantees of c2, and guarantees G1 and
  the assumptions of c2. The assumptions of c2 implied by A1 are discharged
  first; when some are left (A2'), each guarantee g of c2 is assumed as
  A2' → g;
- then the terms implied by the others are dropped.

The closed forms are rarely GR(1), the terms often are: use these before
`is_realizable` and `synthesize`. The [AHB demo](../demos/ahb.md) merges
two viewpoints, and the [BufferSwap demo](../demos/buffer-swap.md) divides
the system by the neighbours of a buffer. Conjunction, disjunction, and
separation have no such form: their assumption or guarantee is a
disjunction.

Pacti computes the quotient of polyhedral terms the same way when A1 implies
A2. Otherwise it assumes A1 alone, since A2 → g is not a polyhedron: the
result refines the quotient, so it is correct but smaller.

## Sources

- Composition, conjunction, disjunction, saturation: Benveniste et al.,
  *Contracts for System Design*, Foundations and Trends in EDA, 2018.
- Quotient: Incer, Benveniste, Sangiovanni-Vincentelli, Seshia, MEMOCODE 2018,
  Theorem 3.5.
- Merging and separation: Passerone, Incer, Sangiovanni-Vincentelli, ACM TECS
  2019, Theorem 3.12.
- Implication, coimplication, reciprocal, adding an assumption or a guarantee:
  Incer, Benveniste, Sangiovanni-Vincentelli, *Some algebraic aspects of
  assume-guarantee reasoning*, arXiv 2309.08875.
