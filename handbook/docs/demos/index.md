# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image; [Running the
demos](running.md) says how to run them. They are grouped by the kind of
system. The tags after each demo say what it uses.

## AI agents

The plan of an AI agent, as a contract over its tool calls.

- **[Payment assistant agent](payment-assistant.md)**: the plan of an AI agent, split among three sub-agents, checked before it runs; the quotient says which sub-agent must send the text.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [agents](../interfaces/mcp.md){ .tag .t-code }

## Aircraft and vehicles

Requirements of aircraft and cars, on Booleans and real numbers.

- **[NASA Lift-Plus-Cruise aircraft](lift-plus-cruise.md)**: the requirements of a NASA aircraft are consistent with a hover in 12 steps, not in 6; the quotient says what the pilot must do.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data }
- **[Lockheed Martin autopilot](lm-fsm.md)**: the unrealizable cores find the requirements in conflict, fixed one at a time.
  [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Emergency braking](braking.md)**: a braking system misses its bound by 0.05 ms; repair finds the least change of the bound or of the network delay.
  [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair }
- **[Aircraft power system](aircraft-power.md)**: requirements written as patterns: the bounds as written conflict, and the core points to one DC bus; relaxed, they are realizable.
  [DSL](aircraft-power.md){ .tag .t-data } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }

## Hardware

Contracts in SystemVerilog Assertions, checked against RTL, and synthesized arbiters.

- **[OpenTitan security chip](escalation.md)**: the escalation link proven module by module from its RTL; a faster sender breaks its contract.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [SVA](../tools/systemverilog.md){ .tag .t-hw } [RTL](../contracts/checks.md#rtl){ .tag .t-hw }
- **[Circuit buffer swap](buffer-swap.md)**: a smaller buffer fails the old contract, but refines the quotient: the contract of its slot.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [SVA](../tools/systemverilog.md){ .tag .t-hw } [RTL](../contracts/checks.md#rtl){ .tag .t-hw }
- **[AMBA AHB bus arbiter](ahb.md)**: two viewpoints that cannot be merged, the assumption that fixes them, and the arbiter synthesized.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 } [SVA](../tools/systemverilog.md){ .tag .t-hw }
- **[Resource arbiter](deadline.md)**: the least bound on the waiting time of a request, repaired from the counterexamples of nuXmv.
  [verification](../contracts/checks.md){ .tag .t-verif } [repair](../contracts/repair.md){ .tag .t-repair }

## Software

C functions checked one at a time against contracts written in the C file.

- **[Contracts in C](contracts-in-c.md)**: the contract written in the C file (ESBMC, CBMC, or ACSL clauses), checked function by function; code with no contract checked for overflow.
  [verification](../contracts/checks.md){ .tag .t-verif } [C](../tools/c-programs.md){ .tag .t-code }
- **[Fire-suppression drones in C](drone-grid.md)**: a collision of two drones found and fixed on the contracts, then each C function checked against its contract.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [C](../tools/c-programs.md){ .tag .t-code }

## Drones and robots

Drones, robots, and their controllers, checked and synthesized.

- **[Drone climb](drone-altitude.md)**: no climb rate beats the wind: repair says what the requirement can ask.
  [verification](../contracts/checks.md){ .tag .t-verif } [signals](../contracts/checks.md#formulas-over-a-bounded-number-of-steps){ .tag .t-data } [robustness](../contracts/checks.md#robustness){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair }
- **[Warehouse robot](warehouse-robot.md)**: the contract of a controller to delegate is the quotient by perception and localization.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data }
- **[Robot charging station](charger.md)**: refinement does not see the conflict, realizability does: five arbiters, each problem caught by another check.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Robotic arm joints](robotic-joints.md)**: three joints refine the contract of the arm and are synthesized one at a time; the check scales to 8 joints in 5 s.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Pick-and-place arm](pick-and-place.md)**: the mission refines the target, and the coordinator of the arm is synthesized.
  [DSL](aircraft-power.md){ .tag .t-data } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Drone timing](drone-timing.md)**: the timing of the drones as a linear program: the worst case and the margins of each part.
  [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair }

## Buildings and factories

A room and a factory, from the requirement to the controller and its code.

- **[Room thermostat](heater.md)**: a thermostat overshoots by 2 degrees; repair finds the threshold, and ESBMC checks that its C code implements it.
  [verification](../contracts/checks.md){ .tag .t-verif } [signals](../contracts/checks.md#formulas-over-a-bounded-number-of-steps){ .tag .t-data } [robustness](../contracts/checks.md#robustness){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair } [C](../tools/c-programs.md){ .tag .t-code }
- **[Factory gate controller](factory-gates.md)**: the bays keep their supply when the main conveyors fail; without the secondary conveyors, the core says why they do not.
  [DSL](aircraft-power.md){ .tag .t-data } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }

The [Diagrams](../interfaces/diagrams.md#what-is-drawn) page says what the boxes and the tags of the figures mean.

All the demos are run and checked by the test suite of CHASE:

```
$> docker run --rm ghcr.io/chase-cps/chase /opt/chase/tests/demo-suite.sh
```
