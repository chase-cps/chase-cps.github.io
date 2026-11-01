---
wide: true
---

# OpenTitan security chip: the escalation link proven module by module from its RTL

**The system.** [OpenTitan](https://opentitan.org) is an open source
security chip. When it detects an attack, an alert handler sends an
escalation (an order to react, for instance to wipe the keys) to a
receiver, over an escalation link. This demo is a small version of that
link: _Sender_, _Channel_ (the wires), and _Receiver_, each a Verilog
module. To escalate, the sender raises a differential pair: two wires
with opposite values (`esc_p_tx`, `esc_n_tx`), so a single wrong wire
makes them equal, which both ends detect. To ping (test that the receiver
is alive), it sends one-cycle pulses; a pulse of two cycles is an
escalation. The inputs `err_ep`, `err_en`, `err_rp`, `err_rn` flip one
wire of the channel, to model a fault or an attack. The contracts of the
modules and the two requirements are written in SystemVerilog Assertions,
after the assertions of OpenTitan (`prim_esc_rxtx_assert_fpv`):
_Functional_ (with no wrong wire, a request held two cycles escalates the
receiver, nothing else does, and a ping is answered) and _Integrity_ (a
single wrong wire is detected). Yosys reads the Verilog into state
machines, and nuXmv checks them.

**The question.** Does the link meet both requirements, and can we show
it by checking each module on its own? Checking modules one by one scales
to designs too large to check at once, and a module can then be replaced
by any other that meets its contract.

[![The link: Sender, Channel, and Receiver, with the injected faults err_* as inputs, inside the requirement Functional](../assets/demos/escalation/system-link.png){ width="870" }](../assets/demos/escalation/system-link.png)
_The system: the three modules, each with its Verilog, inside the requirement Functional._

## The steps

The tags on the boxes give the results of the checks: green holds, red
fails; [Diagrams](../interfaces/diagrams.md) says
how to read them.

**Step 1. Each module.** The Verilog of the sender, of the channel, and of
the receiver implements its contract (M ⊨ C: every behavior of the module
meets the contract). The receiver is drawn open: its contract and its
state machine of 4 states, read from the Verilog.

[![Step 1: the receiver open, M ⊨ C green, with its contract and its four states](../assets/demos/escalation/step1-modules.png){ width="870" }](../assets/demos/escalation/step1-modules.png)
_Step 1: the receiver implements its contract (M ⊨ C); its state machine of four states._

**Step 2. The link.** The contracts of the three modules, composed,
[refine](../contracts/checks.md#verification-tasks)
_Functional_ and _Integrity_. With step 1, this proves that the link meets
both requirements, without a check of the whole design. Checked as a
whole, the Verilog of the link meets both too, as it should.

[![Step 2: the link, its tag ⪯ green, each module M ⊨ C green](../assets/demos/escalation/step2-link-refines.png){ width="870" }](../assets/demos/escalation/step2-link-refines.png)
_Step 2: each module implements its contract, and the link refines Functional._

**Step 3. A faster sender.** A sender that pings at every cycle of a ping
request does not implement _Sender_. In the counterexample, the ping
request stays high and so does the pair, which only an escalation may do.
The module check finds the fault in the sender alone; in the whole link,
the same sender makes the receiver escalate on a ping.

[![Step 3: the fast sender, M ⊨ C red; the counterexample in the panel, the broken guarantee in red](../assets/demos/escalation/step5-fast-sender.png)](../assets/demos/escalation/step5-fast-sender.png)
_Step 3: the fast sender does not implement Sender; the guarantee it breaks in red._

## Run it

```
pip install "chase-cps[rtl]"                # with Yosys
chase-cps install nuxmv --accept-license
python escalation.py --expect
```

The files of the demo are in the [repository](https://github.com/chase-cps/demos/tree/main/Escalation); [Running the demos](running.md) says what the scripts print and how to use the diagrams.
