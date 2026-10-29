# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image. Each one follows a design
problem from its requirements to a result. The tags say what each one uses,
and link to its page: the [contract algebra](../contracts/algebra.md),
[contract-based verification](../contracts/checks.md),
[GR(1) synthesis](../tools/synthesis.md), contracts in
[SystemVerilog Assertions](../tools/systemverilog.md), RTL read with Yosys,
real variables, or a domain-specific language.

| Demo | What it shows | Uses |
|---|---|---|
| [Charger](charger.md) | Two robots share a charging station through an arbiter: one design iteration of the arbiter, from an unrealizable contract to a composition that refines the system | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |
| [Lift-Plus-Cruise](lift-plus-cruise.md) | The lift modes of a NASA aircraft, with real variables: the requirements are consistent with one deadline and in conflict with a shorter one, and the quotient by the mode logic says what the pilot must do to hover in time | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-data" href="../contracts/checks.md#real-variables">reals</a> |
| [Robotic joints](robotic-joints.md) | The joints of a robotic arm: composition, refinement, synthesis of the joint controllers, and scaling with the number of joints | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |
| [BufferSwap](buffer-swap.md) | A buffer of a circuit is replaced by a smaller one: the contracts in SVA, the quotient as the contract of the place of the buffer, and the RTL checked with Yosys and nuXmv, and with Jasper | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-hw" href="../tools/systemverilog.md">SVA</a> <a class="tag t-hw" href="../contracts/checks.md#rtl">RTL</a> |
| [LMFSM](lm-fsm.md) | The state machine of an autopilot and a sensor (Lockheed Martin challenge): the conflicts of the requirements found by unrealizable cores and fixed one at a time, and the time a pullup takes in the composition | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |
| [AHB](ahb.md) | The arbiter of the AMBA AHB bus as two viewpoints in SVA: their merge is unrealizable until the masters release a locked bus, and then synthesized | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> <a class="tag t-hw" href="../tools/systemverilog.md">SVA</a> |
| [Warehouse](warehouse.md) | The controller of a warehouse robot is delegated: the quotient by perception and localization is its contract, with what they assume of it, and requirements written for the mission alone fail | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-data" href="../contracts/checks.md#real-variables">reals</a> |
| [Delegation](delegation.md) | A task of an AI agent split among three sub-agents (AppWorld): the contracts from the tools miss a deliverable, the quotient says which sub-agent must do it, and an unsat core finds a slip of the parent | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> |
| [Power systems and factories](power-systems.md) | Requirements written in a domain-specific language: the electrical power system of an aircraft (DATE 2018, DATE 2021) and a small factory (FDL 2024) | <a class="tag t-data" href="power-systems.md">DSL</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |

All the demos are run and checked by the test suite of CHASE:

```
$> docker run --rm ghcr.io/chase-cps/chase /opt/chase/tests/demo-suite.sh
```
