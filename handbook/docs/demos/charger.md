---
wide: true
---

# Robot charging station: refinement does not see the conflict, realizability does

**The question.** Two robots share a charging station through an arbiter.
Each first contract of the arbiter is flawed. Which check catches
which, and which arbiter works with the robots?

**The result.**

- Refinement does not see the conflict, realizability does: _Greedy_ is
  unrealizable, with 3 of its 5 guarantees in the unrealizable core (the
  smallest set of requirements in conflict), yet with the robots it refines
  _ChargingStation_.
- _Pushy_ is not well separated, and _Trusting_ is vacuous: each wins for
  a bad reason.
- _Fair_ is realizable, with a controller of 18 states. With the robots, it
  refines _ChargingStation_ with no assumption left.

[![The five arbiters, and Fair with the robots inside ChargingStation](../assets/demos/charger/overview-all-checks.png){ width="723" }](../assets/demos/charger/overview-all-checks.png)
_The five arbiters, and Fair with the robots inside ChargingStation._

Each robot asks for the station (`req`) when its battery is low, and
assumes that it gets it (`grant`), or stops asking, infinitely often.
Every arbiter guarantees that the station never goes to both robots
(R5, numbered as in `requirements.txt`).

## The steps

**Step 1. Greedy: unrealizable.** _Greedy_ grants each request at the next
step (R6.1, R6.2). When both robots ask at once, it cannot serve both: the
core is R5, R6.1, and R6.2. Yet _Greedy_ with the robots refines
_ChargingStation_.

[![Step 1: Greedy, unrealizable, with its core in red](../assets/demos/charger/step1-greedy-unrealizable.png)](../assets/demos/charger/step1-greedy-unrealizable.png)
_Step 1: the core of Greedy in red._

**Step 2. Fair: realizable.** _Fair_ gives the station to each robot, or
the robot stops asking, infinitely often (R7.1, R7.2): it is realizable,
with a controller of 18 states, and not vacuous (¬V: it cannot win without
setting its outputs). `remove_redundant` removes R8, implied by R7.1.

[![Step 2: Fair, open, realizable and not vacuous](../assets/demos/charger/step2-fair-realizable.png){ width="192" }](../assets/demos/charger/step2-fair-realizable.png)
_Step 2: Fair is realizable (R) and not vacuous (¬V)._

**Step 3. Realizable for a bad reason.** _Pushy_ assumes that robot 1 asks
infinitely often (A2), but never right after a grant (A3). Granting robot
1 at every step breaks A2, so the arbiter wins. _Pushy_ is not well
separated (WS: the arbiter cannot win by forcing the robots to break its
assumptions); the core is A2 and A3. _Polite_, with A4 (only after a grant it asked for)
instead of A3, is well separated.

[![Step 3: Pushy, with its core in red, and Polite](../assets/demos/charger/step3-pushy-not-well-separated.png)](../assets/demos/charger/step3-pushy-not-well-separated.png)
_Step 3: Pushy is not well separated; Polite is._

**Step 4. An arbiter that never grants.** _Trusting_ is _Fair_ with two
more assumptions: each robot stops asking infinitely often. Its guarantees
then hold without any grant: it is vacuous. The core: the two
assumptions and the guarantees they make true.

[![Step 4: Trusting, vacuous, with its core in red](../assets/demos/charger/step4-trusting-vacuous.png)](../assets/demos/charger/step4-trusting-vacuous.png)
_Step 4: Trusting is vacuous (¬V red)._

**Step 5. The arbiter with the robots.** _Fair_ (without R8) and the robots
feed each other. Composed with discharge, they leave no assumption, and
refine _ChargingStation_.

[![Step 5: Fair, Robot1, and Robot2 inside ChargingStation](../assets/demos/charger/step5-arbiter-and-robots.png){ width="532" }](../assets/demos/charger/step5-arbiter-and-robots.png)
_Step 5: the composition refines ChargingStation._

## Run it

```
pip install chase-cps
chase-cps install nuxmv --accept-license
chase-cps install slugs
python charger.py --expect
```

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/Charger); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
