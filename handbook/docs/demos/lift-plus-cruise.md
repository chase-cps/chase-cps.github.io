---
wide: true
---

# NASA Lift-Plus-Cruise aircraft: what the pilot must do to hover in time

**The system.** Lift-Plus-Cruise is a NASA concept of an electric aircraft
that takes off and hovers on lift rotors and cruises on a wing. Its mode
logic sets `lift_mode`: 3 wing borne (flying on the wing), 2 semi wing
borne, 1 semi thrust borne, 0 thrust borne (hovering on the rotors). It
reads the airspeed `kias` and the ground speed `kgs` (knots), and the hover
control `hover_control_mode`, which the pilot turns on. The requirements
come from the LPC_mini example of
[FRET](https://github.com/NASA-SW-VnV/fret), the requirements tool of NASA
(Pressburger et al., REFSQ 2023), as LTL formulas over real numbers, one
formula per requirement. The vehicle is split in two parts: _ModeLogic_, with the requirements on the modes, and
_Pilot_, which sets the speeds and the hover control: it starts at 120
knots and changes the speed by at most 10 per step. The checks run on
nuXmv, with its SMT engine for the reals.

**The question.** The requirements say what the mode logic does, not what
the pilot does, so some flights hover within 12 steps and others never do.
What must the pilot do so that every flight hovers in time? A designer of
the pilot, or of a flight procedure, needs exactly this contract.

[![The mode logic and the pilot, inside the requirements with the deadline of 12 steps](../assets/demos/lift-plus-cruise/system-mode-logic-and-pilot.png){ width="676" }](../assets/demos/lift-plus-cruise/system-mode-logic-and-pilot.png)
_The system: the pilot drives the mode logic, inside the requirements with the deadline of 12 steps._

## The steps

The tags on the boxes give the results of the checks: green holds, red
fails; [Diagrams](../interfaces/diagrams.md) says
how to read them.

**Step 1. Two deadlines.** With a deadline of 12 steps the requirements
are consistent: some flight meets them all. With 6 they are not, and CHASE
finds the [unsat core](../contracts/checks.md#cores-why-a-check-fails),
the smallest set of requirements in conflict: 8 of 18. They say why:
`kias` starts at 120 and changes by at most 10 per step, the vehicle stays
wing borne above 90 and semi wing borne above 30, so it cannot hover by
step 6.

[![Step 1: Vehicle_Reach12, green; Vehicle_Reach06, red, with the terms of the core](../assets/demos/lift-plus-cruise/step1-reach06-inconsistent-core.png){ width="733" }](../assets/demos/lift-plus-cruise/step1-reach06-inconsistent-core.png)
_Step 1: consistent with 12 steps, not with 6; the core in red._

**Step 2. The split.** _ModeLogic_ ⊗ _Pilot_ (their composition)
[refines](../contracts/checks.md#verification-tasks)
_Vehicle_, the requirements without a deadline.

[![Step 2: Vehicle with Pilot and ModeLogic inside; the refinement holds](../assets/demos/lift-plus-cruise/step2-mode-logic-and-pilot.png){ width="661" }](../assets/demos/lift-plus-cruise/step2-mode-logic-and-pilot.png)
_Step 2: the split refines the vehicle._

**Step 3. What the pilot must do.** CHASE computes the
[quotient](../contracts/algebra.md#example-the-contract-of-a-missing-component)
Q12 = Reach12 / ModeLogic, the dashed box: the weakest contract of the
pilot with which every flight hovers within 12 steps. It is derived from
the requirements, not written by hand. _Pilot_, with the requirements
alone, does not refine it: in the counterexample `kias` stays at 120 and
the vehicle never leaves the wing.

[![Step 3: Pilot inside Q12; red, with the counterexample](../assets/demos/lift-plus-cruise/step3-pilot-does-not-refine-q12.png)](../assets/demos/lift-plus-cruise/step3-pilot-does-not-refine-q12.png)
_Step 3: Pilot does not refine Q12: <code>kias</code> stays at 120._

**Step 4. A pilot that slows down.** _Slow_ lowers `kias` by 10 per step,
but never turns the hover control on: the vehicle stops at semi thrust
borne, and _Slow_ does not refine Q12.

[![Step 4: Slow inside Q12; red, with the counterexample](../assets/demos/lift-plus-cruise/step4-slow-does-not-refine-q12.png)](../assets/demos/lift-plus-cruise/step4-slow-does-not-refine-q12.png)
_Step 4: Slow slows down, but never turns the hover control on._

**Step 5. A pilot that turns on the hover control.** _Decel_ also turns
the hover control on when `kgs` is below 20, and refines Q12: with the
mode logic, every flight hovers within 12 steps. It does not refine
Q06 = Reach06 / ModeLogic: no pilot can, as step 1 showed.

[![Step 5: Decel inside Q12; the refinement holds](../assets/demos/lift-plus-cruise/step5-decel-refines-q12.png){ width="598" }](../assets/demos/lift-plus-cruise/step5-decel-refines-q12.png)
_Step 5: Decel refines Q12._

[![Step 5: Decel inside Q06; red, with the counterexample](../assets/demos/lift-plus-cruise/step6-decel-does-not-refine-q06.png)](../assets/demos/lift-plus-cruise/step6-decel-does-not-refine-q06.png)
_Step 5: Decel does not refine Q06: at step 6 the vehicle is still semi wing borne._

## Run it

```
pip install chase-cps
chase-cps install nuxmv --accept-license
python lpc.py --expect
```

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/LiftPlusCruise); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
