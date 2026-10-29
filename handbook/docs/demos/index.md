# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image. Each one follows a design
problem; the recent ones use the contract algebra, verification, and
synthesis in turn.

| Demo | What it shows | Uses |
|---|---|---|
| [Charger](charger.md) | Two robots share a charging station through an arbiter: one design iteration of the arbiter, from an unrealizable contract to a composition that refines the system | <span class="tag l1">algebra</span> <span class="tag l2">verification</span> <span class="tag l3">synthesis</span> |
| [Lift-Plus-Cruise](lift-plus-cruise.md) | The lift modes of a NASA aircraft, with real variables: consistency, a behavior, and the requirements in conflict | <span class="tag l1">algebra</span> <span class="tag l2">verification</span> |
| [Robotic joints](robotic-joints.md) | The joints of a robotic arm: composition, refinement, synthesis of the joint controllers, and scaling with the number of joints | <span class="tag l1">algebra</span> <span class="tag l2">verification</span> <span class="tag l3">synthesis</span> |
| [BufferSwap](buffer-swap.md) | A buffer of a circuit is replaced by a smaller one: the contracts in SVA, the quotient as the contract of the place of the buffer, and the RTL checked with Yosys and nuXmv, and with Jasper | <span class="tag l1">algebra</span> <span class="tag l2">verification</span> |
| [LMFSM](lm-fsm.md) | The state machine of an autopilot and a sensor (Lockheed Martin challenge): the conflicts of the requirements found by unrealizable cores and fixed one at a time, and the time a pullup takes in the composition | <span class="tag l1">algebra</span> <span class="tag l2">verification</span> |
| [AHB](ahb.md) | The arbiter of the AMBA AHB bus as two viewpoints: their merge is synthesized, and the controller does not implement their conjunction | <span class="tag l1">algebra</span> <span class="tag l2">verification</span> |
| [Power systems and factories](power-systems.md) | Requirements written in a domain-specific language: the electrical power system of an aircraft (DATE 2018, DATE 2021) and a small factory (FDL 2024) | <span class="tag l3">synthesis</span> |

All the demos are run and checked by the test suite of CHASE:

```
$> docker run --rm chase /opt/chase/tests/demo-suite.sh
```
