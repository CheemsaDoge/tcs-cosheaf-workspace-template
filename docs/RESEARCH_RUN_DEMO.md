# Research Run Demo

This demo shows how a workspace user can drive the v0.6.0 external-operator
run loop through the Cosheaf CLI and Git-oriented workflow.

It is not an embedded agent runtime, not an MCP workflow, and not a hosted
provider workflow. It does not use API keys.

## Run

```bash
bash scripts/demo_research_run.sh
```

With Make:

```bash
make research-run-demo
```

The script installs the framework from the published `v0.6.0` tag by default.
Override the source with:

```bash
COSHEAF_FRAMEWORK_REF=<ref> bash scripts/demo_research_run.sh
```

To run against a local framework checkout:

```bash
COSHEAF_SKIP_INSTALL=1 \
PYTHONPATH="$(pwd)/../tcs-cosheaf" \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/demo_research_run.sh
```

## What It Does

The script:

1. starts a research run for `issue.example-private-claim`;
2. records `workspace info`, `validate`, `gate run`, memory search, and context
   build commands;
3. records the context pack and validation/gate outputs as run outputs;
4. checks that the checked-evidence CLI surface is visible without staging
   checked evidence;
5. records a skipped checked-evidence note as skipped, not pass;
6. reruns validation and gate;
7. finalizes the research run;
8. emits evidence-report and replay-plan JSON;
9. previews `export-review` with `--dry-run`;
10. reruns workspace validation and gate after the dry-run export.

Default outputs are written under ignored runtime paths:

```text
.cosheaf/research-run-demo/
.cosheaf/runs/<run-id>/run.json
```

The default script does not write `reviews/runs/`. To explicitly export a
review record, set:

```bash
COSHEAF_RESEARCH_DEMO_EXPORT_REVIEW=1 bash scripts/demo_research_run.sh
```

That writes a controlled review export under `reviews/runs/<run-id>.yaml`.
Review exports are still provenance only.

## Boundaries

Research-run records are provenance only. They are not proof, verifier pass,
gate pass, human review, accepted status, accepted refutation, or promotion
authority.

The demo does not:

- call hosted providers;
- require MCP;
- write accepted knowledge;
- promote artifacts;
- mark human review complete;
- run Lean, SAT, SMT, lake, CSLib, or mathlib;
- claim planned formal links are checked.

The included seed files are examples only. Real public KB content should be
mounted or checked out from `tcs-kb-public`, and private conjectures or proof
attempts belong under `kb/private`.

