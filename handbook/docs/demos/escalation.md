---
wide: true
---

# Hardware: a security chip checked module by module

**The question.** The escalation link of a security chip is made of a
sender, the wires, and a receiver. Does it meet its requirements, and can we
show it by checking each module on its own?

The link is a toy version of the escalation link of OpenTitan. The sender
raises a differential pair (`esc_p`/`esc_n`) to make the receiver escalate,
and pings the receiver with one-cycle pulses; the receiver answers on a
response pair (`resp_p`/`resp_n`). A wrong wire, a fault or an attack, makes
the two wires of a pair equal, which the receiver and the sender detect. The
contracts are written in [SystemVerilog Assertions](../tools/systemverilog.md),
and each module has its RTL in Verilog.

[![The link: the sender, the channel, and the receiver, each with its RTL, inside the requirements](../assets/diagram-escalation-system.png)](../assets/diagram-escalation-system.png)
_The link: the sender, the channel, and the receiver, each with its RTL, inside the requirements._

## The contracts

- _Sender_ keeps the escalation pair differential, raises it at the cycle
  after an escalation request, and sends a one-cycle pulse for a new ping
  request; it reports a ping answered, and equal response wires.
- _Channel_ carries each wire, or flips it when an error input says so.
- _Receiver_ escalates when the pair stays high for two cycles, answers a
  pulse on the response pair, and signals equal escalation wires back on
  the response pair.
- _Functional_ and _Integrity_ are the requirements, after the end-to-end
  assertions of OpenTitan (`prim_esc_rxtx_assert_fpv`): an escalation
  request held for two cycles escalates the receiver, nothing else does, a
  new ping request is answered, and the sender detects a single wrong
  wire.

## The steps

<div class="tbl-steps" markdown>

| Step | Operation | Result |
|---|---|---|
| 1. Each module | `is_implementation(Model.from_rtl(...), contract)` for the sender, the channel, and the receiver | valid, three times |
| 2. The composition | Sender ∥ Channel ∥ Receiver, with discharge; `refines(..., Functional)`, `refines(..., Integrity)` | valid |
| 3. A cross-check | `is_implementation` of the whole RTL against _Functional_ and _Integrity_ | valid |
| 4. What any sender must do | SenderSlot = Functional / (Channel ∥ Receiver); `refines(Sender, SenderSlot)` | valid |
| 5. A faster sender | `is_implementation` of `esc_sender_fast` against _Sender_, and of the link with it against _Functional_ | invalid: its pulses last two cycles, and a ping escalates the receiver |

</div>

Steps 1 and 2 are the point of the demo: by the theory of contracts, the
three modules together meet the requirements, with no check on the whole
design. Step 3 checks the same on the whole RTL. Step 5 shows what the
checks find when a module breaks its contract.

[![The link inside Functional: the RTL of each module implements its contract (M ⊨ C), and the composition refines Functional (⪯); the receiver shows its contract and its four states](../assets/diagram-escalation-1.png)](../assets/diagram-escalation-1.png)
_The link inside Functional: the RTL of each module implements its contract (M ⊨ C), and the composition refines Functional (⪯); the receiver shows its contract and its four states._

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps[rtl]
$> chase-cps install nuxmv --accept-license
$> python3 Escalation/escalation.py
```

The script also writes `out/escalation.html`, the diagram of the demo with the results of its checks. It opens in a browser: a click on a name shows a contract, and a click on a red tag marks its core.
