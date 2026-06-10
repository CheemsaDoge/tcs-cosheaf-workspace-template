# Agent Access

This workspace template supports CLI-first operation by external coding
agents. The framework repository defines the authoritative agent-access
contract; this workspace shows how to exercise that contract without hosted
API calls, MCP, accepted writes, or private leakage.

## CLI Agent Demo

Run the end-to-end CLI agent demo with:

```bash
bash scripts/demo_cli_agent.sh
```

The script runs only Cosheaf CLI commands and writes machine-readable command
outputs under `.cosheaf/cli-agent-demo/`, an ignored runtime directory. It
does not promote artifacts, does not create accepted private claims, does not
write human review, does not call hosted providers, and does not require MCP.

Until the controlled draft-write CLI commands are available in a release tag,
the demo installs the framework from the `main` branch by default:

```bash
COSHEAF_FRAMEWORK_REF=main bash scripts/demo_cli_agent.sh
```

For local framework development, skip installation and point the script at a
local CLI command:

```bash
COSHEAF_SKIP_INSTALL=1 \
PYTHONPATH=../tcs-cosheaf \
COSHEAF_CMD="python -m cosheaf.cli" \
bash scripts/demo_cli_agent.sh
```

On Windows, if `bash` is installed but not on `PATH`, run the Makefile target
with an explicit Bash path:

```powershell
mingw32-make cli-agent-demo BASH="C:/Program Files/Git/bin/bash.exe"
```

## Demo Flow

The demo runs:

1. `cosheaf workspace info --json`
2. `cosheaf validate --json`
3. `cosheaf gate run --json`
4. `cosheaf memory search "graph private draft" --issue issue.example-private-claim --json`
5. `cosheaf context build issue.example-private-claim --json --public-only`
6. `cosheaf draft write-artifact --input-json examples/cli_agent_demo/draft_artifact_request.json --json --dry-run`
7. `cosheaf bundle submit --input-json examples/cli_agent_demo/bundle_submit_request.json --json --dry-run`
8. `cosheaf validate --json`
9. `cosheaf gate run --json`

The context build is public-only so the saved demo context does not include
private artifact text. The draft write and bundle submission are dry-runs. The
proposed artifact path is under the writable private KB overlay, not the
readonly public KB root, and the bundle remains review context only.

## Policy

- Public KB remains readonly from this workspace.
- Private work belongs under `kb/private`.
- Agent-generated outputs may be draft/proposal/bundle/source-note/review
  staging only.
- Validation and gate success are evidence for review, not human review and
  not accepted status.
- Formal links remain metadata unless a checker actually verifies them.
