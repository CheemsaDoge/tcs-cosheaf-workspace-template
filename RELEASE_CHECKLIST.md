# Release Checklist

This workspace template follows the TCS-Cosheaf framework release line and
keeps release-followup changes focused on reproducible workspace setup.

## Current Baseline

- [x] Workspace template CI installs the framework through `make install`,
  which pins the immutable `v0.12.0` tag:
  `python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.12.0"`.
- [x] Quickstart, README, Makefile, and demo scripts use the framework
  `v0.12.0` tag instead of tracking `main`; demos that support local framework
  development still allow explicit local-checkout overrides.
- [x] License policy is Apache-2.0 and the repository includes a root `LICENSE`.
- [x] The private workspace demo is represented by
  `issues/open/issue.example-private-claim.yaml` and
  `kb/private/claims/claim.example-private.yaml`.
- [x] `cosheaf.toml` keeps the public KB root readonly and the private KB root
  writable.
- [x] The demo does not promote artifacts and does not create accepted private
  knowledge.
- [x] Formal-link display remains metadata-only and does not claim Lean,
  CSLib, mathlib, SAT, SMT, or informal/formal alignment verification.
- [x] Operator-session and handoff demo records are review context only; they
  do not write accepted knowledge, create human review, promote artifacts, or
  mutate verifier results.

## Required Checks

Run these before merging release-followup PRs:

```bash
cosheaf workspace info
cosheaf validate
cosheaf gate run
cosheaf gate run --pr-checklist .github/pull_request_template.md
cosheaf context build issue.example-private-claim
git diff --check
```

## Next Framework Entry

Before updating this template to a later framework release:

- `CheemsaDoge/tcs-cosheaf` has a reviewed immutable release tag.
- The README, docs, Makefile, demo scripts, and CI all pin the same tag.
- Public KB compatibility is checked in the separate public KB repository.
- Related release-followup PRs are merged and CI passes.
- No stale release issue remains open.

## Workspace Demo Hardening

- [x] Workspace template CI still installs `tcs-cosheaf` from immutable
  `@v0.12.0`, not `@main`.
- [x] Workspace template CI runs workspace info, validation, gatekeeper, PR
  checklist gate, example issue context build, and whitespace checks.
- [x] The clean-clone demo remains a private draft claim depending on the
  public seed definition; no demo artifact is promoted or expanded.
- [x] Formal-link context display remains metadata-only and does not claim Lean
  verification or automatic informal/formal alignment.

## Operator Session Demo

- [x] `make operator-session-demo` delegates to
  `scripts/demo_operator_session.sh`.
- [x] The demo uses a local `../tcs-cosheaf` checkout when present and falls
  back to the configured `COSHEAF_FRAMEWORK_REF`, which defaults to `v0.12.0`.
- [x] Runtime output stays under ignored `.cosheaf/` and `context/TASKS/`
  paths.
- [x] Handoff export is previewed with `--dry-run`; no `reviews/operator/`
  file is written by the default demo.
- [x] The demo does not modify `kb/public`, write `kb/accepted`, promote
  artifacts, create human review, call hosted providers, require API keys, or
  require MCP.
