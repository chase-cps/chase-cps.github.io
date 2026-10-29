# Warehouse: the contract of a controller to delegate

**The question.** The local controller of a warehouse robot is given to a
designer, a person or a language model, while perception and localization
stay as they are. What must the controller satisfy for the robot to meet
the requirements of the system?

The example is simplified from S. S. Damera, R. Matheu, and J. S. Baras,
"Contract-Based Agentic Systems Engineering: Delegation as Quotient for
Assured System Design" (arXiv 2610.33349, 2026), with the bounds of the
paper. The robot crosses the floor, keeps 0.40 m from a worker, and rests at
a dock. The controller commands the yaw rate `w` and the rest; it sees the
clearance to the worker and the distance to the dock only as perception and
localization report them. All the variables but `rest` are real numbers.

```mermaid
flowchart LR
    E["Worker and floor"] -- "c_true, e_true" --> P["Perception"]
    E --> L["Localization"]
    P -- "c_rep" --> K["Controller (delegated)"]
    L -- "e_est" --> K
    K -- "w" --> P
    K -- "w" --> L
    K -- "rest" --> O["Dock"]
```

## The contracts

| Contract | Assumes | Guarantees |
|---|---|---|
| _Perception_ | `G (w <= 0.8 & w >= -0.8)`: the robot turns slowly enough for the camera and the lidar | `G (c_rep <= c_true + 0.3)` |
| _Localization_ | `G (w <= 1.0 & w >= -1.0)` | `G (e_true <= e_est + 0.05)` |
| _System_ | nothing | `G (c_true >= 0.4)`, `F (rest & e_true <= 0.1)` |
| _MissionOnly_ | nothing | `G (c_rep >= 0.4)`, `F (rest & e_est <= 0.1)` |
| _Margins_ | nothing | `G (c_rep >= 0.7)`, `F (rest & e_est <= 0.05)` |
| _Dispatched_ | nothing | the guarantees of _Margins_, and `G (w <= 0.8 & w >= -0.8)` |

## The steps

| Step | Operation | Result |
|---|---|---|
| 1. The contract of the controller | Q = System / (Perception ∥ Localization), with discharge | _Q_ guarantees the requirements of the system and `G (w <= 0.8 & w >= -0.8)` |
| 2. The requirements of the mission | `refines(MissionOnly, Q)` | invalid: reported clearance 0.40, true clearance 0, `w` = 0.9 |
| 3. With margins for the errors | `refines(Margins, Q)` | invalid: `w` = 1.2, true clearance 0 |
| 4. With the yaw rate | `refines(Dispatched, Q)`, `refines(Perception ∥ Localization ∥ Dispatched, System)` | valid |

The quotient is the weakest contract of the controller with which the
system meets its requirements, so it is the one to hand to the designer: it
leaves every design that works. With discharge it keeps the terms, and its
guarantees name what the neighbours assume of the controller: perception
needs `|w| <= 0.8` (the bound of localization, 1.0, follows from it). A
requirement written for the mission alone leaves this out (step 2), and so
does one with margins for the errors of perception and localization
(step 3): in both counterexamples the controller turns too fast, perception
no longer bounds its error, and the true clearance is 0. The paper finds
the same two failures on the robot in simulation, and checks the
refinements on finite sets of values; here they are checked on all the
behaviors, with a counterexample when they fail.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license
$> python3 Warehouse/warehouse.py
```

The directory also has the variables and the contracts in words
(`requirements.txt`).
