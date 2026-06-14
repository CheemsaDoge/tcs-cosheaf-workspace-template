# Verification Workflow Demo

This workspace demo shows how a user can inspect verifier and promotion
readiness evidence without installing SAT, SMT, Lean, lake, hosted providers,
or MCP.

Run:

```bash
bash scripts/demo_verifier_evidence.sh
```

Or:

```bash
make verifier-evidence-demo
```

The script installs the framework source configured by
`COSHEAF_FRAMEWORK_REF` unless `COSHEAF_SKIP_INSTALL=1` is set. For local
framework development, run:

```bash
COSHEAF_SKIP_INSTALL=1 \
PYTHONPATH=../tcs-cosheaf \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/demo_verifier_evidence.sh
```

## What It Runs

The demo writes JSON outputs under `.cosheaf/verifier-evidence-demo/` and
runs:

1. `cosheaf workspace info --json`
2. `cosheaf validate --json`
3. `cosheaf gate run --json`
4. A local check of the gate report showing that G6 verifier status is
   `skipped` or `not_applicable`, not `pass`
5. `cosheaf promotion readiness --artifact claim.example-private --json` when
   the installed framework exposes that command

If the installed framework does not expose a later optional command, the demo
writes an explicit `unavailable` JSON record and treats that as not-a-pass.

## Expected Result

The template's private example claim is intentionally not promotion-ready. The
readiness report should keep `accepted_write_performed: false` and should show
blocking reasons such as draft status and missing human review.

That result is expected. It demonstrates that:

- validation/gate output is workflow evidence, not accepted status;
- skipped or unavailable verifier paths are not passes;
- promotion readiness is read-only and advisory;
- private draft claims stay under `kb/private`;
- no accepted artifacts are written;
- no human review is created;
- no hosted provider call or API key is required.

## Boundaries

This demo does not run a theorem prover, does not prove Lean/mathlib/CSLib
semantic alignment, does not autoformalize statements, does not promote
artifacts, and does not replace human review.
