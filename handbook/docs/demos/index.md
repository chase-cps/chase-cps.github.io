# Demos

The demos are in the [demos](https://github.com/chase-cps/demos) repository,
and in the `demos` directory of the Docker image. Each one follows a design
problem from its requirements to a result, with the same parts: the
question, what it shows, the steps with their diagrams, and how to run it.
The tags after each demo say what it uses, and link to the page that
describes it.

## Repair and signals

Requirements over time on numbers, a check that fails, and the least change of a named constant that makes it pass.

- **[Room heating](heater.md)**: a thermostat overshoots its requirement by 2 degrees; repair finds the threshold (74), and ESBMC checks that its C code, called once per step, implements it.
  [verification](../contracts/checks.md){ .tag .t-verif } [signals](../contracts/checks.md#formulas-over-a-bounded-number-of-steps){ .tag .t-data } [robustness](../contracts/checks.md#robustness){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair } [C](../tools/c-programs.md){ .tag .t-code }
- **[Emergency braking](braking.md)**: the braking system of ContrACT misses its bound by 0.05 ms; repair finds the least change of the bound (4.05) or of the delay of the network (11, or 10.05).
  [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair }
- **[Drone climb](drone-altitude.md)**: a drone climbs to its drop altitude in the wind and misses it by 2.5 m; no climb rate fixes it, and repair says what the requirement can ask.
  [verification](../contracts/checks.md){ .tag .t-verif } [signals](../contracts/checks.md#formulas-over-a-bounded-number-of-steps){ .tag .t-data } [robustness](../contracts/checks.md#robustness){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair }
- **[Drone timing](drone-timing.md)**: the timing of the fire-suppression drones as linear constraints: the worst case of 280 ms, and the margins of the planner and the mission.
  [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data } [repair](../contracts/repair.md){ .tag .t-repair }
- **[Waiting time](deadline.md)**: the least bound on the waiting time of a request, repaired from the counterexamples of nuXmv.
  [verification](../contracts/checks.md){ .tag .t-verif } [repair](../contracts/repair.md){ .tag .t-repair }

## Code and agents

Contracts on code: C functions checked one at a time, and the plan of an AI agent.

- **[Contracts in C](contracts-in-c.md)**: the contract written in the C file (ESBMC, CBMC, or ACSL clauses), drawn and checked function by function; code with no contract checked for overflow and division by zero.
  [verification](../contracts/checks.md){ .tag .t-verif } [C](../tools/c-programs.md){ .tag .t-code }
- **[Drones in C](drone-grid.md)**: the step of two drones, checked one C function at a time: the contracts find that two drones can end in the same cell.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [C](../tools/c-programs.md){ .tag .t-code }
- **[Payment assistant agent](payment-assistant.md)**: an assistant agent splits a task among three sub-agents; the quotient says which sub-agent must do the missing step.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [agents](../interfaces/mcp.md){ .tag .t-code }

## Hardware

Contracts in SystemVerilog Assertions, checked against RTL read with Yosys.

- **[Security chip (OpenTitan)](escalation.md)**: the escalation link of a security chip, checked module by module; a faster sender breaks its contract.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [SVA](../tools/systemverilog.md){ .tag .t-hw } [RTL](../contracts/checks.md#rtl){ .tag .t-hw }
- **[Bus arbiter (AMBA AHB)](ahb.md)**: two viewpoints of the arbiter, unrealizable until the masters release a locked bus; then synthesized.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 } [SVA](../tools/systemverilog.md){ .tag .t-hw }
- **[Circuit buffer swap](buffer-swap.md)**: a smaller buffer does not refine the old one, but refines the quotient, the contract of its place.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [SVA](../tools/systemverilog.md){ .tag .t-hw } [RTL](../contracts/checks.md#rtl){ .tag .t-hw }

## Aircraft and robots

Requirements of real systems, with real variables, and what each part must do.

- **[Aircraft (Lift-Plus-Cruise)](lift-plus-cruise.md)**: the requirements of a NASA aircraft are consistent with one deadline and not a shorter one; the quotient says what the pilot must do.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data }
- **[Warehouse robot](warehouse-robot.md)**: the contract of a delegated controller is the quotient by perception and localization; requirements written for the mission alone fail it.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [reals](../contracts/checks.md#real-variables){ .tag .t-data }
- **[Autopilot (Lockheed Martin)](lm-fsm.md)**: the unrealizable cores find the conflicts of the requirements of an autopilot, fixed one at a time.
  [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }

## Controller synthesis

GR(1) contracts: realizability, cores, and the controllers slugs synthesizes.

- **[Charging station](charger.md)**: four arbiters for two robots, each problem caught by another check: unrealizable, not well separated, vacuous.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Robotic joints](robotic-joints.md)**: three joints refine the contract of an arm and are synthesized one at a time; the refinement scales to 8 joints in 5 s.
  [algebra](../contracts/algebra.md){ .tag .t-theory } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }

## Domain-specific language

Requirements written from patterns of a domain (dsl_tool).

- **[Power system (DATE 2018)](date18.md)**: the power system of an aircraft: the requirements as written are unrealizable, and the core says which bound to relax.
  [DSL](date18.md){ .tag .t-data } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Factory (FDL 2024)](fdl2024.md)**: a small factory: the controller of its gates is realizable, with slugs and with gr1c.
  [DSL](date18.md){ .tag .t-data } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }
- **[Tutorial (DATE 2021)](date21.md)**: the hands-on tutorial of the DATE 2021 University Booth, with the console tools of CHASE.
  [DSL](date18.md){ .tag .t-data } [verification](../contracts/checks.md){ .tag .t-verif } [GR(1)](../tools/synthesis.md){ .tag .t-gr1 }

The [Diagrams](../interfaces/diagrams.md#what-is-drawn) page says what the boxes and the tags of the figures mean.

All the demos are run and checked by the test suite of CHASE:

```
$> docker run --rm ghcr.io/chase-cps/chase /opt/chase/tests/demo-suite.sh
```
