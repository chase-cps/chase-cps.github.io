---
wide: true
---

# AI agents: decomposing a task

**The question.** An AI agent splits a task among three sub-agents, each
with a contract over its tool calls. Do the contracts of the sub-agents,
together, refine the contract of the parent? If not, what is missing, and
which sub-agent must do it?

[![The plan: the four sub-agents inside the contract of the parent, wired by the variables they share](../assets/diagram-ai-agents-system.png)](../assets/diagram-ai-agents-system.png)
_The plan: the four sub-agents inside the contract of the parent, wired by the variables they share._

## From the task to contracts

The task is in natural language, with rules of the user (task 530b157_1 of
[AppWorld](https://arxiv.org/abs/2407.18901), Trivedi et al., ACL 2024):

> Kristin paid for the groceries. Pay her back on Venmo the amount in her
> text messages, with the note "Groceries", then send her the text message
> "It is done." (a text message, not a voice message).

The rules and what the user asked for become the contract of the parent
agent, a set of formulas over the tool calls. Each tool call of a sub-agent
is a Boolean variable (`tx2`: sub-agent 2 creates a Venmo transaction,
`text3`: sub-agent 3 sends a text, ...), and `paid` is the fact that the
Venmo tool writes once the payment is done.

<div class="tbl-rules" markdown>

| | Rule of the user | Formula |
|---|---|---|
| H1 | the text comes after the payment | `G (text3 -> paid)` |
| H2 | pay once | `G (paid -> G !tx2)` |
| H3 | the note is "Groceries" | `G (tx2 -> desc_ok)` |
| H4 | the text is "It is done." | `G (text3 -> msg_ok)` |
| H5 | no voice message | `G (!voice1 & !voice3)` |
| H6 | the payment is made | `F tx2` |
| H7 | the text is sent | `F text3` |
| H8 | the task is marked complete | `F complete` |

</div>

## The decomposition

The parent splits the task among three sub-agents, in this order, and keeps
the completion of the task. Each sub-agent gets the rules of the tools it
holds, and the payment goes to the only one that holds Venmo:

- _Messages_ (1) finds the amount in the text messages; it holds the tool
  of voice messages, so it guarantees `G !voice1`.
- _Payment_ (2) is the only one with Venmo: H2, H3, and the payment (H6).
- _Text_ (3) sends the text: from the rules of its tools, H1, H4, and
  `G !voice3`.
- _Keep_: the parent marks the task complete (H8).

## The steps

<div class="tbl-steps" markdown>

| Step | Operation | Result |
|---|---|---|
| 1. The decomposition | `refines(Messages || Payment || Text || Keep, Parent)`, with the first contract of _Text_ | invalid: the payment is made, and the text is never sent |
| 2. What sub-agent 3 must do | Q3 = Parent / (Messages ∥ Payment ∥ Keep), with discharge | H1, H4, `G (!voice1 & !voice3)`, and `F text3` |
| 3. The repaired decomposition | `refines(Text, Q3)`, `refines(Messages || Payment || Text || Keep, Parent)` | valid |
| 4. A clause against the rules | `is_consistent(Parent with G !tx2, core=True)` | unsat, with the core `F tx2` and `G !tx2` |

</div>

Following the tools is not enough (step 1): two sub-agents hold the tools
to send the text, so no contract says which one must. The quotient (step 2)
is the weakest contract of sub-agent 3 with which the decomposition meets
the contract of the parent: it asks for the text. Sub-agent 3 with that
clause, starting once the payment is done, refines it, and the
decomposition refines the contract of the parent (step 3). A clause that
contradicts the rules of the user is found by consistency, and the unsat
core points to it (step 4).

Once checked, the contracts of the sub-agents can be enforced on their tool
calls at run time, for instance with
[ContrAgent](https://arxiv.org/abs/2609.18128). The formulas are read on
infinite traces, as CHASE reads them.

[![Step 1: the plan inside the contract of the parent does not refine it (⪯, red). The parent asks for F text3 (H7); Text, with the rules of its tools only, does not promise it](../assets/diagram-ai-agents-1.png)](../assets/diagram-ai-agents-1.png)
_Step 1: the plan inside the contract of the parent does not refine it (⪯, red). The parent asks for F text3 (H7); Text, with the rules of its tools only, does not promise it._

[![Steps 2 and 3: Q3 = Parent / (Messages ∥ Payment ∥ Keep), the hole, is what sub-agent 3 must do: the rules of its tools and F text3. Text, which sends the text once the payment is done, refines it](../assets/diagram-ai-agents-2.png)](../assets/diagram-ai-agents-2.png)
_Steps 2 and 3: Q3 = Parent / (Messages ∥ Payment ∥ Keep), the hole, is what sub-agent 3 must do: the rules of its tools and F text3. Text, which sends the text once the payment is done, refines it._

[![Step 4: a parent that also says "never pay" is inconsistent (G, red); its core, on a red ground, is F tx2 and G !tx2](../assets/diagram-ai-agents-3.png)](../assets/diagram-ai-agents-3.png)
_Step 4: a parent that also says "never pay" is inconsistent (G, red); its core, on a red ground, is F tx2 and G !tx2._

## Run it

```
$> git clone https://github.com/chase-cps/demos && cd demos
$> pip install chase-cps
$> chase-cps install nuxmv --accept-license
$> python3 AIAgents/agents.py
```

The script also writes `out/agents.html`, the diagram of the demo with the results of its checks. It opens in a browser: a click on a name shows a contract, and a click on a red tag marks its core.

The directory also has the task, the decomposition, and the contracts in
words (`requirements.txt`).
