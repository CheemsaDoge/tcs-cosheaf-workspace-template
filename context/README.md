# Context

Record durable workspace context and context-pack outputs here. Chat transcripts
are not durable project memory.

The example demo issue can build a local context pack with:

```bash
cosheaf context build issue.example-private-claim
```

Generated context packs are task-scoped outputs under `context/TASKS/`. Keep
them focused on the active issue rather than treating chat history as project
state.

With `tcs-cosheaf` `v0.1.1`, the generated context pack may include compact
formal-link metadata for relevant artifacts. That display is metadata-only: it
does not claim Lean verification and does not claim the informal statement has
been semantically aligned with the formal declaration.

## Using the public graph-theory foundation pack

When this workspace mounts or refreshes the latest `tcs-kb-public`, context
packs can select accepted public graph-theory foundation artifacts such as
`definition.vertex`, `definition.edge`, `definition.simple-graph`,
`definition.path`, and `definition.cycle`. If those artifacts are relevant to
the issue being packed, their planned formal-link metadata appears in the
context output.

That output is informational only. Planned links are not checked links, Lean is
not executed, CSLib symbol existence is not claimed, and informal/formal
alignment remains a separate human review concern.
