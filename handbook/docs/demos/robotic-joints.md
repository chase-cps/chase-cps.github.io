---
wide: true
---

# Robotic joints

**The question.** A robotic arm is built from three joints, each with its
own contract. Does the arm meet its contract, can each joint be
synthesized, and how does the check grow with the number of joints?

[![The arm: three joints inside the contract of the arm](../assets/diagram-robotic-joints-system.png)](../assets/diagram-robotic-joints-system.png)
_The arm: three joints inside the contract of the arm._

The demo was first presented at CPS-IoT Week 2022. The arm asks Joint1 to
move (`req_j1`) to an angle (`j1_dangle`); the joint commands its motor
(`j1_cmd`: stop, up, or down), reads the angle (`j1_angle`), and says when
it is there (`j1_done`). Joint2 and Joint3 are alike. Each joint stops the
motor when it is done or not asked, is done exactly at the requested angle,
and is done infinitely often, under assumptions on the motor and on the
requests.

## The steps

**Step 1. The composition.** Joint1 ∥ Joint2 ∥ Joint3 refines _Joints_, the
contract of the arm.

**Step 2. The joints.** Each joint is realizable, and slugs synthesizes its
controller.

[![Steps 1 and 2: the joints refine the arm, and each one is realizable; Joint1 and the arm open](../assets/diagram-robotic-joints-1.png)](../assets/diagram-robotic-joints-1.png)
_Steps 1 and 2: the joints refine the arm, and each one is realizable; Joint1 and the arm open._

**Step 3. More joints.** `scaling.py` builds the same contracts for N joints
and checks the refinement, for a correct arm and for a broken one (a joint
that may never be done). With the closed-form composition, the correct arm
is checked up to 5 joints (84 s), and the counterexample of the broken one
is found up to 8 joints. Composed with discharge, the composition keeps the
terms of the joints, and the refinement is proved up to 8 joints in 3.3 s.

[![Step 3: refinement time against the number of joints](../assets/robotic-joints-scaling.png){ width="440" }](../assets/robotic-joints-scaling.png)
_Step 3: refinement time against the number of joints._

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license && chase-cps install slugs
$> sh RoboticJoints/diagram.sh
$> python3 RoboticJoints/scaling.py --joints 1 2 3 4 5 --broken
```

`diagram.sh` checks steps 1 and 2 and writes `out/specs.html`, the diagram
above, to open in a browser. The same steps with the console of
logics_tool are in `RoboticJoints/verification.chase` and
`RoboticJoints/synthesis.chase`; the data of the plot are in
`RoboticJoints/results`.
