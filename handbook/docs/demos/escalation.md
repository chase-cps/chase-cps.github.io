---
wide: true
---

# Hardware: a security chip checked module by module

**The question.** The escalation link of a security chip is made of a
sender, the wires, and a receiver. Does it meet its requirements, and can we
show it by checking each module on its own?

[![The link: the sender, the channel, and the receiver, each with its RTL, inside the requirements](../assets/diagram-escalation-system.png)](../assets/diagram-escalation-system.png)
_The link: the sender, the channel, and the receiver, each with its RTL, inside the requirements._

The link is a toy version of the escalation link of OpenTitan. The sender
raises a differential pair to make the receiver escalate, and pings the
receiver with one-cycle pulses; the receiver answers on a response pair. A
wrong wire makes the two wires of a pair equal, which the receiver and the
sender detect. The requirements, _Functional_ and _Integrity_, follow the
end-to-end assertions of OpenTitan. The contracts are written in
[SystemVerilog Assertions](../tools/systemverilog.md), and each module has
its RTL in Verilog.

## The steps

**Step 1. Each module.** The RTL of the sender, of the channel, and of the
receiver implements its contract.

**Step 2. The composition.** _Sender_ ∥ _Channel_ ∥ _Receiver_ refines
_Functional_ and _Integrity_. By the theory of contracts, the three modules
together meet the requirements, with no check on the whole design.

[![Steps 1 and 2: each RTL implements its contract, and the composition refines Functional; the receiver with its four states](../assets/diagram-escalation-1.png)](../assets/diagram-escalation-1.png)
_Steps 1 and 2: each RTL implements its contract, and the composition refines Functional; the receiver with its four states._

**Step 3. A cross-check.** The whole RTL, checked directly, meets
_Functional_ and _Integrity_ too.

**Step 4. What any sender must do.** SenderSlot = Functional / (Channel ∥
Receiver), and the contract of the sender refines it.

**Step 5. A faster sender.** A sender that pings at every cycle of a ping
request does not implement the contract of the sender: its pulses last two
cycles, and in the whole link a ping escalates the receiver.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps[rtl]
$> chase-cps install nuxmv --accept-license
$> python3 Escalation/escalation.py
```

The script prints the result of each step and writes `out/escalation.html`,
the diagram above, to open in a browser: a click on a name opens a
contract, and a click on the state icon opens the model.
