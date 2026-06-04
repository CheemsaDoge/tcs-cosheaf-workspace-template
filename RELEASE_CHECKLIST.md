# Release Checklist

This workspace template follows the TCS-Cosheaf framework release line and
keeps release-followup changes focused on reproducible workspace setup.

## P0 Exit

- [x] Workspace template CI installs the framework from the immutable `v0.1.0`
  tag:
  `python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.1.0"`.
- [x] Quickstart install guidance uses the framework `v0.1.0` tag instead of
  tracking `main`.
- [x] License policy is Apache-2.0 and the repository includes a root `LICENSE`.
- [x] The private workspace demo is represented by
  `issues/open/issue.example-private-claim.yaml` and
  `kb/private/claims/claim.example-private.yaml`.
- [x] Release follow-up changes do not add new demo scope or alter existing
  artifact content.

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

## P1 Entry

P1 testing hardening may start only after:

- `CheemsaDoge/tcs-cosheaf` has tag `v0.1.0`.
- Public KB CI installs `tcs-cosheaf` from `@v0.1.0`, not `@main`.
- Workspace template CI installs `tcs-cosheaf` from `@v0.1.0`, not `@main`.
- Related P0 release-followup PRs are merged and CI passes.
- No stale P0 issue remains open.

## P1 Workspace Demo Hardening

- [x] Workspace template CI still installs `tcs-cosheaf` from immutable
  `@v0.1.0`.
- [x] Workspace template CI runs workspace info, validation, gatekeeper, PR
  checklist gate, example issue context build, and whitespace checks.
- [x] The clean-clone demo remains a private draft claim depending on the
  public seed definition; no demo artifact is promoted or expanded.
