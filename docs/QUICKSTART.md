# Quickstart

1. Install or make the `cosheaf` CLI available. For release-aligned local
   testing, install the framework package from the `v0.1.1` tag:

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.1.1"
```

2. Inspect the configured workspace and confirm it has a readonly public root
   and writable private root:

```bash
cosheaf workspace info
```

3. Validate the loaded public and private KB roots. The template includes a
   tiny public graph definition seed and a private draft claim example:

```bash
cosheaf validate
```

4. Run the gatekeeper. Draft examples are not accepted knowledge:

```bash
cosheaf gate run
```

5. When preparing a PR, run the local PR checklist gate:

```bash
cosheaf gate run --pr-checklist .github/pull_request_template.md
```

6. Build the example issue context pack:

```bash
cosheaf context build issue.example-private-claim
```

The example issue is `issues/open/issue.example-private-claim.yaml`. It points
to `kb/private/claims/claim.example-private.yaml`, which stays `status: draft`
and depends on the public seed `definition.graph`.

Keep private research in `kb/private/`. Replace or mount `kb/public/` from the
public KB repository for real work.

With `tcs-cosheaf` `v0.1.1`, context packs can display formal-link metadata
from mounted public KB artifacts or from this template's draft public seed. The
display is metadata-only: it does not mean Lean has verified the declaration,
does not mean informal and formal statements are automatically aligned, and does
not add CSLib, mathlib, lake, or Lean dependencies.
