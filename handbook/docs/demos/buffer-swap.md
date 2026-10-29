# BufferSwap: replacing a block of a circuit

**The question.** A buffer of a circuit is replaced by a smaller one, whose
contract does not refine the old one. Can it take its place, and what must
any buffer in that place satisfy?

A producer sends data to a consumer through a buffer, with a ready/valid
handshake. The buffer is `bsg_two_fifo` of BaseJump STL, a FIFO of two
entries. The demo replaces it with `bsg_one_fifo`, a FIFO of one entry,
which is smaller, and checks that the system still meets its requirements.
The contracts are written in [SystemVerilog Assertions](../tools/systemverilog.md),
and the RTL is that of BaseJump STL.

```mermaid
flowchart LR
    P["Producer"] -- "v_i, data_i" --> B["Buffer: bsg_two_fifo, then bsg_one_fifo"]
    B -- "ready_o" --> P
    B -- "v_o, data_o" --> C["Consumer"]
    C -- "yumi_i" --> B
```

## The contracts

- _Producer_ keeps offering a value (`v_i`) until the buffer takes it
  (`ready_o`).
- _Consumer_ takes a value (`yumi_i`) only when the buffer offers one
  (`v_o`), and takes what is offered sooner or later.
- _TwoFifo_ and _OneFifo_ assume what the consumer guarantees. They keep what
  they offer until it is taken, take a value when they are empty and after a
  value is taken, and offer at the next cycle what they take. _TwoFifo_ takes
  a second value when it holds one; _OneFifo_ does not.
- _System_: every offer is taken sooner or later, and what the buffer offers
  stays until it is taken.

## The steps

| Step | Operation | Result |
|---|---|---|
| 1. The old system | Producer ∥ TwoFifo ∥ Consumer, with discharge; `refines(..., System)` | valid |
| 2. The new buffer against the old one | `refines(OneFifo, TwoFifo)` | invalid: with a value in, _OneFifo_ takes no other |
| 3. What the place of the buffer needs | Slot = System / (Producer ∥ Consumer), with discharge; `refines(OneFifo, Slot)` | valid, and the new system refines _System_ |
| 4. The contract for the RTL | `to_sva(Slot)`, `is_implementation(Model.from_rtl(...), Slot)` | `bsg_one_fifo` implements _Slot_; Jasper proves it too |

The new buffer is not a refinement of the old one, so its contract alone
does not say that it can replace it (step 2). The quotient answers the
question (step 3): it is the weakest contract with which the system meets
its requirements, here the guarantees of the system under the guarantees of
the producer and of the consumer. Any buffer that refines it can take the
place, and the new buffer does. Step 4 checks the same on the RTL, not only
on the contracts.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps[rtl]
$> chase-cps install nuxmv --accept-license
$> python3 BufferSwap/bufferswap.py
```

`jasper/run.tcl` proves the contract of the place (`out/slot.sv`, written by
the script) on the RTL of `bsg_one_fifo` with Jasper.
