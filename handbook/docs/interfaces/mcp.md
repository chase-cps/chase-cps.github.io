# MCP server for AI agents

[chase-mcp](https://github.com/chase-cps/chase-mcp) is a
[Model Context Protocol](https://modelcontextprotocol.io) server that gives the
operations of CHASE to AI agents as tools. With them, an agent writes
assume-guarantee contracts, composes them, checks refinement, and uses the
counterexamples and the cores to fix the specification. A skill tells the
agent how to use the tools.

## Tools

The tools have the names of the Python package. They are grouped as
follows:

- **Contract algebra**: `compose`, `conjoin`, `disjoin`, `merge`, `divide`,
  `separate`, `imply`, `coimply`, `invert`, `assume`, `ensure`, `saturate`,
  `simplify`.
- **Contract-based verification**: `refines`, `verify`, `is_compatible`,
  `is_consistent`, `is_implementation`, `is_environment`, `is_receptive`,
  `remove_redundant`. `refines` takes `period` and `lipschitz` to check a
  refinement in continuous time.
- **Repair**: `repair`, the values of named constants that make a check
  pass.
- **Queries on formulas**: `implies`, `is_satisfiable`, `unsat_core`.
- **GR(1) synthesis**: `is_realizable`, `synthesize`, `unrealizable_core`,
  `is_well_separated`, `is_vacuous`, and `remove_redundant` with `synth`.
- **Formats**: `parse_spec` and `to_spec` (specification files),
  `parse_sva` and `to_sva` (SystemVerilog Assertions), `rtl_ports` (the
  ports of RTL read with Yosys; RTL is given to `is_implementation` and the
  other checks of state machines), `parse_smv` (an SMV model with its
  `LTLSPEC` and `INVARSPEC`).
- **C programs**: `parse_c` (the contracts written in a C file: clauses of
  ESBMC, CBMC, or ACSL) and `check_c` (each function against its own
  contract, with ESBMC or CBMC).
- **Diagrams**: `visualize`.

A contract is given in JSON:

```json
{"name": "Arbiter",
 "inputs": {"req": "bool", "n": [0, 3]},
 "outputs": {"grant": "bool"},
 "assumptions": ["G F !req"],
 "guarantees": ["G (req -> F grant)"]}
```

## Setup

With [uv](https://docs.astral.sh/uv/) there is nothing to install:
`uvx chase-mcp` downloads and runs the server. Otherwise `pip install
chase-mcp`, and use `chase-mcp` in place of `uvx chase-mcp`. The checks need
nuXmv, and slugs for GR(1) synthesis (see [Installation](../installation.md#the-tools-that-run-the-checks)).

=== "Claude Code"

    The server and the skill are packaged as a plugin:

    ```
    /plugin marketplace add chase-cps/chase-mcp
    /plugin install chase@chase-cps
    ```

    Or only the server: `claude mcp add chase -- uvx chase-mcp`

=== "Codex"

    `codex mcp add chase -- uvx chase-mcp`, or in `~/.codex/config.toml`:

    ```toml
    [mcp_servers.chase]
    command = "uvx"
    args = ["chase-mcp"]
    ```

=== "Cursor, Claude Desktop, Gemini CLI"

    Add the server to the `mcpServers` object of the configuration file
    (`.cursor/mcp.json`, `claude_desktop_config.json`, or
    `~/.gemini/settings.json`):

    ```json
    {"mcpServers": {"chase": {"command": "uvx", "args": ["chase-mcp"]}}}
    ```

=== "VS Code"

    In `.vscode/mcp.json`:

    ```json
    {"servers": {"chase": {"type": "stdio", "command": "uvx", "args": ["chase-mcp"]}}}
    ```

To set the model checker, add `"env": {"CHASE_NUXMV": "/path/to/nuXmv"}` to
the server entry.

## Skill

The skill is in `skills/chase-contracts` of the repository, in the
[Agent Skills](https://agentskills.io) format. It tells the agent:

- how to turn requirements into contracts: the variables and who controls
  them, and one pattern for each requirement;
- which group each tool belongs to;
- how to report a result in the words of the requirements: which
  requirement fails and when, and which parts of an answer hold for every
  behavior and which come from one counterexample.

The skill also works without the server: the agent then uses the Python
package.
