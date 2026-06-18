# Agent Providers

This workspace template demonstrates provider workflows without committing
secrets, calling real hosted APIs, writing accepted knowledge, or requiring MCP.
The framework repository remains the authoritative implementation and policy
source for provider behavior.

## Fake Provider Smoke

Run the local fake provider smoke with:

```bash
bash scripts/provider_fake_smoke.sh
```

Or through Make:

```bash
make provider-fake-smoke
```

The smoke writes JSON outputs under `.cosheaf/provider-fake-smoke/`, an ignored
runtime directory. It runs:

1. `cosheaf provider config-check --provider fake --json`
2. `cosheaf provider preview-send --issue issue.example-private-claim --provider fake --json`
3. `cosheaf orchestrator run --issue issue.example-private-claim --provider fake --json`

The automated smoke uses `provider=fake` only. It performs no hosted API call,
does not require an API key, does not require MCP, does not write accepted
knowledge, does not promote artifacts, and does not mark human review complete.
The public KB remains readonly.

The provider and hosted-worker orchestrator commands are included in the
`v0.11.0` framework tag, so the smoke installs `tcs-cosheaf` from `v0.11.0` by
default. Override the source with `COSHEAF_FRAMEWORK_REF=<ref>`, or use a local
framework checkout with:

```bash
COSHEAF_SKIP_INSTALL=1 \
PYTHONPATH=../tcs-cosheaf \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/provider_fake_smoke.sh
```

On Windows, if `bash` is installed but not on `PATH`, run:

```powershell
mingw32-make provider-fake-smoke BASH="C:/Program Files/Git/bin/bash.exe"
```

## Provider Modes

Use these names consistently when reading framework docs and workspace output:

- Fake provider: deterministic local provider used by this template's
  automated smoke. It requires no API key, performs no hosted API call, and is
  the only provider used by default demos.
- Mocked provider: test-only framework fixture that injects a fake transport to
  exercise OpenAI-compatible provider boundaries. It is useful for framework
  tests, but it is not a user configuration mode in this workspace.
- Real provider: an explicitly configured hosted provider call. It requires
  local operator setup, API credentials outside the repository, public/private
  context preview, send consent, and network permission. Real provider output
  is untrusted review context only.

Default workspace demos remain fake-only. Do not add a Makefile target or demo
script that performs a real provider call by default.

## Single-Step Commands

Use these targets when an agent or operator wants one provider check at a time:

```bash
make provider-config-check
make provider-preview-public
```

`provider-config-check` uses the local fake provider smoke for a minimal
secret-free configuration check. `provider-preview-public` runs
`scripts/provider_preview_public.sh`, which checks OpenAI-compatible provider
configuration metadata and previews the public-only context boundary without a
hosted API call.

Both targets use the same framework source selection style as the full smoke.
Set `COSHEAF_FRAMEWORK_REF=<ref>` to choose an install source, or set
`COSHEAF_SKIP_INSTALL=1` with `COSHEAF_CMD="python -m cosheaf.cli"` for a local
framework checkout.

`provider-config-check` reports fake-provider configuration in JSON. It does
not read or print secrets.

`provider-preview-public` writes JSON under `.cosheaf/provider-preview-public/`
for `issue.example-private-claim`. It does not send full artifact text to a
hosted provider and does not authorize a provider call by itself.

## Public Provider Preview Smoke

Run the public-only preview smoke directly with:

```bash
bash scripts/provider_preview_public.sh
```

The script runs:

1. `cosheaf provider config-check --provider openai --api-key-env OPENAI_API_KEY --json`
2. `cosheaf provider preview-send --issue issue.example-private-claim --provider openai --policy-mode public --json`

The first step reports whether the configured API key environment variable is
present without printing any secret value. The second step previews the
provider-send context shape in public mode only. It should report public root
scope, `private_context_included: false`, card-only content, and
`real_run_performed: false`.

The script writes outputs under `.cosheaf/provider-preview-public/`, an ignored
runtime path. It performs no hosted API call, does not require an API key, does
not require MCP, does not write accepted knowledge, does not promote artifacts,
and keeps public KB readonly.

## Real Provider Setup

Real hosted provider use is not part of the automated workspace smoke. If a
user enables a real provider later, it must be explicit and local to that user:

- set secrets only in the shell environment or a local secret manager;
- do not commit API keys, tokens, `.env` files, logs with secrets, or provider
  responses containing private context;
- run a public context preview before any send;
- use private context only when policy mode, provider configuration, and
  operator consent explicitly allow it;
- keep provider output as WorkerBundle, draft, proposal, or review context
  only.

Real provider output is not human review, not validation/gate success, not a
verifier pass, and not accepted knowledge.

### Environment Variable Names

`.env.example` lists variable names only. Leave real provider values empty in
the repository. Put local values in your shell, a local secret manager, or an
untracked local environment file.

Current OpenAI-compatible variable names used by examples and operator notes:

- `OPENAI_API_KEY`: secret API key. Never commit a value.
- `OPENAI_BASE_URL`: optional OpenAI-compatible endpoint URL. Leave empty in
  repository files.
- `OPENAI_MODEL`: optional model name. Leave empty in repository files unless
  a future private local setup file supplies it.

Run a configuration check before any send:

```bash
cosheaf provider config-check --provider openai --api-key-env OPENAI_API_KEY --json
```

The config check reports secret presence only and must not print the key.

### Preview Before Send

Always preview public context first:

```bash
cosheaf provider preview-send \
  --issue issue.example-private-claim \
  --provider openai \
  --json
```

Public preview output should show public root scope only and
`private_context_included: false`. Preview output is metadata for operator
review; it does not authorize a hosted provider call by itself.

Private context requires an explicit private-research preview and explicit
private-context consent:

```bash
cosheaf provider preview-send \
  --issue issue.example-private-claim \
  --provider openai \
  --include-private \
  --policy-mode private_research \
  --allow-private-context \
  --json
```

Do not use private context unless the local research workflow really requires
it and the operator has inspected the preview. Private provider responses and
logs may contain sensitive research content; keep them under ignored runtime
paths and do not commit them.

### Real Send Boundary

The workspace template does not provide a default real-run Makefile target.
The framework real-send path is deliberately hard to trigger: it requires an
explicit input envelope, configured endpoint/key environment, context preview,
`--confirm-send`, and `--allow-network`. Private context additionally requires
private-research policy and explicit private-context consent.

Real sends are outside the default demo path. They must not write accepted
knowledge, mark human review, create verifier results, promote artifacts, or
bypass validation and gates.
