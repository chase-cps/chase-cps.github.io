# <span class="tag l3">3</span> GR(1) synthesis

| Analysis | logics_tool | Python | chase-cps check | MCP tool |
|---|---|---|---|---|
| realizability | | `is_realizable(c)` | `--realizable C` | `is_realizable` |
| synthesis | `synthesize C file solver` | `synthesize(c)` | `--synthesize C` | `synthesize` |
| unrealizable core | | `unrealizable_core(c)` | `--realizable C --core` | `unrealizable_core` |
| well-separation | | `is_well_separated(c)` | `--well-separated C` | `is_well_separated` |
| vacuity | | `remove_vacuous(c)` | | `remove_vacuous` |

These analyses are about reactive synthesis from contracts in the GR(1)
fragment of LTL, with slugs, in `chase_cps.gr1`. A contract is realizable
when a component that controls the outputs can satisfy A -> G against every
environment that controls the inputs; this depends on the synthesis
approach, and is not a property of contracts in general. The terms must be
GR(1): initial (no temporal operator), safety (G f, with X only in f), or
justice (G F f). The checks do not take a context: whether a formula
constrains the environment or the component is a question of roles, which a
context does not say.

`is_realizable` gives the counter-strategy of the environment when the
contract is unrealizable; `synthesize` also builds the controller. The
console writes the input file of slugs or gr1c, which decide realizability
and build the controller.

## Unrealizable cores

`unrealizable_core(c)` gives a minimal set of guarantees that is
unrealizable under all the assumptions. The search minimizes the justice
guarantees, then the safety, then the initial ones (QuickCore, Maoz and
Shalom, ICSE 2021), with one call to slugs per test.
`unrealizable_core(guarantees, inputs, outputs, assumptions)` takes formulas
and returns formulas, and `is_realizable(c, core=True)` gives the core of an
unrealizable result.

## Well-separation

A contract is well-separated when the component cannot satisfy it by
forcing the environment to violate the assumptions (Klein and Pnueli, HVC
2010; Maoz and Ringert, FSE 2016). A contract that is not well-separated is
realizable for a bad reason: the controller may break its environment
instead of meeting the guarantees. `is_well_separated(c)` answers
`separated` or `not_separated` with the `controller` that forces the
violation; `with_guarantees=True` makes the component keep its initial and
safety guarantees (Def. 4 of Maoz and Ringert), and `core=True` gives a
minimal set of assumptions that causes the problem. The check is one call
to slugs. It detects the violations that can be forced from every initial
state; those forced only from some reachable state need the winning region,
which slugs does not give.

## Vacuity

`remove_vacuous(c)` removes the terms whose removal does not change the
GR(1) specification: its realizability and the controllers that realize it
(inherent vacuity, Maoz and Shalom, ESEC/FSE 2020). Each term is checked
against a premise set that depends on its kind (initial, safety, justice)
and on its side (assumption or guarantee), one call to nuXmv per term; a
safety term is compared with the bodies of the other safety terms only, as
a propositional implication over the current and next values. The terms are
checked in order against the terms not yet removed, so of two equal terms
one is kept. The result has the `contract`, the `removed` terms with their
part and kind, and with `core=True` the terms that make each one vacuous.

`remove_redundant(c)` (layer 2) instead keeps A -> G: it may remove a term
that only follows from the others over whole traces, which can change the
synthesis problem; `remove_vacuous` does not.
