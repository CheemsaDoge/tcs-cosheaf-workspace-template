# Reviewable Workflow Demo

This demo exercises the published `v0.10.0` reviewable-workflow path from the
workspace template. It covers the V14 follow-up surface that is now included in
the published tag.

Run:

```bash
make reviewable-workflow-demo
```

The script prefers a sibling framework checkout at `../tcs-cosheaf`. When that
checkout is present, it runs:

```bash
python -m cosheaf.cli
```

through `PYTHONPATH` so the workspace can validate local framework changes. If
no local checkout is present, the script installs the published `v0.10.0` tag by
default. You can also set an explicit framework ref:

```bash
COSHEAF_FRAMEWORK_REF=<tag-or-commit> bash scripts/demo_reviewable_workflow.sh
```

The published `v0.10.0` tag contains the workflow `draft-proposal` and
`handoff` commands required by this demo.

The demo:

- starts a workflow for `issue.example-private-claim`;
- runs the whitelisted local workflow actions for workspace info, validation,
  gate, and context build;
- checks persisted workflow readiness;
- previews a draft proposal with `--dry-run`;
- builds and scans a workflow handoff packet;
- previews handoff export with `--dry-run`;
- reruns validation and gatekeeper checks.

Runtime outputs are ignored and stay under `.cosheaf/` and `context/TASKS/`.
The demo does not write public KB content, accepted artifacts, source
metadata, verifier results, gate results, promotion records, or human review.
Workflow records, draft proposals, and handoff packets are review context only.
