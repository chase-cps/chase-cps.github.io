# Specification language and console

## Specification files

The specification files (`.ltl`) are written in the logics language of
CHASE. They are read by the console, by `chase_cps.load_spec`, and by
`chase-cps check`.

```
NAME: arbiter;

CONTRACT Spec:
    input boolean variable req;
    output boolean variable grant;
    input integer (0:3) variable n;
    Assumptions:
        G(F(!(req)));
    Guarantees:
        G(req -> F(grant));
```

- `NAME: name;` names the system; `CONTRACT name:` starts a contract.
- Variables: `input` or `output`, `boolean`, `integer (low:high)`, or `real`,
  then `variable name;`. An integer without a range ranges over 0 to 16;
  `load_spec` and `parse_spec` warn when an integer is compared with a
  constant outside its range, since the comparison then has the same value
  at every step.
  Declarations outside the contracts are shared: each contract gets those it
  uses. A real is declared without a range (the Python package rejects
  `real (low:high)`: write the range as an assumption). Constants are
  declared as `integer constant N 5;` or `real constant K 2.5;`, and
  propositions as `proposition p is x > 3;`.
- `Assumptions:` and `Guarantees:` list formulas, each ending with `;`.
- Formulas: `!` (or `~`), `&` (or `/\`), `|` (or `\/`), `->`, `<->`, `G`,
  `F`, `X`, `U`, `R`,
  `P(...)` (probability), `true`, `false`, the relations
  `= != < <= > >=`, the arithmetic `+ - * /`, and `x'` for the value of `x`
  in the next step. `#` starts a comment.

All the binary operators have the same precedence, and `G`, `F`, `X` bind
looser than them: `G a -> b` is `G (a -> b)`. Parentheses avoid surprises.


## The console of logics_tool

`logics_tool` reads a specification file and runs commands, interactively or
from a script:

```
$> logics_tool -i specs.ltl -o out/ -c script.chase
```

The commands have the names of the operations of the
[contract algebra](../contracts/algebra.md) (`compose C1 C2 R`,
`conjoin C1 C2 R`, `divide C1 C2 R`, ...), plus `saturate C`, `simplify C`,
`show C`, `verify C file`, `refines C1 C2 file`, and
`synthesize C file solver`. The console also accepts the names of its first
version: `conjunction` for `conjoin`, `quotient` for `divide`, and
`refinement` for `refines`.

In the console, the variables of two contracts are matched by name (the
default), by a map entered by hand (`manual` as last argument), or by a map
read from a file (its name as last argument).

The console writes the input files of the external tools, to be run by hand:
an SMV model for `verify` and `refines`, a slugs or gr1c specification for
`synthesize`. The Python package, the command line, and the MCP server run
the tools and return the result. When the SMV file has real variables or
real numbers, the console says so: NuSMV cannot read it, and nuXmv checks it
with its SMT engine:

```
$> nuXmv -int refinement.smv
nuXmv > go_msat
nuXmv > check_ltlspec_ic3
```
