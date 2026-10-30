---
wide: true
---

# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image. Each one follows a design
problem from its requirements to a result. The tags say what each one uses,
and link to its page: the [contract algebra](../contracts/algebra.md),
[contract-based verification](../contracts/checks.md),
[GR(1) synthesis](../tools/synthesis.md), contracts in
[SystemVerilog Assertions](../tools/systemverilog.md), RTL read with Yosys,
real variables, or a domain-specific language.

<div class="tbl-demos" markdown>

| Demo | What it shows | Uses |
|---|---|---|
| [Payment assistant agent](payment-assistant.md) | A task in natural language becomes the contract of an assistant agent, decomposed among three sub-agents: the decomposition misses a deliverable, the quotient says which sub-agent must do it, and an unsat core finds a clause against the request of the user | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> |
| [Security chip (OpenTitan)](escalation.md) | The escalation link of a security chip, checked module by module: the RTL of each module implements its contract, and the composition refines the requirements with no check on the whole design; a faster sender breaks its contract | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-hw" href="../tools/systemverilog.md">SVA</a> <a class="tag t-hw" href="../contracts/checks.md#rtl">RTL</a> |
| [Aircraft (Lift-Plus-Cruise)](lift-plus-cruise.md) | The lift modes of a NASA aircraft, with real variables: the requirements are consistent with one deadline and in conflict with a shorter one, and the quotient by the mode logic says what the pilot must do to hover in time | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-data" href="../contracts/checks.md#real-variables">reals</a> |
| [Bus arbiter (AMBA AHB)](ahb.md) | The arbiter of the AMBA AHB bus as two viewpoints in SVA: their merge is unrealizable until the masters release a locked bus, and then synthesized | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> <a class="tag t-hw" href="../tools/systemverilog.md">SVA</a> |
| [Circuit buffer swap](buffer-swap.md) | A buffer of a circuit is replaced by a smaller one: the contracts in SVA, the quotient as the contract of the buffer's place, and the RTL checked with Yosys and nuXmv, and with Jasper | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-hw" href="../tools/systemverilog.md">SVA</a> <a class="tag t-hw" href="../contracts/checks.md#rtl">RTL</a> |
| [Warehouse robot](warehouse-robot.md) | The controller of a warehouse robot is delegated: the quotient by perception and localization is its contract, with what they assume of it, and requirements written for the mission alone fail | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-data" href="../contracts/checks.md#real-variables">reals</a> |
| [Charging station (Charger)](charger.md) | Two robots share a charging station through an arbiter: one design iteration of the arbiter, from an unrealizable contract to a composition that refines the system | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |
| [Autopilot (Lockheed Martin)](lm-fsm.md) | The state machine of an autopilot and a sensor (Lockheed Martin challenge): the conflicts of the requirements found by unrealizable cores and fixed one at a time, and the time a pullup takes in the composition | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |
| [Robotic joints](robotic-joints.md) | The joints of a robotic arm: composition, refinement, synthesis of the joint controllers, and scaling with the number of joints | <a class="tag t-theory" href="../contracts/algebra.md">algebra</a> <a class="tag t-verif" href="../contracts/checks.md">verification</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |
| [Power systems and factories](power-systems.md) | Requirements written in a domain-specific language: the electrical power system of an aircraft (DATE 2018, DATE 2021) and a small factory (FDL 2024) | <a class="tag t-data" href="power-systems.md">DSL</a> <a class="tag t-gr1" href="../tools/synthesis.md">GR(1)</a> |

</div>

## Reading the diagrams

- A rounded box is a contract; a square box also has a model (RTL, a state
  machine, or a synthesized controller).
- A box drawn inside another is checked against it: the ⪯ tag says
  whether it refines it. The note under a name says how the contract is
  built: ⊗ composition (∥ in the text), • merging, / quotient; "contract X"
  names the contract of a system.
- Inside an open box, the dark A and G mark its assumptions and its
  guarantees.
- A dashed box is a quotient: what the missing part, written ? in the
  note, must satisfy, with the part checked against it drawn inside.
- The tags are the results of the checks, green when the check holds and
  red when it does not: ⪯ refinement, A compatible, G consistent,
  R realizable, WS well separated, ¬V not vacuous, M ⊨ C the model
  implements the contract. The lines highlighted in red are the core of a
  failed check.
- In the page that each script writes, a click on a name opens or closes a
  contract, and a click on a red tag shows its core.

All the demos are run and checked by the test suite of CHASE:

```
$> docker run --rm ghcr.io/chase-cps/chase /opt/chase/tests/demo-suite.sh
```
