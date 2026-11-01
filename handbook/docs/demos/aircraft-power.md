---
wide: true
---

# Aircraft power system: the bounds as written conflict, relaxed they are realizable

**The system.** The electric power system of an aircraft, from Nuzzo et
al., "CHASE: Contract-based requirement engineering for cyber-physical
system design" (DATE 2018). A left and a right generator each feed an AC
bus, a rectifier, a DC bus, and a load. Contactors (switches) connect each
generator to its AC bus (contactors 1 and 2), and the two AC buses to each
other (contactor 3). A controller opens and closes the contactors; it
reads the state of the generators and of the contactors, and commands the
contactors. The system and its requirements are written in the language
of CHASE for power systems (read by `load_dsl`), which turns them into a
GR(1) contract for the controller (GR(1) is the fragment of LTL that a
synthesis tool such as slugs solves): it assumes that a contactor switches
in 10 ms or less and that at most one generator fails, and guarantees,
among others, that the generators never run in parallel and that no DC
bus stays without power more than 15 ms. Times become counters: a step is
5 ms.

**The question.** Can the contactors be switched so that the
requirements hold whatever fails? If not, which requirements are in
conflict? The answer tells the system engineers which bound to renegotiate
before anyone designs the controller.

[![The controller of the contactors: the states of the generators and contactors as inputs, the commands of the contactors and the counters as outputs](../assets/demos/aircraft-power/system-controller.png){ width="501" }](../assets/demos/aircraft-power/system-controller.png)
_The system: the controller of the contactors, with its inputs and outputs._

## The steps

The tags on the boxes give the results of the checks: green holds, red
fails; [Diagrams](../interfaces/diagrams.md) says
how to read them.

**Step 1. The requirements as written.** The contract (11 inputs, 7
outputs, 30 assumptions, 28 guarantees) is not
[realizable](../tools/synthesis.md#realizability-and-synthesis):
no controller meets it whatever the generators do. CHASE finds the
[unrealizable core](../tools/synthesis.md#unrealizable-cores),
4 of the 28 guarantees: contactors 1, 2, and 3 are never all closed, and
the three terms of the counter of one DC bus allow it at most 15 ms
without power. When a generator fails, its DC bus can be fed again only
through contactor 3, after the contactor of that generator opens: two
switchings of up to 10 ms each, more than 15 ms.

[![Step 1: EPS_15ms is unrealizable; the four guarantees of the core in red, and the panel of the check](../assets/demos/aircraft-power/step1-unrealizable-core.png)](../assets/demos/aircraft-power/step1-unrealizable-core.png)
_Step 1: the requirements as written are unrealizable; the terms of the core are red._

**Step 2. The relaxed requirements.** `template_0_realizable.txt` changes
two lines: 20 ms to disconnect a failed generator, 30 ms for a DC bus (a
step is then 10 ms). The contract (24 assumptions, 26 guarantees) is
realizable, and slugs synthesizes a controller of 97 states from it.

[![Step 2: EPS_30ms, realizable, with the states of the generators and contactors as inputs and the commands of the contactors as outputs](../assets/demos/aircraft-power/step2-relaxed-realizable.png){ width="521" }](../assets/demos/aircraft-power/step2-relaxed-realizable.png)
_Step 2: the relaxed requirements are realizable (R)._

The same language describes a [factory](https://github.com/chase-cps/demos/blob/main/FDL2024/FDL2024.md).

## Run it

```
pip install chase-cps
chase-cps install slugs
python eps.py --expect
```

`sh solution.sh /tmp/eps` runs both versions with `dsl_tool` and slugs.

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/DATE18); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
