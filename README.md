# TCS-Cosheaf Workspace Template

This is the user-facing workspace for using TCS-Cosheaf with a readonly public KB and a writable private KB overlay.

The public KB is common knowledge. The private KB is your own research overlay for conjectures, proof attempts, failures, and work-in-progress claims. Users should not manually merge the framework and KB repositories; `cosheaf.toml` makes them appear as one workspace.

## Layout

- `kb/public/`: readonly public KB root.
- `kb/private/`: writable private KB root.
- `issues/`: local issue drafts when GitHub issues are unavailable.
- `context/`: durable project context and context-pack outputs.
- `reviews/`: human, AI, and gatekeeper review records.
- `experiments/evaluators/`: optional local evaluator scripts.
- `docs/`: workspace guidance.

## Typical Commands

```bash
cosheaf workspace info
cosheaf validate
cosheaf gate run
cosheaf context build <issue-id>
```

The seed files are draft examples only. Replace or mount `kb/public/` from `tcs-kb-public` for real work, and keep private research under `kb/private/`.
