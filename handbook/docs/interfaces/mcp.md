# MCP server for AI agents

[chase-mcp](https://github.com/chase-cps/chase-mcp) is a
[Model Context Protocol](https://modelcontextprotocol.io) server that gives the
operations of CHASE to AI agents as tools. An agent can write
assume-guarantee contracts, compose them, check refinement, and use the
counterexamples and the cores to fix the specification. A skill tells the
agent how to use the tools.

## Tools

The 30 tools follow the three layers; their names are those of the Python
package.

| Layer | Tools |
|---|---|
| 1. Contract algebra | `compose`, `conjoin`, `disjoin`, `merge`, `divide`, `separate`, `imply`, `coimply`, `invert`, `assume`, `ensure`, `saturate`, `simplify` |
| 2. Contract-based verification | `refines`, `verify`, `is_compatible`, `is_consistent`, `is_implementation`, `is_environment`, `is_receptive`, `remove_redundant` |
| 2. Queries on formulas | `implies`, `is_satisfiable`, `unsat_core` |
| 3. GR(1) synthesis | `is_realizable`, `synthesize`, `unrealizable_core`, `is_well_separated`, `is_vacuous`; `remove_redundant` with `synth` |
| Specifications | `parse_spec`, `to_spec` |
| SystemVerilog Assertions | `parse_sva`, `to_sva` |

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
nuXmv, and slugs for GR(1) synthesis (see [Installation](../getting-started/install.md)).

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
[Agent Skills](https://agentskills.io) format. It tells the agent how to turn
requirements into contracts (variables and who controls them, one pattern per
requirement), which layer each tool belongs to, and how to explain a
counterexample. It also works without the server: the agent then uses the
Python package. Its examples are run by the tests of the repository, so the
results they state are those CHASE returns.
