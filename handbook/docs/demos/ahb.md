---
wide: true
---

# AMBA AHB bus arbiter: two viewpoints that cannot be merged, and the assumption that fixes them

**The question.** Two teams wrote two viewpoints of the arbiter of the AMBA
AHB bus: how the bus is given to the masters, and how a master locks it. Is
there an arbiter that meets both, and what must it assume of the masters?

**The result.**

- Each viewpoint is realizable, but their merge is not: the unrealizable
  core (the smallest set of requirements in conflict) is 5 of its 7
  guarantees.
- The core points to the missing assumption LA2. With it, the merge is
  realizable, and slugs synthesizes a controller of 81 states.
- The controller implements the merge (M ⊨ C).

[![Arbiter, the merge of Grant and Lock, realizable; the merge without LA2, unrealizable, with its core in red; and the controller](../assets/demos/ahb/overview-arbiter.png){ width="757" }](../assets/demos/ahb/overview-arbiter.png)
_The merge with LA2 (R green), the merge without it (R red, its core in red), and the controller (M ⊨ C)._

The arbiter gives the bus to one of two masters (simplified from Bloem et
al., "Specify, Compile, Run: Hardware from PSL", COCV 2007). _Grant_ gives
the bus to exactly one master, and no master waits forever. _Lock_ lets a
master that has locked the bus keep it while it asks for it. Merging (•)
puts together two viewpoints of one component.

## The steps

**Step 1. Each viewpoint.** _Grant_ and _Lock_, read from the
SystemVerilog Assertions (SVA) of `sva/`, are each realizable.

[![Step 1: Grant and Lock, open inside Arbiter, each realizable](../assets/demos/ahb/step1-viewpoints.png){ width="508" }](../assets/demos/ahb/step1-viewpoints.png)
_Step 1: Grant and Lock, each realizable (R)._

**Step 2. The merge without LA2.** Without LA2, the merge is unrealizable.
When master 1 locks the bus and keeps asking for it, _Lock_ lets it keep
the bus (LK2.1), and _Grant_ says that master 2 does not wait forever
(GR3.2). GR1, GR2, and LK1 complete the core.

[![Step 2: the merge without LA2 is unrealizable; the core in red, and the panel of the check](../assets/demos/ahb/step2-merge-core.png)](../assets/demos/ahb/step2-merge-core.png)
_Step 2: the merge without LA2 is unrealizable; the terms of the core are red._

**Step 3. What the arbiter must assume.** LA2: a master that has locked
the bus stops asking for it sooner or later. With LA2 in _Lock_, the merge
_Arbiter_ is realizable, and slugs synthesizes a controller. _Arbiter_ is
also written as SVA in `out/arbiter.sv`.

[![Step 3: Arbiter, the merge with LA2, open: its assumptions and guarantees, realizable](../assets/demos/ahb/step3-arbiter.png){ width="465" }](../assets/demos/ahb/step3-arbiter.png)
_Step 3: Arbiter, the merge with LA2, is realizable._

**Step 4. The controller.** The controller, read as a state machine,
implements _Arbiter_ (M ⊨ C).

[![Step 4: Arbiter and the synthesized controller, which implements it](../assets/demos/ahb/step4-controller.png){ width="268" }](../assets/demos/ahb/step4-controller.png)
_Step 4: the controller implements Arbiter (M ⊨ C)._

## Run it

```
pip install chase-cps
chase-cps install nuxmv --accept-license
chase-cps install slugs
python ahb.py --expect
```

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/AHB); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
