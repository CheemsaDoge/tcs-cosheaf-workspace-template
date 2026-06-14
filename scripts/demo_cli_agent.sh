#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.2.3}"
OUTPUT_DIR="${COSHEAF_AGENT_DEMO_OUTPUT_DIR:-.cosheaf/cli-agent-demo}"
ISSUE_ID="${COSHEAF_AGENT_DEMO_ISSUE:-issue.example-private-claim}"
SEARCH_QUERY="${COSHEAF_AGENT_DEMO_QUERY:-graph private draft}"

cd "$REPO_ROOT"

run() {
  printf '\n+' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  "$@"
}

add_python_user_scripts_to_path() {
  local scripts_dir
  scripts_dir="$("$PYTHON_BIN" - <<'PY'
import os
import sysconfig

scheme = "nt_user" if os.name == "nt" else "posix_user"
path = sysconfig.get_path("scripts", scheme=scheme) or ""
path = path.replace("\\", "/")
if len(path) > 2 and path[1] == ":":
    path = "/" + path[0].lower() + path[2:]
print(path)
PY
)"

  if [[ -n "$scripts_dir" && -d "$scripts_dir" ]]; then
    export PATH="$scripts_dir:$PATH"
  fi
}

run_cosheaf() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    # COSHEAF_CMD is intentionally split so callers can use values such as
    # `python -m cosheaf.cli` for local framework checkouts.
    local cmd=($COSHEAF_CMD)
    run "${cmd[@]}" "$@"
  else
    run "${COSHEAF:-cosheaf}" "$@"
  fi
}

capture_json() {
  local name="$1"
  shift
  local output_path="$OUTPUT_DIR/$name.json"
  printf '\n# output: %s\n' "$output_path"
  run_cosheaf "$@" | tee "$output_path"
}

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  run "$PYTHON_BIN" -m pip install \
    "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
  add_python_user_scripts_to_path
fi

mkdir -p "$OUTPUT_DIR"

capture_json 01-workspace-info workspace info --json
capture_json 02-validate-before validate --json
capture_json 03-gate-before gate run --json
capture_json 04-memory-search memory search "$SEARCH_QUERY" --issue "$ISSUE_ID" --json
capture_json 05-context-build context build "$ISSUE_ID" --json --public-only
capture_json 06-draft-write-dry-run draft write-artifact \
  --input-json examples/cli_agent_demo/draft_artifact_request.json \
  --json \
  --dry-run
capture_json 07-bundle-submit-dry-run bundle submit \
  --input-json examples/cli_agent_demo/bundle_submit_request.json \
  --json \
  --dry-run
capture_json 08-validate-after validate --json
capture_json 09-gate-after gate run --json

printf '\nCLI agent demo complete.\n'
printf 'JSON outputs are under %s.\n' "$OUTPUT_DIR"
printf 'No hosted API, MCP, accepted write, promotion, or human review was performed.\n'
