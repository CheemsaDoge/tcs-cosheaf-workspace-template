# Cross-Check Demo

This demo exercises the V15 workflow cross-check, gap report, and
checker/cross-check eval surfaces from the workspace template.

Run:

```bash
make crosscheck-demo
```

The script prefers a sibling framework checkout at `../tcs-cosheaf`. When that
checkout is present, it runs:

```bash
python -m cosheaf.cli
```

through `PYTHONPATH` so the workspace can validate framework changes. The
checker/cross-check eval cases live in the framework repository under
`evals/checker_crosscheck/cases.yaml`, so the demo needs a local framework
checkout or an explicit `COSHEAF_CHECKER_EVAL_REPO_ROOT` even when the CLI is
installed from the published tag.

If no local checkout is present, set an explicit framework ref and eval case
root:

```bash
COSHEAF_FRAMEWORK_REF=<tag-or-commit> \
COSHEAF_CHECKER_EVAL_REPO_ROOT=/path/to/tcs-cosheaf \
bash scripts/demo_crosscheck.sh
```

The published `v0.10.0` tag contains the V15 checker/cross-check CLI surface.
The separate eval case file still comes from a framework repository checkout.

The demo:

- inspects the workspace;
- runs validation and gates;
- starts a workflow for `issue.example-private-claim`;
- runs the whitelisted local workflow actions;
- builds a workflow cross-check report;
- builds a workflow evidence report;
- lists workflow gap reports;
- runs `cosheaf eval checker-crosscheck --json` against the framework cases;
- asserts that checked pass, skipped, and inconclusive outputs remain review
  context only;
- reruns validation and gates.

Runtime outputs are ignored and stay under `.cosheaf/crosscheck-demo/`,
`.cosheaf/workflows/`, and `context/TASKS/`.

The demo does not write public KB content, accepted artifacts, source metadata,
verifier results, gate results, promotion records, or human review.
Cross-check reports, gap reports, checker sidecars, and eval output are review
context only. They are not proof, source metadata, human review, verifier pass,
gate pass, accepted status, accepted theorem/refutation, or promotion
authority. Skipped and inconclusive outputs are not passes.
