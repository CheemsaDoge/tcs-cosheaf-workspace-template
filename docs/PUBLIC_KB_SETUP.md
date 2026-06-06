# Public KB Setup

This workspace has a readonly public KB root and a writable private KB root.
The public KB is shared/common knowledge. Private claims, experiments, notes,
and conjectures belong under `kb/private`.

This repository is the user-facing workspace template. `tcs-cosheaf` is the
framework package, and `tcs-kb-public` is the source of reusable public
knowledge for real work.

Do not manually merge the framework repository, the public KB repository, and
private workspace files into one mixed tree.

## Three Modes

1. Use the tiny seed in this template for demonstration only.
   The seed lets `cosheaf validate`, `cosheaf gate run`, and context-pack
   commands work immediately, but it is not the real public KB.

2. Clone, mount, or replace `kb/public` from `tcs-kb-public` for real work.
   Treat the public KB as readonly from this workspace. Public accepted
   artifacts should come from reviewed `tcs-kb-public` PRs, not from local
   private edits. Validation and gate success are not a substitute for human
   review for accepted public KB artifacts.

3. Advanced users may edit `cosheaf.toml` to point at their own public and
   private roots. Keep the direction clear: private work may depend on public
   accepted artifacts, but public artifacts must not depend on private work.

## Bootstrap A Local Public KB Checkout

The recommended bootstrap command clones `tcs-kb-public` into an ignored runtime
location. It does not change `kb/public`.

```bash
bash scripts/bootstrap_public_kb.sh
```

Default clone target:

```text
.cosheaf/public-kb/tcs-kb-public
```

On Windows PowerShell:

```powershell
.\scripts\bootstrap_public_kb.ps1
```

If the checkout already exists, the script refuses to modify it unless you
explicitly request a fast-forward update:

```bash
bash scripts/bootstrap_public_kb.sh .cosheaf/public-kb/tcs-kb-public --update
```

```powershell
.\scripts\bootstrap_public_kb.ps1 -Update
```

The bootstrap scripts never copy private artifacts into the public KB and never
overwrite an existing non-git directory.

## Use The Checkout

For inspection, open the cloned public KB directly under `.cosheaf/public-kb/`.
For a real workspace root, use one explicit approach:

- Replace this template's demonstration `kb/public` with a checkout or mount of
  `tcs-kb-public` after saving any local work you intentionally want to keep.
- Keep the checkout outside `kb/public` and edit `cosheaf.toml` so the `public`
  KB root points to that location.

Do not copy public accepted artifacts into `kb/private`. Do not place private
conjectures, proof attempts, or draft claims into `kb/public`. Do not promote
private claims to accepted without explicit review and gates.

## Formal Links

Formal links in public KB artifacts are metadata unless a real checker actually
verifies them. Planned links do not mean Lean, CSLib, mathlib, lake, SAT, SMT,
or any other checker has run, and they do not prove informal/formal alignment.
