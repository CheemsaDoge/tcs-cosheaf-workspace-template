# TCS-Cosheaf Workspace Template

This is a user-facing workspace template for using TCS-Cosheaf with a readonly
public KB and a writable private KB overlay.

`tcs-cosheaf` is the framework repository. It provides the CLI, schemas,
validation, gates, graph tools, and context-pack tooling. `tcs-kb-public` is the
readonly public reusable KB. `kb/private` is the user's writable research
overlay for conjectures, proof attempts, failures, and work-in-progress claims.

Users should not manually merge framework and KB repositories. Install or use
the framework package, mount or replace `kb/public` from `tcs-kb-public`, and
keep private work under `kb/private`.

With `tcs-cosheaf` `v0.1.1`, context packs can show formal-link metadata from
public KB artifacts or from this template's draft public seed. Formal links are
metadata-only references to external declarations. They do not mean Lean has
verified the artifact, do not mean the informal statement is automatically
aligned with the formal declaration, and do not add CSLib, mathlib, lake, or
Lean dependencies.

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
cosheaf gate run --pr-checklist .github/pull_request_template.md
cosheaf context build <issue-id>
```

The seed files are draft examples only. Replace or mount `kb/public/` from
`tcs-kb-public` for real work, and keep private research under `kb/private`.
When the mounted public KB contains formal-link metadata, context packs display
that metadata as review context only, not as a proof or alignment claim.

## Policy

- Private artifacts may depend on public artifacts.
- Public artifacts must not depend on private artifacts.
- Accepted artifacts require review and gates.
- Public accepted artifacts require structured source metadata.
- Do not create accepted private claims without explicit review and gates.
- Do not import papers or private notes into this template.

## License

This workspace template is released under the Apache-2.0 license. See
`LICENSE`.
