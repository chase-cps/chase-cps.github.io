# Running the demos

Each demo is a directory of the [demos](https://github.com/chase-cps/demos)
repository. Its page ends with the commands that run it.

## Install

The Python package and the back ends that a demo uses:

```
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license
$> chase-cps install slugs
```

- nuXmv checks refinement, compatibility, and consistency;
- slugs checks realizability and synthesizes controllers (GR(1));
- `pip install "chase-cps[z3]"` adds z3, for the contracts over real
  numbers and for repair;
- `pip install "chase-cps[rtl]"` adds Yosys, which reads the RTL;
- ESBMC or CBMC checks the C programs.

The [Docker image](../installation.md#the-docker-image) has all of them but nuXmv, whose
license does not allow redistribution: `chase-cps install nuxmv
--accept-license` adds it in a container.

## The scripts

Each demo has a Python script, named after the demo. The script prints the
result of each step, with the counterexamples, and writes the diagrams of
the demo in `out/`. With `--expect`, the script also compares each result
with the one on the page, and exits with code 1 when one differs.

```
$> python heater.py --expect
```

Some demos also have a `diagram.sh`, which writes the same diagrams with the
command line (`chase-cps view`).

## The diagrams

The pages in `out/` open in a browser. On a diagram:

- a box is a contract or a component; a box inside another refines it;
- the tags next to a name are its checks: green holds, red does not;
- a click on a red tag opens the panel with the counterexample; the slider
  steps through it, and the values appear on the ports;
- the wrench at the top opens and closes the panel; it lists the checks
  that fail;
- Esc closes the help, then the panel.

The [Diagrams](../interfaces/diagrams.md#what-is-drawn) page says what each
box and tag means.
