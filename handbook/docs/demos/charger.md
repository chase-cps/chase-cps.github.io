---
wide: true
---

# Charging station: designing an arbiter

**The question.** Two robots share a charging station through an arbiter.
How do the checks of CHASE guide the design of the arbiter, from a first
contract to one that works with the robots?

[![The system: an arbiter and two robots, which feed each other with requests and grants](../assets/diagram-charger-system.png)](../assets/diagram-charger-system.png)
_The system: an arbiter and two robots, which feed each other with requests and grants._

A robot asks for the station (`req`) when its battery is low (`low`), and
the arbiter gives it (`grant`). The requests of the robots are the inputs of
the arbiter, and its grants are the inputs of the robots.

## The steps

**Step 1. Greedy: unrealizable.** _Greedy_ gives the station to each robot
at the next step after its request (R6.1, R6.2), and never to both (R5).
When both robots ask at once, it cannot serve both: the unrealizable core is
these three guarantees.

[![Step 1: Greedy is unrealizable; its core on a red ground](../assets/diagram-charger-1.png)](../assets/diagram-charger-1.png)
_Step 1: Greedy is unrealizable; its core on a red ground._

**Step 2. Fair: realizable.** _Fair_ gives the station to each robot
eventually (R7.1, R7.2). It is realizable, and slugs synthesizes a
controller of 18 states.

[![Step 2: Fair is realizable and not vacuous](../assets/diagram-charger-2.png)](../assets/diagram-charger-2.png)
_Step 2: Fair is realizable and not vacuous._

**Step 3. Realizable for a bad reason.** _Pushy_ assumes that robot 1 asks
infinitely often (A2) and does not ask right after it is served (A3). The
arbiter can then keep the station for robot 1: robot 1 never asks again, A2
is broken, and the contract holds without serving anybody. It is not well
separated, with A2 and A3 as its core. _Polite_, which assumes A4 instead of
A3, is well separated.

[![Step 3: Pushy is not well separated (its core: A2, A3); Polite is](../assets/diagram-charger-3.png)](../assets/diagram-charger-3.png)
_Step 3: Pushy is not well separated (its core: A2, A3); Polite is._

**Step 4. An arbiter that never grants.** _Trusting_ assumes that the robots
stop asking on their own (`G F !req1`, `G F !req2`), so it meets its
guarantees without any grant: it is vacuous, and these two assumptions are
the core. _Fair_ is not vacuous. Its guarantee R8 is redundant (R7.1 implies
it) and is removed.

[![Step 4: Trusting is vacuous; its core on a red ground](../assets/diagram-charger-4.png)](../assets/diagram-charger-4.png)
_Step 4: Trusting is vacuous; its core on a red ground._

**Step 5. The arbiter with the robots.** _Fair_ and the robots, composed
with discharge: the guarantees of the arbiter discharge the assumptions of
the robots, and the composition refines _System_ (the diagram at the top).

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license && chase-cps install slugs
$> python3 Charger/charger.py
```

The script prints the result of each step and writes `out/charger.html`, the
diagrams above, to open in a browser: a click on a name opens a contract,
and a click on a red tag shows its core. The requirements are in
`Charger/requirements.txt`, and the same iteration with the console of
logics_tool in `Charger/charger.chase`.
