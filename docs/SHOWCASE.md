# Showcase Demo

This showcase is the shortest public demo for the three-repository
TCS-Cosheaf workflow. It starts from this workspace template, uses the
framework package as a CLI dependency, keeps public KB content readonly, keeps
private research under `kb/private`, and builds context for an example private
draft claim.

The demo is safe by design:

- It does not require hosted LLMs.
- It does not require private data.
- It does not promote artifacts.
- It does not create accepted private knowledge.
- It does not claim production readiness.
- It treats formal links as metadata unless a real checker runs and records a
  result.

## What The Demo Shows

The workflow demonstrates:

1. Clone or fork this workspace template.
2. Install the pinned framework package.
3. Bootstrap a local reference checkout of `tcs-kb-public` under `.cosheaf/`.
4. Inspect the public/private KB roots.
5. Validate the workspace.
6. Run the gatekeeper and PR checklist gate.
7. Rebuild the deterministic local index.
8. Build a context pack for the example private issue.
9. Optionally run a local dry-run worker if the installed framework version
   supports that CLI surface.
10. Optionally inspect verifier-gate and promotion-readiness boundaries.
11. Optionally run the V15 workflow cross-check and checker/cross-check eval
    path against a local framework checkout.
12. Confirm no accepted auto-promotion happened.

## Run It

From a clean clone:

```bash
bash scripts/demo.sh
```

The script writes runtime outputs only under ignored locations such as
`.cosheaf/` and `context/TASKS/`. The public KB bootstrap checkout is placed
under `.cosheaf/public-kb/tcs-kb-public` so it does not overwrite the template
seed at `kb/public`.

If you want the older minimal demo path, run:

```bash
bash scripts/demo_workspace.sh
```

To inspect verifier and promotion-readiness boundaries without API keys,
hosted providers, MCP, or mandatory SAT/SMT/Lean installations, run:

```bash
bash scripts/demo_verifier_evidence.sh
```

That script writes JSON under `.cosheaf/verifier-evidence-demo/` and treats
skipped, not-applicable, or unavailable verifier/readiness paths as not-a-pass.

To inspect the V15 workflow cross-check, gap report, and checker/cross-check
eval path against a local framework checkout, run:

```bash
make crosscheck-demo
```

That target writes JSON under ignored `.cosheaf/` runtime paths. Cross-check
reports, gap reports, checker sidecars, and eval output are review context
only: not proof, source metadata, verifier pass, gate pass, human review,
accepted status, accepted theorem/refutation, or promotion authority.

To run the canonical CLI-first AI math collaborator walkthrough, run:

```bash
make ai-math-collaborator-demo
```

That target composes existing demo paths plus the smoke benchmark/report
commands. It writes only ignored runtime output and remains review context:
not a hosted provider run, MCP requirement, accepted write, public KB mutation,
promotion, or human review.
If benchmark eval cases are not present in the selected repo root, the
benchmark rows are recorded as skipped rather than treated as passes.

## Commands

The showcase script runs the same core commands that a user can run manually:

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.12.0"
bash scripts/bootstrap_public_kb.sh .cosheaf/public-kb/tcs-kb-public
cosheaf workspace info
cosheaf validate
cosheaf gate run
cosheaf gate run --pr-checklist .github/pull_request_template.md
cosheaf index rebuild
cosheaf context build issue.example-private-claim
```

If `.cosheaf/public-kb/tcs-kb-public` is already a git checkout, the showcase
script uses `--update` so the repeated demo path attempts only a fast-forward
update.

The optional dry-run worker is skipped when the pinned framework version does
not expose `cosheaf orchestrator run`. A skipped optional dry-run is not a
verification pass and is not required for the basic workspace demo.

The verifier-evidence demo also treats skipped or unavailable optional
verification surfaces as not-a-pass. Promotion-readiness output is advisory and
read-only; it does not write accepted knowledge or replace human review.

## Accepted vs Draft

The included private claim is:

```text
kb/private/claims/claim.example-private.yaml
```

It is `status: draft`. It is example private research context, not accepted
knowledge.

The included public seed is:

```text
kb/public/definitions/definition.graph.yaml
```

It is also `status: draft` and exists only so a clean clone can validate and
build context immediately. For real work, mount or replace the public KB root
with reviewed accepted knowledge from `tcs-kb-public`.

Validation and gate success are necessary workflow checks, but they are not
human review. Accepted public KB artifacts still require source metadata,
human review, and a reviewed public KB PR. Private claims must not be promoted
to accepted without explicit review and gates.

## Formal-Link Boundary

The template seed may contain planned formal-link metadata. Planned links do
not mean Lean, CSLib, mathlib, SAT, SMT, or any other checker has run. A
context pack can display formal-link metadata as review context, but that
display is not proof and does not establish informal/formal semantic
alignment.

`formal-libs/lean-libraries.example.yaml` is present only so the seed's planned
`cslib-main` reference has a local manifest record for G10 metadata checks. It
is not a CSLib checkout, not a Lean run, and not formal verification evidence.

## What This Demo Is Not

- It is not a web application.
- It is not a production deployment.
- It is not an automatic theorem prover.
- It is not Lean autoformalization.
- It is not a hosted LLM agent runtime.
- It is not public KB promotion.
