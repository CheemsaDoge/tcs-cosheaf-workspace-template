# TCS-Cosheaf Workspace Template

## What This Is

This repository is the user-facing workspace template for TCS-Cosheaf. It is
the recommended starting point for a user workspace that combines the framework
package, readonly reusable public knowledge, and a writable private research
overlay.

The included seed files are examples only. They let a clean clone run
validation, gates, and context-pack commands immediately, but real public KB
content should be mounted or checked out from `tcs-kb-public`.

## What This Is Not

This repository is not the framework implementation, not the public KB
maintenance repository, and not a place to publish private conjectures. It does
not provide automatic theorem proving, full Lean/mathlib/CSLib integration, a
web UI, or multi-user permissions.

Validation and gate success are workflow checks. They are not a substitute for
human review for accepted public KB artifacts, and they do not make
LLM-generated or private material accepted knowledge.

## Three-Repo Model

- `tcs-cosheaf` is the framework package. It provides the CLI, schemas,
  validation, gates, graph tools, and context-pack tooling.
- `tcs-kb-public` is readonly reusable public knowledge for downstream user
  workspaces.
- `tcs-cosheaf-workspace-template` is this user-facing workspace template.
- `kb/private` is the writable private research overlay for conjectures, proof
  attempts, failures, notes, and work-in-progress claims.

Users should not manually merge framework, public KB, and private workspace
repositories. Use the framework package, mount or check out public KB content
from `tcs-kb-public`, and keep private work under `kb/private`.

## Quickstart

Install the framework package pinned by this template:

```bash
python -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.2.4"
```

Then inspect and validate the workspace:

```bash
cosheaf workspace info
cosheaf validate
cosheaf gate run
cosheaf gate run --pr-checklist .github/pull_request_template.md
cosheaf context build issue.example-private-claim
```

The example issue is `issues/open/issue.example-private-claim.yaml`. It points
to `kb/private/claims/claim.example-private.yaml`, which remains a draft
private example depending on artifact id `definition.graph`.

In a clean clone, that dependency is satisfied by this template's local draft
public seed so the demo can run offline. For real work, mount or check out
`tcs-kb-public` as the readonly public KB so `definition.graph` resolves to
reviewed accepted public knowledge.

## One-Command Demo

Run the minimal workspace demo from a clean clone:

```bash
bash scripts/demo_workspace.sh
```

The demo installs `tcs-cosheaf` from the `v0.2.4` tag, inspects the workspace,
validates the configured public/private KB roots, runs the gatekeeper and PR
checklist gate, and builds context for `issue.example-private-claim`.

The demo does not promote artifacts and does not create accepted private
claims. Runtime outputs are written under ignored paths such as `.cosheaf/` and
`context/TASKS/`.

For a more complete public showcase that also bootstraps a local
`tcs-kb-public` reference checkout, rebuilds the index, and attempts the
optional local dry-run worker when the installed framework supports it, run:

```bash
bash scripts/demo.sh
```

See [Showcase demo](docs/SHOWCASE.md) for the step-by-step walkthrough and
limitations.

## CLI Agent Demo

Run the CLI-first agent demo:

```bash
bash scripts/demo_cli_agent.sh
```

This demo uses only Cosheaf CLI commands with JSON output. It inspects the
workspace, validates and gates, searches memory, builds public-only context,
previews a draft artifact write with `--dry-run`, previews a worker bundle
review submission with `--dry-run`, and validates/gates again.

The demo writes parseable JSON outputs under `.cosheaf/cli-agent-demo/`, an
ignored runtime directory. It does not use hosted API calls, does not require
MCP, does not write accepted knowledge, does not promote artifacts, and does
not mark human review complete. Public KB remains readonly.

The demo installs `tcs-cosheaf` from the `v0.2.4` tag by default. Override the
source with `COSHEAF_FRAMEWORK_REF=<ref>`, or use a local framework checkout
with
`COSHEAF_SKIP_INSTALL=1`, `PYTHONPATH=../tcs-cosheaf`, and
`COSHEAF_CMD="python -m cosheaf.cli"`.

On Windows, if `bash` is installed but not on `PATH`, run:

```powershell
mingw32-make cli-agent-demo BASH="C:/Program Files/Git/bin/bash.exe"
```

## Failure-Memory Demo

Run the artifact failure-memory demo:

```bash
make failure-memory-demo
```

The demo uses the active `cosheaf` CLI; it does not install the framework by
default. It creates a temporary workspace copy under
`.cosheaf/failure-memory-demo/`, appends one `failure_log` entry to the copied
private draft artifact, then records JSON output for failure-log inspection,
promotion-readiness reporting, validation, and gates.

The promotion-readiness report is expected to say the example is not ready:
the artifact is still a draft, lacks human review, and depends on template seed
material.

The source `kb/private` artifact is not modified. The demo does not write
accepted knowledge, does not promote artifacts, does not call a provider, does
not require an API key, and does not mark human review complete. Failure memory
is research context only: it is not proof, refutation, verifier evidence,
human review, gate success, or promotion evidence.

The demo expects a framework version with artifact failure-log CLI support.
Until that support is released as a pinned tag, run it against a local
framework checkout:

```bash
PYTHONPATH="$(pwd)/../tcs-cosheaf" \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/demo_failure_memory.sh
```

To explicitly install a framework source before running the demo, set
`COSHEAF_INSTALL_FRAMEWORK=1 COSHEAF_FRAMEWORK_REF=<ref>`.

## Provider Fake Smoke

Run the fake provider smoke when you want to exercise the hosted-worker
provider path without a real API key or hosted API call:

```bash
bash scripts/provider_fake_smoke.sh
```

Or through Make:

```bash
make provider-fake-smoke
```

The smoke writes JSON outputs under `.cosheaf/provider-fake-smoke/`, checks the
fake provider configuration, previews the public-mode provider send shape, and
runs the orchestrator with `--provider fake`. It does not require MCP, does not
write accepted knowledge, does not promote artifacts, does not mark human
review complete, and keeps the public KB readonly.

The smoke installs `tcs-cosheaf` from the `v0.2.4` tag by default. Real hosted
provider use is explicit user setup only; do not commit API keys, `.env`
files, provider responses with private context, or logs containing secrets. See
[Agent Providers](docs/AGENT_PROVIDERS.md).

`docs/AGENT_PROVIDERS.md` distinguishes fake, mocked, and real provider
surfaces. Default demos use the fake provider only. Real provider setup starts
with `provider config-check` and a public-only `provider preview-send`; private
context requires `private_research` policy plus explicit private-context
consent.

To preview the OpenAI-compatible public context boundary without an API key or
network send, run:

```bash
bash scripts/provider_preview_public.sh
```

or:

```bash
make provider-preview-public
```

The preview smoke writes JSON outputs under `.cosheaf/provider-preview-public/`
and does not perform a hosted provider call.

## Makefile Shortcuts

If `make` is available, these targets are thin wrappers around the same
commands:

```bash
make install
make workspace-info
make validate
make gate
make index
make pr-checklist
make context
make demo
make cli-agent-demo
make failure-memory-demo
make provider-config-check
make provider-preview-public
make provider-fake-smoke
make verifier-evidence-demo
```

Only `make install` performs the framework package install directly.
`make demo` delegates to `scripts/demo_workspace.sh`, which performs the
install as part of the full demo path.
The fake provider targets use `scripts/provider_fake_smoke.sh`. The public
provider preview target uses `scripts/provider_preview_public.sh` and previews
OpenAI-compatible provider metadata without sending a real request. Provider
targets may install the framework source configured by `COSHEAF_FRAMEWORK_REF`.
`make verifier-evidence-demo` runs `scripts/demo_verifier_evidence.sh`, which
shows promotion-readiness and verifier-gate boundaries without API keys,
hosted providers, MCP, accepted writes, or human-review spoofing.
`make workspace` remains available as a compatibility alias for
`make workspace-info`.
On Windows, if `bash` is installed but not on `PATH`, run the demo with an
explicit Bash path, for example:

```powershell
mingw32-make demo BASH="C:/Program Files/Git/bin/bash.exe"
```

## Public KB Setup

For real work, mount or replace `kb/public` with content from `tcs-kb-public`,
or use the bootstrap script to clone a readonly reference checkout under the
ignored `.cosheaf/` runtime area:

```bash
bash scripts/bootstrap_public_kb.sh
```

On Windows PowerShell:

```powershell
.\scripts\bootstrap_public_kb.ps1
```

The bootstrap scripts do not modify `kb/public`, do not copy private artifacts
into public KB, and refuse to overwrite existing non-git directories. See
`docs/PUBLIC_KB_SETUP.md` for the supported modes.

## Private Research Workflow

Private conjectures, proof attempts, failures, experiments, notes, and
work-in-progress claims belong under `kb/private`. Private artifacts may depend
on accepted public artifacts from a mounted public KB. Public artifacts must
not depend on private artifacts. The included public seed is only for template
demonstration and is not accepted public knowledge.

Do not copy public accepted artifacts into `kb/private`. Do not place private
conjectures in `kb/public`. Do not promote private claims to accepted without
explicit review and gates.

## Formal-Link Warning

Formal links are metadata only unless a real checker verifies them. Planned
formal links do not mean Lean has checked anything, do not mean CSLib/mathlib
symbols exist, and do not prove informal/formal semantic alignment.

The template includes `formal-libs/lean-libraries.example.yaml` so the draft
seed's planned `cslib-main` metadata resolves under the G10 formal-link gate.
That example manifest is placeholder metadata. It does not fetch CSLib, run
Lean, or turn the seed formal link into checked evidence.

Context packs may display formal-link metadata from mounted public KB artifacts
or from this template's seed examples as review context. That display is not a
proof and is not a Lean, SAT, SMT, CSLib, or mathlib verification claim.

## Verification Workflow Demo

Run:

```bash
bash scripts/demo_verifier_evidence.sh
```

The demo records JSON outputs under `.cosheaf/verifier-evidence-demo/`. It
checks workspace validation and gates, shows that skipped or not-applicable
verifier gates are not passes, and runs promotion-readiness reporting when the
installed framework exposes that command. The private example claim is expected
to remain not promotion-ready because it is draft and lacks human review.

See [Verification Workflow Demo](docs/VERIFICATION_WORKFLOW.md).

## Known Limitations

- The template seed is for demonstration only and is not the real public KB.
- Public accepted artifacts still require source metadata and human review in
  `tcs-kb-public`.
- The demo requires network access for the framework install step.
- Formal links remain metadata unless a checker actually runs and records a
  result.
- The workspace template is the user entry point; framework changes belong in
  `tcs-cosheaf`, and reusable public knowledge changes belong in
  `tcs-kb-public`.

## License

This workspace template is released under the Apache-2.0 license. See
`LICENSE`.
