# <span class="tag l1">1</span> Contract algebra

The operations that build a contract from contracts. They hold for any
assume-guarantee contracts and are computed in closed form by the CHASE core
library, without a solver. In Python they are the methods of `Contract`; each
returns a new contract. The contracts are saturated: C1 = (A1, G1) and
C2 = (A2, G2).

| Operation | logics_tool | Python | chase-cps check | MCP tool |
|---|---|---|---|---|
| composition ∥ | `compose C1 C2 R` | `c1.compose(c2)` | `C1+C2` in a contract argument | `compose` |
| conjunction ∧ | `conjoin C1 C2 R` | `c1.conjoin(c2)` | | `conjoin` |
| disjunction ∨ | `disjoin C1 C2 R` | `c1.disjoin(c2)` | | `disjoin` |
| merging • | `merge C1 C2 R` | `c1.merge(c2)` | | `merge` |
| quotient / | `divide C1 C2 R` | `c1.divide(c2)` | | `divide` |
| separation ÷ | `separate C1 C2 R` | `c1.separate(c2)` | | `separate` |
| implication → | `imply C1 C2 R` | `c1.imply(c2)` | | `imply` |
| coimplication | `coimply C1 C2 R` | `c1.coimply(c2)` | | `coimply` |
| reciprocal C⁻¹ | `invert C R` | `c.invert()` | | `invert` |
| adding an assumption b·C | | `c.assume(b)` | | `assume` |
| adding a guarantee C·b | | `c.ensure(b)` | | `ensure` |
| saturation | `saturate C` | `c.saturate()` | | `saturate` |
| (formula simplification) | `simplify C` | `c.simplify()` | | `simplify` |

## Formulas

| Operation | Result (A, G) | Source |
|---|---|---|
| composition C1 ∥ C2 | <span class="f">((A1∧A2) ∨ ¬(G1∧G2), G1∧G2)</span> | Benveniste et al. 2018 |
| conjunction C1 ∧ C2 | <span class="f">(A1∨A2, G1∧G2)</span> | Benveniste et al. 2018 |
| disjunction C1 ∨ C2 | <span class="f">(A1∧A2, G1∨G2)</span> | Benveniste et al. 2018 |
| merging C1 • C2 | <span class="f">(A1∧A2, (G1∧G2) ∨ ¬(A1∧A2))</span> | Passerone et al., TECS 2019 |
| quotient C1 / C2 | <span class="f">(A1∧G2, (G1∧A2) ∨ ¬(A1∧G2))</span> | Incer et al., MEMOCODE 2018, Thm 3.5 |
| separation C1 ÷ C2 | <span class="f">((A1∧G2) ∨ ¬(G1∧A2), G1∧A2)</span> | Passerone et al., TECS 2019, Thm 3.12 |
| implication C1 → C2 | <span class="f">((A2∧¬A1) ∨ (G1∧¬G2), G2 ∨ ¬G1)</span> | Incer et al., arXiv 2309.08875, Prop 6 |
| coimplication | <span class="f">(A2 ∨ ¬A1, (G2∧¬G1) ∨ (A1∧¬A2))</span> | Incer et al., arXiv 2309.08875, Prop 7 |
| reciprocal C⁻¹ | <span class="f">(G, A)</span> | Incer et al., arXiv 2309.08875, Sec 2.1 |
| adding an assumption b·C | <span class="f">(b∧A, b → G)</span> | Incer et al., arXiv 2309.08875, Sec 4 |
| adding a guarantee C·b | <span class="f">(b → A, b∧G)</span> | Incer et al., arXiv 2309.08875, Sec 4 |
| saturation | <span class="f">(A, A → G)</span> | Benveniste et al. 2018 |

Implication and coimplication are the adjoints of conjunction and
disjunction, as the quotient and separation are of composition and merging
(Incer, Benveniste, Sangiovanni-Vincentelli, arXiv 2309.08875, Table 1).
`c1.imply(c2)` is the largest contract C such that C conjoined with c1
refines c2. The reciprocal (G, A) is the contract seen from its environment.
`c.assume(b)` gives (b & A, b -> G), an abstraction of c, and `c.ensure(b)`
gives (b -> A, b & G), which refines c.

`c1.compose(c2, discharge=True)` keeps the terms of the two contracts instead
of the closed form (Incer, PhD thesis 2022, Algorithm 2). When c1 drives the
inputs of c2 and not the reverse, the assumptions of c2 implied by the
assumptions and guarantees of c1 are dropped, then the redundant terms. This
variant is a simplification of the composition with the checks of
[layer 2](checks.md) (one implication per test), so it needs nuXmv. The result is an abstraction of the composition: a refinement proved
on it holds for the composition; a failed one may not.

The console also accepts the names of its first version: `conjunction` for
`conjoin`, `quotient` for `divide`, and `refinement` for `refines`. It has
`show C` to print a contract (`print(c)` in Python).

In the console, the variables of two contracts are matched by name (the
default), by a map entered by hand (`manual` as last argument), or by a map
read from a file (its name as last argument). In Python, variables with the
same name are the same variable, and `c.rename({...})` renames them.
