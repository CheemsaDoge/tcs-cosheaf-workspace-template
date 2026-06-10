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

The provider and hosted-worker orchestrator commands are newer than the
`v0.2.0` release tag, so the smoke installs `tcs-cosheaf` from the `main`
branch by default until the next framework tag includes them. Override the
source with `COSHEAF_FRAMEWORK_REF=<ref>`, or use a local framework checkout
with:

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

## Single-Step Commands

Use these targets when an agent or operator wants one provider check at a time:

```bash
make provider-config-check
make provider-preview-public
```

These targets use the same framework source selection as the full smoke. Set
`COSHEAF_FRAMEWORK_REF=<ref>` to choose an install source, or set
`COSHEAF_SKIP_INSTALL=1` with `COSHEAF_CMD="python -m cosheaf.cli"` for a local
framework checkout.

`provider-config-check` reports fake-provider configuration in JSON. It does
not read or print secrets.

`provider-preview-public` previews the public-mode provider context shape for
`issue.example-private-claim`. It does not send full artifact text to a hosted
provider and does not authorize a provider call by itself.

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
