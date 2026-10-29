---
wide: true
---

# Power systems and factories: requirements from patterns

**The question.** The requirements of the power system of an aircraft are
written as patterns over its architecture, not as formulas. Can the
contactors be controlled so that the requirements hold, and if not, which
requirements are in conflict?

```mermaid
flowchart TB
    LG["Left generator"] --- C1(["contactor 1"]) --- LB["Left AC bus"]
    RG["Right generator"] --- C2(["contactor 2"]) --- RB["Right AC bus"]
    LB --- C3(["contactor 3"]) --- RB
    LB --- LR["Left rectifier"] --- LD["Left DC bus"] --- LL["Left load"]
    RB --- RR["Right rectifier"] --- RD["Right DC bus"] --- RL["Right load"]
```

_The architecture of the power system: the controller opens and closes the contactors._

The problem is written in the domain-specific language of CHASE: the
components, their types, how they are connected, and patterns such as
`never-connect(generator, generator, AC bus)`. CHASE turns the patterns into
one contract in GR(1) for the controller of the contactors: its inputs are
the states of the generators and of the contactors, its outputs the
commands of the contactors. The requirements are those of the DATE 2018
paper (Nuzzo et al.): a DC bus is powered by the generator on its side if
possible, a failed generator is disconnected within 15 ms, two generators
are never connected in parallel, and a DC bus is never unpowered for more
than 15 ms. The contactors open and close within 10 ms, and at most one
generator fails.

## The steps

**Step 1. The requirements as written.** They are unrealizable. Of the 28
guarantees, the unrealizable core keeps 4: two generators are never
connected in parallel, and the left DC bus is never unpowered for more than
15 ms. When the left generator fails, the left bus must be switched to the
right generator: contactor 1 opens first, so that the generators are never
connected, and then contactor 3 closes. Each takes up to 10 ms, so the bus
may stay unpowered for more than 15 ms.

**Step 2. Relaxed requirements.** With 30 ms without power for a DC bus
(and 20 ms to disconnect a failed generator), the requirements are
realizable, and slugs synthesizes the controller of the contactors.

**Step 3. A small factory.** The same language describes a factory (FDL
2024): a warehouse, conveyors, machines that turn iron into coins, pipes,
output bays, and gates. Its requirements are realizable.

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install slugs
$> python3
>>> from chase_cps import load_dsl, is_realizable
>>> eps = load_dsl("DATE18/template_0_unrealizable.txt")
>>> r = is_realizable(eps, core=True)
>>> r.status, len(r.core.core.guarantees)
('unrealizable', 4)
>>> is_realizable(load_dsl("DATE18/template_0_realizable.txt")).status
'realizable'
>>> is_realizable(load_dsl("FDL2024/dsl_factory_realizable.txt")).status
'realizable'
```

`load_dsl` reads a file of the domain-specific language into a contract.
The same steps with the console tools of CHASE (`dsl_tool` and slugs) are
in `DATE21/DATE21.md`, the walkthrough of the DATE 2021 University Booth.
