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

For the public showcase flow, including public KB bootstrap, index rebuild,
context build, and optional local dry-run worker when supported by the
installed framework, run:

```bash
bash scripts/demo.sh
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
   testing, install the framework package from the `v0.12.0` tag:

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.12.0"
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
and depends on artifact id `definition.graph`.

In a clean clone, `definition.graph` is provided by the template's local draft
public seed so the demo can run immediately. For real work, mount or check out
`tcs-kb-public` as the readonly public KB so `definition.graph` resolves to
reviewed accepted public knowledge. Do not promote private claims to accepted
without explicit review and gates.

Keep private research in `kb/private/`. Replace or mount `kb/public/` from the
public KB repository for real work. Do not manually merge the framework,
public KB, and private workspace repositories into one mixed tree.

With `tcs-cosheaf` `v0.12.0`, context packs can display formal-link metadata
from mounted public KB artifacts or from this template's draft public seed. The
display is metadata-only: it does not mean Lean has verified the declaration,
does not mean informal and formal statements are automatically aligned, and does
not add CSLib, mathlib, lake, or Lean dependencies.

The template includes `formal-libs/lean-libraries.example.yaml` so the draft
seed's planned `cslib-main` reference resolves during G10 metadata checks. That
manifest is an example placeholder, not evidence that CSLib was fetched, built,
or checked.

Validation and gate success are required workflow checks, but they are not a
substitute for human review for accepted public KB artifacts.

## CLI-agent and provider smoke commands

For the CLI-first agent workflow, run:

```bash
make cli-agent-demo
```

That demo writes JSON output under `.cosheaf/cli-agent-demo/`, uses dry-run
draft and bundle commands, and does not call hosted providers or require MCP.
See `docs/AGENT_ACCESS.md`.

For the strategy-planner workflow, run:

```bash
make strategy-demo
```

For framework development, use a local framework checkout:

```bash
COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/demo_strategy_planner.sh
```

The demo builds a context pack, stages the strategy-planner input under
ignored `.cosheaf/strategy-demo/` runtime paths, records a research run,
updates the plan from run provenance, previews strategy review export with
`--dry-run`, and reruns validation and gates. Strategy plans are guidance only:
not proof, checked evidence, verifier pass, gate pass, human review, accepted
status, or promotion authority. See `docs/STRATEGY_PLANNER_WORKFLOW.md`.

For the operator-session and handoff preview workflow, run:

```bash
make operator-session-demo
```

That demo uses the active local framework checkout when `../tcs-cosheaf`
exists; otherwise it installs the framework source configured by
`COSHEAF_FRAMEWORK_REF`, defaulting to the published `v0.12.0` tag. It records a
private-research operator session around the example issue, appends validation
and gate check summaries, appends private draft/runtime references, scans the
session, builds a handoff bundle, and previews handoff export with `--dry-run`.

Operator-session and handoff records are review context only. They are not
proof, verifier evidence, gate pass, source metadata, human review, accepted
status, accepted refutation, or promotion authority. The demo writes runtime
outputs only under ignored `.cosheaf/` paths and `context/TASKS/`; it does not
modify public KB or accepted artifacts. See `docs/OPERATOR_SESSION_DEMO.md`.

For the published `v0.12.0` reviewable-workflow handoff path, run:

```bash
make reviewable-workflow-demo
```

That demo uses the active local framework checkout when `../tcs-cosheaf`
exists, otherwise it installs the published `v0.12.0` tag. It exercises the
V14 workflow `draft-proposal` and `handoff` commands now included in that tag.
It starts a workflow for the example issue, runs whitelisted local actions,
checks readiness, previews a draft proposal with `--dry-run`, builds and scans
a workflow handoff, and previews handoff export with `--dry-run`.

Workflow records, draft proposals, and handoff packets are review context only.
They are not proof, source metadata, verifier pass, gate pass, human review,
accepted status, accepted refutation, or promotion authority. See
`docs/REVIEWABLE_WORKFLOW_DEMO.md`.

For the V15 workflow cross-check and checker/cross-check eval path, run:

```bash
make crosscheck-demo
```

This demo installs or uses the published `v0.12.0` framework by default. It
also needs the framework repository eval case file under
`evals/checker_crosscheck/cases.yaml`, so keep the sibling `../tcs-cosheaf`
checkout or set `COSHEAF_CHECKER_EVAL_REPO_ROOT`. It starts a workflow for the
example issue, runs local workflow actions, builds cross-check/evidence/gap
reports, and runs the checker/cross-check eval against the framework eval
cases. Outputs stay under ignored `.cosheaf/` paths. The reports are review
context only: not proof, source metadata, verifier pass, gate pass, human
review, accepted status, accepted theorem/refutation, or promotion authority.

For the V16 campaign handoff and campaign eval path, run:

```bash
make campaign-demo
```

This demo uses the active sibling `../tcs-cosheaf` checkout when available,
otherwise it installs the published `v0.12.0` tag. Set
`COSHEAF_FRAMEWORK_REF=<ref>` to test another framework source. It starts a
campaign for the example issue, previews and exports one bounded operator task
packet, appends one safe campaign attempt, builds a campaign handoff, runs the
campaign eval suite, and stores outputs under ignored `.cosheaf/` paths.
Campaign outputs
are review context only: not proof, source metadata, verifier pass, gate pass,
human review, accepted status, accepted refutation, or promotion authority.

For the published `v0.12.0` bounded research-loop workflow, run:

```bash
make research-loop-demo
```

This demo installs or uses the published `v0.12.0` framework by default. It
starts a loop, appends a failed attempt, exports a task packet, imports a
deterministic retry result with `retry_justification`, scans the loop, and
finalizes it. Outputs stay under ignored `.cosheaf/` paths. The loop material
is review context only: not proof, source metadata, verifier pass, gate pass,
human review, accepted status, accepted refutation, or promotion authority.

For artifact failure-memory workflow, run:

```bash
make failure-memory-demo
```

The demo uses the active `cosheaf` CLI and writes a temporary workspace copy
and JSON outputs under
`.cosheaf/failure-memory-demo/`. It appends one failed direction to the copied
private draft artifact, shows `artifact failures`, reports promotion readiness,
and reruns validation and gates. The source `kb/private` artifact is not
modified.

The promotion-readiness report is expected to remain not ready because the
example artifact is a draft without human review.

Failure memory is research context only. It is not proof, refutation, verifier
evidence, human review, gate success, accepted status, or promotion evidence.
If the active `cosheaf` command is older than the template's pinned framework
tag, use a local framework checkout:

```bash
PYTHONPATH="$(pwd)/../tcs-cosheaf" \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/demo_failure_memory.sh
```

To explicitly install a framework source first, set
`COSHEAF_INSTALL_FRAMEWORK=1 COSHEAF_FRAMEWORK_REF=<ref>`.

For the fake provider workflow, run:

```bash
make provider-config-check
make provider-preview-public
make provider-fake-smoke
```

`provider-config-check` reports fake-provider configuration in JSON.
`provider-preview-public` previews the public-mode provider context shape for
`issue.example-private-claim`. `provider-fake-smoke` writes JSON output under
`.cosheaf/provider-fake-smoke/` and runs the orchestrator with `--provider
fake`.

The automated provider smoke uses the fake provider only. It does not require
an API key, does not make hosted API calls, does not require MCP, does not write
accepted knowledge, does not promote artifacts, and keeps public KB readonly.
The provider smoke installs the framework from the `v0.12.0` tag by default.
See `docs/AGENT_PROVIDERS.md` for safe real-provider setup rules.

For verifier-gate and promotion-readiness boundaries, run:

```bash
make verifier-evidence-demo
```

That demo writes JSON output under `.cosheaf/verifier-evidence-demo/`, shows
that skipped or not-applicable verifier gates are not passes, and reports that
the private draft example is not promotion-ready. It does not require SAT, SMT,
Lean, lake, hosted providers, MCP, API keys, accepted writes, promotion, or
human-review spoofing. See `docs/VERIFICATION_WORKFLOW.md`.

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
