# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image. Each one follows a design
problem from its requirements to a result. The tags after each demo say what
it uses, and link to the page that describes it.

- **[Payment assistant agent](payment-assistant.md)**: an assistant agent splits a task among three sub-agents. The decomposition misses a step, the quotient says which sub-agent must do it, and an unsat core finds a clause against the request of the user.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif }
- **[Security chip (OpenTitan)](escalation.md)**: the escalation link of a security chip, checked module by module: the RTL of each module implements its contract, and the composition refines the requirements. A faster sender breaks its contract.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [SVA](../tools/systemverilog.md){ .tag .t-hw } [RTL](../contracts/checks.md#rtl){ .tag .t-hw }
- **[Aircraft (Lift-Plus-Cruise)](lift-plus-cruise.md)**: the lift modes of a NASA aircraft, with real variables. The requirements are consistent with one deadline and in conflict with a shorter one. The quotient by the mode logic says what the pilot must do to hover in time.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data }
- **[Bus arbiter (AMBA AHB)](ahb.md)**: the arbiter of the AMBA AHB bus as two viewpoints in SVA. Their merge is unrealizable until the masters release a locked bus; it is then synthesized.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 } [SVA](../tools/systemverilog.md){ .tag .t-hw }
- **[Circuit buffer swap](buffer-swap.md)**: a buffer of a circuit is replaced by a smaller one. The contracts are in SVA, the quotient is the contract of the place of the buffer, and the RTL is checked with Yosys and nuXmv, and with Jasper.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [SVA](../tools/systemverilog.md){ .tag .t-hw } [RTL](../contracts/checks.md#rtl){ .tag .t-hw }
- **[Warehouse robot](warehouse-robot.md)**: the controller of a warehouse robot is delegated. The quotient by perception and localization is its contract, and requirements written for the mission alone fail.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data }
- **[Charging station (Charger)](charger.md)**: two robots share a charging station through an arbiter. One design iteration of the arbiter, from an unrealizable contract to a composition that refines the system.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Autopilot (Lockheed Martin)](lm-fsm.md)**: the state machine of an autopilot and a sensor, from a Lockheed Martin challenge. The unrealizable cores find the conflicts of the requirements, which are fixed one at a time.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Robotic joints](robotic-joints.md)**: the joints of a robotic arm: composition, refinement, synthesis of the joint controllers, and scaling with the number of joints.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Power systems and factories](power-systems.md)**: requirements written in a domain-specific language: the electrical power system of an aircraft (DATE 2018, DATE 2021) and a small factory (FDL 2024).
  [DSL](power-systems.md){ .tag .t-data } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }

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
