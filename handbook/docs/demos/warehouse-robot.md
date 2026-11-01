---
wide: true
---

# Warehouse robot: the contract of a controller to delegate

**The question.** The local controller of a warehouse robot is given to a
designer; perception and localization stay as they are. What must the
controller satisfy for the robot to meet its requirements?

**The result.**

- The quotient Q (the weakest contract the controller must meet) asks for
  the requirements of the system and one more term: `|w| <= 0.8`, what
  perception assumes.
- The requirements written for the mission alone do not refine Q, nor do
  they with margins for the errors: in each counterexample the robot turns
  faster than perception allows.
- The margins with this bound on the yaw rate refine Q: this is the
  contract to give to the designer.

[![Three copies of the system, with MissionOnly (red), Margins (red), and Dispatched (green) inside Q](../assets/demos/warehouse-robot/overview-three-candidates.png)](../assets/demos/warehouse-robot/overview-three-candidates.png)
_The three candidate contracts of the controller, each in its place: two fail, one holds._

The example is simplified from Damera, Matheu, and Baras, "Contract-Based
Agentic Systems Engineering: Delegation as Quotient for Assured System
Design" (arXiv 2610.33349, 2026). The variables are real numbers (the SMT
engine of nuXmv):

- `w`: the yaw rate, commanded by the controller;
- `c_true`, `c_rep`: the clearance to a worker, true and reported by
  perception;
- `e_true`, `e_est`: the distance to the dock, true and estimated by
  localization.

The controller sees only `c_rep` and `e_est`. In the diagrams, _Fixed_ is
perception composed with localization.

## The steps

**Step 1. The contract of the controller.** Q = SafeMission / (Perception ⊗
Localization), drawn as a dashed box, guarantees the requirements of the
system (`c_true >= 0.4`, and a rest at the dock) and what perception
assumes: `|w| <= 0.8`.

[![Step 1: the system with perception, localization, and the dashed box Q open](../assets/demos/warehouse-robot/step1-quotient-q.png)](../assets/demos/warehouse-robot/step1-quotient-q.png)
_Step 1: Q, the place of the controller, next to perception and localization._

**Step 2. The requirements of the mission.** _MissionOnly_, the
requirements written on what the controller sees, does not refine Q: in
the counterexample the reported clearance is 0.4 while the true one is
0.1, and the robot turns faster than perception allows.

[![Step 2: MissionOnly inside Q, red, with the counterexample](../assets/demos/warehouse-robot/step2-missiononly-does-not-refine-q.png)](../assets/demos/warehouse-robot/step2-missiononly-does-not-refine-q.png)
_Step 2: <em>MissionOnly</em> does not refine Q; the counterexample on the wires._

**Step 3. With margins for the errors.** _Margins_ adds the errors of
perception and localization to the bounds, and does not refine Q either:
it turns at `|w| = 1.2`, and the robot reaches the worker.

[![Step 3: Margins inside Q, red, with the counterexample](../assets/demos/warehouse-robot/step3-margins-does-not-refine-q.png)](../assets/demos/warehouse-robot/step3-margins-does-not-refine-q.png)
_Step 3: <em>Margins</em> does not refine Q._

**Step 4. With the yaw rate.** _Dispatched_ is _Margins_ with the bound
of perception on `w`. It refines Q, so the robot with it meets the
requirements of the system. The paper finds the same two failures in
simulation.

[![Step 4: Dispatched inside Q, green](../assets/demos/warehouse-robot/step4-dispatched-refines-q.png)](../assets/demos/warehouse-robot/step4-dispatched-refines-q.png)
_Step 4: <em>Dispatched</em> refines Q._

## Run it

```
pip install chase-cps
chase-cps install nuxmv --accept-license
python warehouse.py --expect
```

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/WarehouseRobot); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
