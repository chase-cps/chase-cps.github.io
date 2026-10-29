---
wide: true
---

# Aircraft: what makes it hover in time

**The question.** Some flights of an aircraft meet its requirements and
hover within 12 steps. What must the pilot do so that every flight does?

[![The vehicle: the mode logic and the pilot](../assets/diagram-lift-plus-cruise-system.png)](../assets/diagram-lift-plus-cruise-system.png)
_The vehicle: the mode logic and the pilot._

Lift-Plus-Cruise is an aircraft studied at NASA, with lift rotors for the
hover and a wing for the cruise. The requirements are those of the LPC_mini
project of [FRET](https://github.com/NASA-SW-VnV/fret) (Pressburger et al.,
REFSQ 2023). The mode logic gives the lift mode `lift_mode` (0 thrust borne,
i.e. hover; 1 semi thrust borne; 2 semi wing borne; 3 wing borne) from the
airspeed `kias` and the ground speed `kgs`, both real numbers. The pilot
sets the speeds and the hover control mode `hover_control_mode`. The
airspeed is 120 at the start and changes by at most 10 at each step.

## The steps

**Step 1. Two deadlines.** The requirements with a hover within 12 steps
(_Reach12_) are consistent; with a hover within 6 steps (_Reach06_) they are
not. The unsat core gives the reason: the vehicle stays wing borne while
`kias` is above 90, then semi wing borne while it is above 30, and `kias`
cannot fall from 120 to 30 by step 6. No pilot can hover within 6 steps.

[![Step 1: consistent with 12 steps (G green), not with 6 (G red)](../assets/diagram-lift-plus-cruise-1.png)](../assets/diagram-lift-plus-cruise-1.png)
_Step 1: consistent with 12 steps (G green), not with 6 (G red)._

**Step 2. The split.** The vehicle is split into the mode logic and the
pilot, as in the diagram at the top, and _ModeLogic_ ∥ _Pilot_ refines the
requirements of the vehicle.

**Step 3. What the pilot must do.** The quotient Q12 = Reach12 / ModeLogic,
drawn as a dashed box, is the weakest contract of the pilot with which
every flight hovers within 12 steps. _Pilot_, which has only the
requirements on the speeds, does not refine it: `kias` may stay at 120.

[![Step 3: Q12, what the pilot must do; Pilot does not refine it](../assets/diagram-lift-plus-cruise-3.png)](../assets/diagram-lift-plus-cruise-3.png)
_Step 3: Q12, what the pilot must do; Pilot does not refine it._

**Step 4. A pilot that slows down.** _Slow_ also lowers `kias` by 10 at each
step. It does not refine Q12: the hover control mode is never turned on, so
the vehicle never reaches the hover.

[![Step 4: Slow does not refine Q12](../assets/diagram-lift-plus-cruise-4.png)](../assets/diagram-lift-plus-cruise-4.png)
_Step 4: Slow does not refine Q12._

**Step 5. A pilot that slows down and turns on the hover control.**
_Decel_ also turns the hover control mode on when `kgs` is below 20. It
refines Q12, so every flight hovers within 12 steps. As step 1 says, it
does not refine Q06.

[![Step 5: Decel refines Q12](../assets/diagram-lift-plus-cruise-5.png)](../assets/diagram-lift-plus-cruise-5.png)
_Step 5: Decel refines Q12._

[![Step 5: Decel does not refine Q06](../assets/diagram-lift-plus-cruise-6.png)](../assets/diagram-lift-plus-cruise-6.png)
_Step 5: Decel does not refine Q06._

The checks are on real variables, with the SMT engine of nuXmv.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license
$> python3 LiftPlusCruise/lpc.py
```

The script prints the result of each step, with the counterexamples, and
writes the diagrams above in `out/lpc.html`. The requirements in FRETish are
in `LiftPlusCruise/requirements.txt`.
