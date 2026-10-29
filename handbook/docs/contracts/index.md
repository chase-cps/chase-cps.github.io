# Contract theory

An assume-guarantee contract C = (A, G) states what a component assumes of
its environment (the assumptions A) and what it guarantees in return (the
guarantees G). A component is an implementation of C when it satisfies G in
every environment that satisfies A; an environment of C is one that
satisfies A. Contracts are composed, refined, and divided like the
components they describe, and the theory says how.

- [Formulas](formulas.md): in CHASE, the assumptions and the guarantees are
  formulas of linear temporal logic (LTL) over Boolean, integer, real, and
  bit-vector variables, written in Python, in the CHASE specification
  language, or in SystemVerilog Assertions.
- [Contract algebra](algebra.md): composition, conjunction, disjunction,
  merging, quotient, separation, implication, and the other operations that
  build a contract from contracts. They hold for any assume-guarantee
  contracts.
- [Contract-based verification](checks.md): refinement, compatibility,
  consistency, implementations, and environments. They are defined on
  behaviors; for contracts in LTL, CHASE reduces each one to the validity or
  the satisfiability of a formula, which a model checker decides.

For contracts in the GR(1) fragment of LTL, [GR(1) synthesis](synthesis.md)
asks whether a component can be synthesized from its contract.
