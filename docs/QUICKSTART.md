# Quickstart

This quickstart starts from `tcs-cosheaf-workspace-template`, the user-facing
workspace template. `tcs-cosheaf` is the framework package, `tcs-kb-public` is
readonly reusable public knowledge, and `kb/private` is the writable private
research overlay.

The included seed files are examples only. Real public KB content should be
mounted or checked out from `tcs-kb-public`, and users should not manually
merge framework, public KB, and private workspace repositories into one mixed
tree.

Run the full template demo with:

```bash
bash scripts/demo_workspace.sh
```

If `make` is available, the same demo path is:

```bash
make demo
```

On Windows environments where `make` or `bash` is not on `PATH`, use an
available Make implementation and pass the Bash executable explicitly, for
example:

```powershell
mingw32-make demo BASH="C:/Program Files/Git/bin/bash.exe"
```

The script runs the same commands below, does not promote artifacts, and keeps
runtime output under ignored paths such as `.cosheaf/` and `context/TASKS/`.

1. Install or make the `cosheaf` CLI available. For release-aligned local
   testing, install the framework package from the `v0.1.1` tag:

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.1.1"
```

Makefile shortcut:

```bash
make install
```

2. Inspect the configured workspace and confirm it has a readonly public root
   and writable private root:

```bash
cosheaf workspace info
```

Makefile shortcut:

```bash
make workspace-info
```

`make workspace` remains available as a compatibility alias for
`make workspace-info`.

3. Validate the loaded public and private KB roots. The template includes a
   tiny public graph definition seed and a private draft claim example:

```bash
cosheaf validate
```

Makefile shortcut:

```bash
make validate
```

4. Run the gatekeeper. Draft examples are not accepted knowledge:

```bash
cosheaf gate run
```

Makefile shortcut:

```bash
make gate
```

5. Rebuild the deterministic local index when you want query/index sidecars:

```bash
cosheaf index rebuild
```

Makefile shortcut:

```bash
make index
```

The index is generated under ignored runtime paths such as `.cosheaf/`; it is
not a source of accepted knowledge.

6. When preparing a PR, run the local PR checklist gate:

```bash
cosheaf gate run --pr-checklist .github/pull_request_template.md
```

Makefile shortcut:

```bash
make pr-checklist
```

7. Build the example issue context pack:

```bash
cosheaf context build issue.example-private-claim
```

Makefile shortcut:

```bash
make context
```

The example issue is `issues/open/issue.example-private-claim.yaml`. It points
to `kb/private/claims/claim.example-private.yaml`, which stays `status: draft`
and depends on the public seed `definition.graph`. Do not promote private
claims to accepted without explicit review and gates.

Keep private research in `kb/private/`. Replace or mount `kb/public/` from the
public KB repository for real work. Do not manually merge the framework,
public KB, and private workspace repositories into one mixed tree.

With `tcs-cosheaf` `v0.1.1`, context packs can display formal-link metadata
from mounted public KB artifacts or from this template's draft public seed. The
display is metadata-only: it does not mean Lean has verified the declaration,
does not mean informal and formal statements are automatically aligned, and does
not add CSLib, mathlib, lake, or Lean dependencies.

Validation and gate success are required workflow checks, but they are not a
substitute for human review for accepted public KB artifacts.

## Using the public graph-theory foundation pack

For real work, update or mount the latest `tcs-kb-public` as the readonly public
KB root. The public graph-theory foundation pack provides accepted definitions
for `definition.vertex`, `definition.edge`, `definition.simple-graph`,
`definition.path`, and `definition.cycle`.

Context packs that include those public artifacts can show their formal-link
metadata alongside the selected artifacts. Treat that display as review context:
the formal links are planned only, planned does not mean checked, Lean has not
run, CSLib symbol existence is not claimed, and informal/formal alignment is not
automatically complete.

Do not copy public accepted artifacts into `kb/private`. Keep `kb/private` for
local drafts and private research, and update or mount `tcs-kb-public` when you
need the latest public foundation definitions.

To clone a local reference checkout of `tcs-kb-public` without modifying this
template's demonstration `kb/public` seed:

```bash
bash scripts/bootstrap_public_kb.sh
```

On Windows PowerShell:

```powershell
.\scripts\bootstrap_public_kb.ps1
```

The checkout is created under `.cosheaf/public-kb/tcs-kb-public`, which is an
ignored runtime location. For details, see `docs/PUBLIC_KB_SETUP.md`.
