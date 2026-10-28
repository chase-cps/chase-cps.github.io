# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image. Each one follows a design
problem; the recent ones use the three layers of CHASE in turn.

| Demo | What it shows | Layers |
|---|---|---|
| [Charger](charger.md) | Two robots share a charging station through an arbiter: one design iteration of the arbiter, from an unrealizable contract to a composition that refines the system | <span class="tag l1">1</span> <span class="tag l2">2</span> <span class="tag l3">3</span> |
| [Lift-Plus-Cruise](lift-plus-cruise.md) | The lift modes of a NASA aircraft, with real variables: consistency, a behavior, and the requirements in conflict | <span class="tag l1">1</span> <span class="tag l2">2</span> |
| [Robotic joints](robotic-joints.md) | The joints of a robotic arm: composition, refinement, synthesis of the joint controllers, and scaling with the number of joints | <span class="tag l1">1</span> <span class="tag l2">2</span> <span class="tag l3">3</span> |
| [BufferSwap](buffer-swap.md) | A buffer of a circuit is replaced by a smaller one: the contracts in SVA, the quotient as the contract of the place of the buffer, and the RTL checked with Yosys and nuXmv, and with Jasper | <span class="tag l1">1</span> <span class="tag l2">2</span> |
| [LMFSM](lm-fsm.md) | The state machine of an autopilot and a sensor (Lockheed Martin challenge): the conflicts of the requirements found by unrealizable cores and fixed one at a time, and the time a pullup takes in the composition | <span class="tag l1">1</span> <span class="tag l2">2</span> |
| [Power systems and factories](power-systems.md) | Requirements written in a domain-specific language: the electrical power system of an aircraft (DATE 2018, DATE 2021) and a small factory (FDL 2024) | <span class="tag l3">3</span> |

All the demos are run and checked by the test suite of CHASE:

```
$> docker run --rm chase /opt/chase/tests/demo-suite.sh
```
