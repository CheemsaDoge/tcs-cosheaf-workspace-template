# Operator Session Demo

This demo shows the workspace side of the `v0.10.0` operator-session and
review-handoff workflow. It is a local, review-only workflow for the example
private issue; it is not an agent runtime and it does not add accepted
knowledge.

Run:

```bash
make operator-session-demo
```

or:

```bash
bash scripts/demo_operator_session.sh
```

The script automatically uses `../tcs-cosheaf` when that checkout exists. This
lets framework development exercise local operator-session changes while the
workspace default remains pinned to the published `v0.10.0` tag. When no local
checkout is available, the script installs:

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.10.0"
```

Override the source with `COSHEAF_FRAMEWORK_REF=<ref>`, or use an explicit
local command:

```bash
COSHEAF_SKIP_INSTALL=1 \
PYTHONPATH="$(pwd)/../tcs-cosheaf" \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/demo_operator_session.sh
```

## Flow

The demo:

1. locates a local framework checkout or installs the configured framework ref;
2. runs `cosheaf workspace info --json`;
3. runs `cosheaf validate --json`;
4. runs `cosheaf gate run --json`;
5. builds context for `issue.example-private-claim`;
6. builds a strategy plan from the context pack;
7. starts a `private_research` operator session;
8. appends validation and gate check summaries;
9. appends skipped test and eval summaries, explicitly not pass evidence;
10. appends private draft and runtime references;
11. finalizes and scans the session;
12. builds and shows a handoff bundle; and
13. previews handoff export with `--dry-run`.

Runtime JSON outputs are written under:

```text
.cosheaf/operator-session-demo/
.cosheaf/operator-sessions/<session-id>/
.cosheaf/strategy/<plan-id>/
context/TASKS/issue.example-private-claim/
```

These paths are ignored runtime paths.

## Authority Boundary

Operator-session records and handoff bundles are review context only. They are
not proof, verifier evidence, verifier pass, gate pass, public KB source
metadata, human review, accepted status, accepted refutation, or promotion
authority.

The demo does not:

- call hosted providers;
- require API keys;
- start or require MCP;
- modify `kb/public`;
- write `kb/accepted`;
- promote artifacts;
- mutate verifier results;
- create human review; or
- persist `reviews/operator/` handoff YAML.

The handoff export command is run with `--dry-run` only. To persist review
context intentionally, use the framework CLI separately and review the export
before committing it.

## Public And Private KB Boundaries

The demo uses the example issue and private draft claim from this template:

```text
issues/open/issue.example-private-claim.yaml
kb/private/claims/claim.example-private.yaml
```

The session policy is `private_research` because the demo references private
workspace material. Real public KB content should still come from
`tcs-kb-public`, and public accepted artifacts still require source metadata,
human review, validation, and gates. Validation, gate, session scan, and
handoff success are not substitutes for human review.

Formal links remain metadata only unless a real checker verifies them. Planned
formal links do not mean Lean, CSLib, mathlib, SAT, SMT, or informal/formal
alignment has been checked.
