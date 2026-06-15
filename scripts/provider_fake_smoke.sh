#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.4.0}"
OUTPUT_DIR="${COSHEAF_PROVIDER_SMOKE_OUTPUT_DIR:-.cosheaf/provider-fake-smoke}"
ISSUE_ID="${COSHEAF_PROVIDER_SMOKE_ISSUE:-issue.example-private-claim}"
MODE="${1:-all}"

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

case "$MODE" in
  all)
    capture_json 01-provider-config-check provider config-check --provider fake --json
    capture_json 02-provider-preview-public provider preview-send \
      --issue "$ISSUE_ID" \
      --provider fake \
      --json

    run_root=".cosheaf/orchestrator/${ISSUE_ID}/runs/run.${ISSUE_ID}"
    if [[ -d "$run_root" ]]; then
      case "$run_root" in
        .cosheaf/orchestrator/*)
          printf '\n# removing previous ignored runtime run: %s\n' "$run_root"
          rm -rf "$run_root"
          ;;
        *)
          printf 'Refusing to remove unexpected path: %s\n' "$run_root" >&2
          exit 1
          ;;
      esac
    fi

    capture_json 03-orchestrator-fake-dispatch orchestrator run \
      --issue "$ISSUE_ID" \
      --provider fake \
      --json
    ;;
  config-check)
    capture_json 01-provider-config-check provider config-check --provider fake --json
    ;;
  preview-public)
    capture_json 02-provider-preview-public provider preview-send \
      --issue "$ISSUE_ID" \
      --provider fake \
      --json
    ;;
  *)
    printf 'Unknown provider smoke mode: %s\n' "$MODE" >&2
    printf 'Expected one of: all, config-check, preview-public\n' >&2
    exit 2
    ;;
esac

printf '\nProvider fake smoke complete.\n'
printf 'JSON outputs are under %s.\n' "$OUTPUT_DIR"
printf 'The automated path used only provider=fake and performed no hosted API call.\n'
printf 'No MCP, accepted write, promotion, or human review was performed.\n'
