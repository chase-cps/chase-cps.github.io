# C programs

A C function is a component that answers once: its parameters are the
inputs of the contract, by name, and its return value is the output; a
pointer parameter named as an output is written by the function. The
formulas of such a contract have no temporal operator. `is_implementation`
takes a `CFunction` and checks it with
[ESBMC](https://esbmc.org/) or, without it, [CBMC](https://www.cprover.org/cbmc/)
(`chase-cps install esbmc` on Linux, `brew install esbmc` on macOS):

````
from chase_cps import CFunction, Contract, is_implementation

open("saturate.c", "w").write("""
int saturate(int x, int lo, int hi) {
    if (x < lo) return lo;
    if (x > hi) return hi;
    return x;
}
""")
sat = Contract.from_strings(name="Sat",
                            inputs={"x": (-1000, 1000), "lo": (-100, 100), "hi": (-100, 100)},
                            outputs={"y": (-1000, 1000)}, assumptions=["lo <= hi"],
                            guarantees=["y >= lo & y <= hi", "(x >= lo & x <= hi) -> y = x"])
r = is_implementation(CFunction("saturate.c", "saturate"), sat)
print(r.status, r.backend)       # valid esbmc
````

The checker calls the function with any values of the inputs, within
their types and the assumptions, and checks the guarantees on what it
returns. A failure gives the values of a call that breaks them (the
trace). The checkers also check the function itself: an arithmetic
overflow, a division by zero, or an access out of bounds makes the result
invalid, with the property in the `reason`. Loops are unwound up to
`unwind` times (20, `is_implementation(f, c, unwind=100)`); a loop that
needs more makes the result unknown.

Integers are compared as integers (in `long long`); a real variable is a
`double` or a `float` of the function, and its formulas are computed in
`double`, with rounding. Words are not written in C yet. On the command
line: `chase-cps check spec.ltl --impl saturate.c:saturate Sat`.

A function called once per step (a controller) implements a contract over
steps too. The contract has no assumption, and each guarantee is a formula
of one step `phi` at some steps: `phi`, `X phi`, `G phi`, or
`G[a,b] phi`. Each step of the system is a call on inputs that nothing
constrains, so the function implements the contract exactly when each call
satisfies every such `phi`: the checker checks one call, and a call that
breaks one, repeated at every step, is the counterexample.

````
from chase_cps import CFunction, is_implementation, parse_spec

open("heater.c", "w").write("""
int thermostat(int T) {
    if (T < 74)
        return 3;
    return 0;
}
""")
c = parse_spec("""NAME: t;
CONTRACT Thermostat:
    input integer (0:200) variable T;
    output integer (0:3) variable u;
    Assumptions:
        true;
    Guarantees:
        G[0,9] ((T < 74 -> u = 3) & (T >= 74 -> u = 0));
""")
is_implementation(CFunction("heater.c", "thermostat"), c["Thermostat"]).status   # valid
````

The result is unknown, with the reason, for a function that keeps a state
between calls (a static variable, or a global variable of its file that it
uses), and for a contract that does not have this form (`T' = T + u - 1`
relates two steps).

The contract can be written in the C file, next to the code, in the
clauses of ESBMC (`__ESBMC_requires(...)`, `__ESBMC_ensures(...)` in the
body, `__ESBMC_return_value`) or of CBMC (`__CPROVER_requires(...)`,
`__CPROVER_ensures(...)` between the signature and the body,
`__CPROVER_return_value`), or in ACSL, the language of Frama-C (a comment
`/*@ requires ...; ensures ...; */` just before the function, with
`\result`, `==>`, `<==>`, and chains such as `0 <= T <= 200`; `\old`,
`\at`, the quantifiers, and behaviors are not read). `load_c` (it gives `{name: (contract, function)}`) reads each function of the file as a
contract and the function as its implementation: the requires clauses are
the assumptions, the ensures clauses the guarantees, the parameters the
inputs, the return value the output `FUNCTION_out`, and `*p` the output
`p` of a pointer parameter. The ranges of the inputs are those of their C
types, narrowed by the bounds the requires clauses give:

````
from chase_cps import is_implementation, load_c

open("thermostat.c", "w").write("""
int thermostat(int T)
{
    __ESBMC_requires(T >= 0 && T <= 200);
    __ESBMC_ensures(T >= 74 || __ESBMC_return_value == 3);
    __ESBMC_ensures(T < 74 || __ESBMC_return_value == 0);
    return T < 74 ? 3 : 0;
}
""")
c, f = load_c("thermostat.c")["thermostat"]
print(c.inputs, is_implementation(f, c).status)   # {'T': (0, 200)} valid
````

The clauses are expressions of C over numbers and Booleans (`&& || ! ==
!= < <= > >= + - * /`); a conditional (`a ? b : c`) is not read. The
clauses on pointers (`is_fresh`, `r_ok`, `w_ok`, `rw_ok`, `assigns`) are
not part of the contract. The function is checked with the clauses taken
out of the code, so either checker checks a file with the clauses of the
other. A function with no clause has a contract with no term: its check
is that of the code alone (overflow, division by zero, access out of
bounds, failed assert).

`chase-cps view FILE.c` (and the CHASE button of VS Code on a `.c` file)
draws each function as a component with its code, checked: the tag
`M ⊨ C` for a function with clauses, and `safe` for one with none. A
failure shows the call that breaks it, and the term it breaks in red.
