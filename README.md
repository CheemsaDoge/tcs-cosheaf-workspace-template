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

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.1.1"
```

With `tcs-cosheaf` `v0.1.1`, context packs can show formal-link metadata from
public KB artifacts or from this template's draft public seed. Formal links are
metadata-only references to external declarations. They do not mean Lean has
verified the artifact, do not mean the informal statement is automatically
aligned with the formal declaration, and do not add CSLib, mathlib, lake, or
Lean dependencies.

## One-command Demo

Run the workspace demo from a clean clone:

```bash
bash scripts/demo_workspace.sh
```

The demo installs `tcs-cosheaf` from the `v0.1.1` tag, inspects the workspace,
validates the configured public/private KB roots, runs the gatekeeper and PR
checklist gate, and builds context for `issue.example-private-claim`.

The script does not promote artifacts, does not create accepted private claims,
and only writes runtime outputs under ignored runtime paths such as `.cosheaf/`
and `context/TASKS/`. The seed files in this template are examples only, and
the private claim is a draft. For real work, mount or replace `kb/public/` from
`tcs-kb-public`, and keep private drafts and research under `kb/private/`.
Formal links remain metadata only unless a real checker is implemented and run.

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
make install
make workspace
make validate
make gate
make pr-checklist
make context
make demo
```

The Makefile targets are thin wrappers around the same commands shown below.
Only `make install` performs the framework package install. `make demo` delegates
to `scripts/demo_workspace.sh`, which also installs the framework as part of the
full demo path.

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
See `docs/PUBLIC_KB_SETUP.md` for a safe bootstrap flow that clones
`tcs-kb-public` into an ignored local checkout without modifying `kb/public`.

## Using the public graph-theory foundation pack

This workspace uses a readonly public KB root plus a writable private KB
overlay. After updating or mounting the latest `tcs-kb-public`, the public KB
includes accepted graph-theory foundation definitions for vertices, edges,
simple graphs, paths, and cycles.

When a context pack selects those public artifacts, it can display their
formal-link metadata. Those links are planned metadata only: planned does not
mean checked, Lean has not been run, CSLib symbol existence is not claimed, and
informal/formal alignment has not been completed automatically. Do not copy the
public accepted artifacts into `kb/private`; keep private work in the private
overlay and refresh or mount the public KB instead.

To clone a local readonly reference checkout without overwriting the template
seed, run:

```bash
bash scripts/bootstrap_public_kb.sh
```

On Windows PowerShell:

```powershell
.\scripts\bootstrap_public_kb.ps1
```

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
