# Getting started

This page installs CHASE in two commands, checks a first specification from
the command line, then writes the same contracts in Python. Other ways to
install CHASE (the sources, the optional tools) are on the<!-- DOCKER (restore when the image is public): "(Docker, the sources, the optional tools)" -->
[Installation](installation.md) page.

## Install

```
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license
$> chase-cps doctor
```

The first command installs the Python package and the `chase-cps` command
(Linux and macOS, Python 3.10 or later). The checks call the model checker
nuXmv, which the second command downloads into `~/.chase`; nuXmv is free for
academic and non-commercial use only (see [Installation](installation.md)
otherwise). `chase-cps doctor` lists the tools found and how to install the
others.

## A first check

A specification file holds contracts: here a system that answers every
request, and two components, a queue that forwards each request and a server
that answers it.

```
NAME: first;

CONTRACT System:
    input boolean variable req;
    output boolean variable grant;
    Assumptions:
        G(F(!(req)));
    Guarantees:
        G(req -> F(grant));

CONTRACT Queue:
    input boolean variable req;
    output boolean variable fwd;
    Guarantees:
        G(req -> X(fwd));

CONTRACT Server:
    input boolean variable fwd;
    output boolean variable grant;
    Guarantees:
        G(fwd -> X(grant));
```

Saved as `first.ltl`, it is checked with:

```
$> chase-cps check first.ltl --refines Queue+Server System
refines     Queue+Server <= System                   valid           0.03 s
```

The queue and the server, composed, refine the system: together they do what
the system must do. `chase-cps view first.ltl --check` draws the same file as
a web page, `first.html`, with the result on the boxes
([Diagrams](interfaces/diagrams.md)). The [command line](interfaces/command-line.md)
page has the other checks, and the [specification files](interfaces/logics-tool.md)
page the language.

## The same in Python

The same contracts in Python: their composition, a counterexample, and
requirements in conflict.

### The contracts

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

### Composition and refinement

Variables with the same name are connected: the output `fwd` of the queue is
the input of the server. The composition is computed in closed form by the
core library ([contract algebra](contracts/algebra.md)); the refinement is
checked by nuXmv ([contract-based verification](contracts/checks.md)).

```python
both = queue.compose(server)
print(refines(both, system).status)
```

```
valid
```

### A counterexample

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
  0: req=True, fwd=False, grant=True
  1: req=True, fwd=True, grant=False
  2: req=False, fwd=True, grant=False
  3: req=False, fwd=True, grant=False  <- loop starts
```

The guarantees fail. The request at step 1 is never granted: `grant` stays
false from step 1 on. The lazy server allows it (`F G !grant`), and the
system forbids it. A trace is a prefix followed by a loop repeated forever.
Another engine of nuXmv may give another trace.

### Requirements in conflict

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

`verify` checks that the assumptions and the guarantees can hold together
(A ∧ G satisfiable), which implies compatibility and consistency; here the
guarantees cannot hold together. `unsat_core` gives a minimal set of terms that cannot hold
together: removing any of them makes the rest satisfiable.

## Next

- The [demos](demos/index.md): CHASE on aircraft, hardware, C code, drones,
  and AI agents.
- The [contract algebra](contracts/algebra.md), the [checks](contracts/checks.md),
  and [GR(1) synthesis](tools/synthesis.md).
- The same operations from a [specification file](interfaces/logics-tool.md)
  with the [command line](interfaces/command-line.md), or from an AI agent
  with the [MCP server](interfaces/mcp.md).
