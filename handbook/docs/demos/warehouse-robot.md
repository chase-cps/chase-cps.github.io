---
wide: true
---

# Warehouse robot: a controller to delegate

**The question.** The local controller of a warehouse robot is given to a
designer while perception and localization stay as they are. What must the controller satisfy for the robot to meet
the requirements of the system?

[![The place of the controller: the hole Q next to perception and localization](../assets/diagram-warehouse-robot-system.png)](../assets/diagram-warehouse-robot-system.png)
_The place of the controller: the hole Q next to perception and localization._

The example is simplified from Damera, Matheu, and Baras, "Contract-Based
Agentic Systems Engineering: Delegation as Quotient for Assured System
Design" (arXiv 2610.33349, 2026). The robot keeps 0.40 m from a worker, and
rests (`rest`) at a dock. The variables are real numbers:

- `w`: the yaw rate, commanded by the controller;
- `c_true` and `c_rep`: the clearance to the worker, and the clearance that
  perception reports (at most 0.3 too high);
- `e_true` and `e_est`: the distance to the dock, and the distance that
  localization reports (at most 0.05 too low). The robot rests when
  `e_true <= 0.1`.

The controller sees only the reported values. Perception bounds its error
only if the robot turns slowly (`|w| <= 0.8`), and localization only if
`|w| <= 1.0`. The composition of perception and localization is called
_Fixed_ in the diagrams.

## The steps

**Step 1. The contract of the controller.** The quotient Q = System /
(Perception ∥ Localization), drawn as a dashed box, is the weakest contract
of the controller with which the robot meets the requirements: the contract
to give to the designer. It guarantees the requirements of the system, and
what perception assumes of the controller: `|w| <= 0.8`.

**Step 2. The requirements of the mission.** _MissionOnly_, the
requirements written on what the controller sees, does not refine Q: in the
counterexample the reported clearance is 0.40 while the true one is
lower, and the robot turns faster than perception allows.

[![Step 2: MissionOnly does not refine Q](../assets/diagram-warehouse-robot-1.png)](../assets/diagram-warehouse-robot-1.png)
_Step 2: MissionOnly does not refine Q._

**Step 3. With margins for the errors.** _Margins_ adds the errors of
perception and localization to the bounds, and does not refine Q either: it
turns faster than perception allows, and the robot reaches the worker.

[![Step 3: Margins does not refine Q](../assets/diagram-warehouse-robot-2.png)](../assets/diagram-warehouse-robot-2.png)
_Step 3: Margins does not refine Q._

**Step 4. With the yaw rate.** _Dispatched_, the contract given to the
designer, is _Margins_ with `|w| <= 0.8`. It refines Q, so the robot with
it meets the requirements of the system.

[![Step 4: Dispatched refines Q](../assets/diagram-warehouse-robot-3.png)](../assets/diagram-warehouse-robot-3.png)
_Step 4: Dispatched refines Q._

The paper finds the same two failures in simulation.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license
$> python3 WarehouseRobot/warehouse.py
```

The script prints the result of each step, with the counterexamples, and
writes the diagrams above in `WarehouseRobot/out/warehouse.html`. The contracts in words
are in `WarehouseRobot/requirements.txt`.
