# A first contract

This page writes a system contract and two component contracts, composes the
components, checks that they refine the system, reads a counterexample, and
finds requirements in conflict. It needs `pip install chase-cps` and nuXmv
(`chase-cps install nuxmv --accept-license`). The outputs below are those of
chase-cps 0.3.1.

## The contracts

A contract has inputs (controlled by the environment), outputs (controlled by
the component), assumptions on the environment, and guarantees of the
component, written in LTL.

```python
from chase_cps import Contract, refines, verify, unsat_core

# Every request is eventually granted, if requests stop infinitely often.
system = Contract.from_strings(
    inputs=["req"], outputs=["grant"], name="System",
    assumptions=["G F !req"],
    guarantees=["G (req -> F grant)"])

# A queue that forwards each request, and a server that answers it.
queue = Contract.from_strings(
    inputs=["req"], outputs=["fwd"], name="Queue",
    guarantees=["G (req -> X fwd)"])
server = Contract.from_strings(
    inputs=["fwd"], outputs=["grant"], name="Server",
    guarantees=["G (fwd -> X grant)"])
```

## Composition and refinement

Variables with the same name are connected: the output `fwd` of the queue is
the input of the server. The composition is computed in closed form by the
core library ([layer 1](../contracts/algebra.md)); the refinement is checked
by nuXmv ([layer 2](../contracts/checks.md)).

```python
both = queue.compose(server)
print(refines(both, system).status)
```

```
valid
```

## A counterexample

A server that may stop answering for good does not refine the system:

```python
lazy = Contract.from_strings(
    inputs=["fwd"], outputs=["grant"], name="Lazy",
    guarantees=["G (fwd -> F grant) | F G !grant"])
r = refines(queue.compose(lazy), system)
print(r.status, r.failed)
print(r.guarantees.trace)
```

```
invalid guarantees
  0: req=True, fwd=True, grant=False
  1: req=False, fwd=True, grant=False  <- loop starts
  2: req=False, fwd=True, grant=False
```

The guarantees fail: at step 0 there is a request, and `grant` stays false
forever in the loop, which the lazy server allows (`F G !grant`) and the
system forbids. A trace is a prefix followed by a loop repeated forever.

## Requirements in conflict

```python
bad = Contract.from_strings(
    inputs=["req"], outputs=["grant"], name="Bad",
    guarantees=["G (req -> X grant)", "G !grant", "F req"])
print(verify(bad).status)
print(unsat_core(bad).core)
```

```
unsat
CONTRACT Bad_core
  input req : bool
  output grant : bool
  Assumptions:
    true
  Guarantees:
    G (req -> X grant)
    G !grant
    F req
```

`verify` checks compatibility and consistency; here the guarantees cannot
hold together. `unsat_core` gives a minimal set of terms that cannot hold
together: removing any of them makes the rest satisfiable.

## Next

- The [contract algebra](../contracts/algebra.md), the [checks](../contracts/checks.md),
  and [GR(1) synthesis](../contracts/synthesis.md).
- The same operations from a [specification file](../interfaces/logics-tool.md)
  with the [command line](../interfaces/command-line.md), or from an AI agent
  with the [MCP server](../interfaces/mcp.md).
