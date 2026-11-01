---
wide: true
---

# Lockheed Martin autopilot: the requirements in conflict, and the time the pullup takes

**The system.** An autopilot of an aircraft commands a safety maneuver, a
pullup, when a sensor reports that the flight limits are exceeded. The
requirements come from the Ten Lockheed Martin Cyber-Physical Challenges
(Mavridou et al., RE 2020), first as written and then corrected, as in
the case study LMCPS of [FRET](https://github.com/NASA-SW-VnV/fret), the
requirements tool of NASA. Each
requirement is a transition of a state machine, written in LTL (`x'` is
`x` at the next step). _Autopilot_ has the states `STATE` 0 TRANSITION, 1
NOMINAL, 2 MANEUVER (the pullup), 3 STANDBY; it reads `standby` (the pilot
is in control), `apfail` (an external failure), `supported` (the system is
healthy), and `good` (the sensor sees no fault). _Sensor_ has the states
`SENSTATE` 0 NOMINAL, 1 TRANSITION, 2 FAULT; it reads `limits` (the limits
are exceeded) and the mode of the autopilot. The contracts assume nothing
of the environment. slugs checks realizability, nuXmv the refinements.

**The question.** Two questions. Which of the first requirements are in
conflict, so that no autopilot can meet them? And once they are
corrected, does the pullup come as soon as the system requirement says?
The first is asked before anyone builds the autopilot, the second before
anyone signs off its timing.

[![The autopilot and the sensor, inside the system requirement Pullup](../assets/demos/lm-fsm/system-autopilot-and-sensor.png){ width="671" }](../assets/demos/lm-fsm/system-autopilot-and-sensor.png)
_The system: the autopilot and the sensor, inside the system requirement, FSM-001._

## The steps

The tags on the boxes give the results of the checks: green holds, red
fails; [Diagrams](../interfaces/diagrams.md) says
how to read them.

**Step 1. The first requirements.** A contract is
[realizable](../tools/synthesis.md#realizability-and-synthesis)
when some state machine meets it whatever the environment does. The first
requirements of the autopilot are not. CHASE finds an
[unrealizable core](../tools/synthesis.md#unrealizable-cores),
the smallest set of requirements that no machine meets together: the
initial state, `G ((STATE = 0 & standby') -> STATE' = 3)`, and
`G ((STATE = 0 & supported' & good) -> STATE' = 1)`. In TRANSITION, with
the pilot in control and good data, one says STANDBY and the other
NOMINAL. The script replaces one requirement per core by its corrected
version until the contract is realizable: four conflicts in the autopilot,
one in the sensor, the ones FRET reports. Finding them by reading 14
requirements is hard; each core points at two to four.

[![Step 1: AutopilotFirst, unrealizable, with its first core in red](../assets/demos/lm-fsm/step1-first-requirements-unrealizable.png)](../assets/demos/lm-fsm/step1-first-requirements-unrealizable.png)
_Step 1: the first requirements; the cores in red._

**Step 2. The system.** The corrected _Autopilot_ and _Sensor_ are
realizable. Composed, they do not
[refine](../contracts/checks.md#verification-tasks)
_Pullup_, `G ((limits & !standby & !apfail & supported) -> pullup)`: a
pullup at the step the limits are exceeded. In the counterexample, the
limits are exceeded at step 1, but the autopilot is still in NOMINAL.

[![Step 2: the counterexample, in the panel and on the wires](../assets/demos/lm-fsm/step2-does-not-refine-pullup.png)](../assets/demos/lm-fsm/step2-does-not-refine-pullup.png)
_Step 2: the composition does not refine Pullup; the values at step 1._

**Step 3. The system, with time.** The sensor and the autopilot each take
a step to react. _PullupTimed_ gives the pullup that time: after three
steps within the limits and one beyond, with the pilot not in control and
no failure, the pullup comes at the fifth step. The composition refines it.

[![Step 3: Autopilot and Sensor inside PullupTimed; the refinement holds](../assets/demos/lm-fsm/step3-refines-pulluptimed.png){ width="662" }](../assets/demos/lm-fsm/step3-refines-pulluptimed.png)
_Step 3: the composition refines PullupTimed._

## Run it

```
pip install chase-cps
chase-cps install nuxmv --accept-license
chase-cps install slugs
python fsm.py --expect
```

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/LMFSM); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
