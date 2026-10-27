# Power systems and factories

These demos write the requirements in a domain-specific language (DSL_tool)
instead of contracts: the components of an architecture, their types, and
patterns of requirements. DSL_tool turns them into a GR(1) specification for
gr1c or slugs.

## Electrical power system (DATE 2018, DATE 2021)

The electrical power system of an aircraft: generators, AC buses, rectifiers,
DC buses, and the contactors between them. The requirements are those of the
DATE 2018 paper:

- if possible, left DC buses shall be powered by left generators;
- failed generators must be disconnected within 15 ms;
- generators shall never connect in parallel through AC buses;
- a DC bus shall never be unpowered for more than 15 ms;

under the assumptions that contactors open and close within 10 ms, that at
most one generator fails, and that the other components do not fail.

```
$> dsl_tool -i DATE21/specs/template_0_unrealizable.txt -o /tmp/eps -b gr1c
$> gr1c -r /tmp/eps.spc
Not realizable.
```

With 20 ms to disconnect a failed generator and 30 ms without power for a DC
bus (`template_0_synthesizable.txt`), the requirements are realizable and gr1c
synthesizes the controller of the contactors. The DATE 2021 University Booth
demo goes through both flows, the DSL one and the logics-based one; its
walkthrough is in `DATE21/DATE21.md`.

## A small factory (FDL 2024)

`FDL2024/dsl_factory_realizable.txt` describes a factory with the same DSL: a
warehouse, conveyors, machines that convert iron into coins, pipes, output
bays, and gates. Its requirements are realizable.
