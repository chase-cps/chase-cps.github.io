# AHB: two viewpoints of an arbiter

The arbiter of the AMBA AHB bus gives the bus to one of two masters, and a
master can lock the bus. The requirements are simplified from those of R.
Bloem et al., "Specify, Compile, Run: Hardware from PSL" (COCV 2007), a case
study of GR(1) synthesis: two masters, no bursts, and no HREADY. They are
written as two viewpoints of the same arbiter, in [SystemVerilog
Assertions](../interfaces/systemverilog.md), and the demo compares the two
ways to put them together: [merging and conjunction](../contracts/algebra.md#what-each-one-is-for).

```mermaid
flowchart LR
    M1["Master 1"] -- "hbusreq1, hlock1" --> A["Arbiter: Grant and Lock"]
    M2["Master 2"] -- "hbusreq2, hlock2" --> A
    A -- "hgrant1, hgrant2, hmastlock" --> B["Bus"]
```

## The contracts

- _Grant_ gives the bus to exactly one master, master 1 at the start, and no
  master waits forever. It assumes nothing.
- _Lock_: a master that has locked the bus keeps it while it asks for it. It
  assumes that a master asks for the bus when it asks for a locked access,
  and that a master that has locked the bus stops asking for it sooner or
  later.

## The steps

| Step | Operation | Result |
|---|---|---|
| 1. The viewpoints | `is_realizable` | _Grant_ and _Lock_ are each realizable |
| 2. The merge | `merge` with discharge, `synthesize`, `to_sva` | The merge keeps the terms of both viewpoints: _Arbiter_, which is realizable; slugs gives a controller, and _Arbiter_ is written as SVA |
| 3. The conjunction | `conjoin`, `refines` | The conjunction refines _Arbiter_; _Arbiter_ does not refine it |
| 4. The controller | `Model.from_controller`, `implements` | The controller implements _Arbiter_, not the conjunction |

The conjunction, (A1 | A2, G1 & G2), asks for each viewpoint on its own: no
master may wait forever even when a master keeps the bus locked and never
stops asking. The counterexample of step 4 is that case. No arbiter
implements the conjunction: it cannot tell from the past whether the master
will stop asking, so it would have to let it keep the bus and take the bus
from it. The merge, (A1 & A2, (G1 & G2) | !(A1 & A2)), is for viewpoints
that describe one component together: each viewpoint holds under the
assumptions of both.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license && chase-cps install slugs
$> python3 AHB/ahb.py
```

The directory also has the requirements (`requirements.txt`) and the
viewpoints in SVA (`sva/grant.sv`, `sva/lock.sv`, with the number of the
requirement as the label of each assertion).
