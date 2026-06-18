#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.12.0}"
OUTPUT_DIR="${COSHEAF_PROVIDER_PREVIEW_OUTPUT_DIR:-.cosheaf/provider-preview-public}"
ISSUE_ID="${COSHEAF_PROVIDER_PREVIEW_ISSUE:-issue.example-private-claim}"
PROVIDER="${COSHEAF_PROVIDER_PREVIEW_PROVIDER:-openai}"
API_KEY_ENV="${COSHEAF_PROVIDER_API_KEY_ENV:-OPENAI_API_KEY}"

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

cosheaf_has_provider_cli() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    local cmd=($COSHEAF_CMD)
    "${cmd[@]}" provider --help >/dev/null 2>&1
  else
    "${COSHEAF:-cosheaf}" provider --help >/dev/null 2>&1
  fi
}

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  if cosheaf_has_provider_cli; then
    printf '\n# existing cosheaf provider CLI found; skipping framework install\n'
  else
    run "$PYTHON_BIN" -m pip install --upgrade --force-reinstall --no-deps \
      "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
    add_python_user_scripts_to_path
  fi
fi

mkdir -p "$OUTPUT_DIR"

capture_json 01-provider-config-check provider config-check \
  --provider "$PROVIDER" \
  --api-key-env "$API_KEY_ENV" \
  --json

capture_json 02-provider-preview-public provider preview-send \
  --issue "$ISSUE_ID" \
  --provider "$PROVIDER" \
  --policy-mode public \
  --json

printf '\nProvider public preview smoke complete.\n'
printf 'JSON outputs are under %s.\n' "$OUTPUT_DIR"
printf 'No hosted API call, real-run, MCP, accepted write, promotion, or human review was performed.\n'
printf 'The preview is public-only and does not authorize a provider send.\n'
