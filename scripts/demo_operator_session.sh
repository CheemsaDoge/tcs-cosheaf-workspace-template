#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.10.0}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
OUTPUT_DIR="${COSHEAF_OPERATOR_DEMO_OUTPUT_DIR:-.cosheaf/operator-session-demo}"
ISSUE_ID="${COSHEAF_OPERATOR_DEMO_ISSUE:-issue.example-private-claim}"
PRIVATE_DRAFT_PATH="${COSHEAF_OPERATOR_DEMO_DRAFT_PATH:-kb/private/claims/claim.example-private.yaml}"
OPERATOR_LABEL="${COSHEAF_OPERATOR_DEMO_OPERATOR:-workspace-template operator-session demo}"
CONTEXT_DIR="context/TASKS/${ISSUE_ID}"

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

use_local_framework_if_available() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    return 0
  fi
  if [[ -d "$FRAMEWORK_ROOT/cosheaf" ]]; then
    FRAMEWORK_ROOT="$(cd "$FRAMEWORK_ROOT" && pwd)"
    export PYTHONPATH="$FRAMEWORK_ROOT${PYTHONPATH:+:$PYTHONPATH}"
    export COSHEAF_CMD="$PYTHON_BIN -m cosheaf.cli"
    printf '# using local framework checkout: %s\n' "$FRAMEWORK_ROOT"
    return 0
  fi
  return 1
}

cosheaf_command() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    # COSHEAF_CMD is intentionally split so callers can use values such as
    # `python -m cosheaf.cli` for local framework checkouts.
    local cmd=($COSHEAF_CMD)
    printf '%s\n' "${cmd[@]}"
  else
    printf '%s\n' "${COSHEAF:-cosheaf}"
  fi
}

run_cosheaf() {
  local cmd
  mapfile -t cmd < <(cosheaf_command)
  run "${cmd[@]}" "$@"
}

run_cosheaf_to_file() {
  local output_path="$1"
  shift
  local cmd
  mapfile -t cmd < <(cosheaf_command)
  mkdir -p "$(dirname "$output_path")"
  printf '\n+' >&2
  printf ' %q' "${cmd[@]}" "$@" >&2
  printf '\n' >&2
  "${cmd[@]}" "$@" | tee "$output_path"
}

extract_json_field() {
  local json_path="$1"
  local field_path="$2"
  "$PYTHON_BIN" - "$json_path" "$field_path" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    payload = json.load(handle)
value = payload
for part in sys.argv[2].split("."):
    value = value[part]
print(value)
PY
}

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  if ! use_local_framework_if_available; then
    run "$PYTHON_BIN" -m pip install \
      "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
    add_python_user_scripts_to_path
  fi
else
  use_local_framework_if_available || true
fi

mkdir -p "$OUTPUT_DIR"

run_cosheaf_to_file "$OUTPUT_DIR/01-workspace-info.json" workspace info --json
run_cosheaf_to_file "$OUTPUT_DIR/02-validate.json" validate --json
run_cosheaf_to_file "$OUTPUT_DIR/03-gate.json" gate run --json
run_cosheaf_to_file "$OUTPUT_DIR/04-context-build.json" context build "$ISSUE_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/05-strategy-plan.json" strategy plan \
  --issue "$ISSUE_ID" \
  --from-context "$CONTEXT_DIR" \
  --json

PLAN_ID="$(extract_json_field "$OUTPUT_DIR/05-strategy-plan.json" plan_id)"

run_cosheaf_to_file "$OUTPUT_DIR/06-session-start.json" operator session start \
  --issue "$ISSUE_ID" \
  --policy private_research \
  --operator-label "$OPERATOR_LABEL" \
  --json

SESSION_ID="$(extract_json_field "$OUTPUT_DIR/06-session-start.json" session_id)"
HANDOFF_ID="handoff.${SESSION_ID}"

run_cosheaf_to_file "$OUTPUT_DIR/07-append-check-validate.json" operator session append-check "$SESSION_ID" \
  --kind validate \
  --status pass \
  --summary "cosheaf validate completed during the workspace operator-session demo" \
  --report-path "$OUTPUT_DIR/02-validate.json" \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/08-append-check-gate.json" operator session append-check "$SESSION_ID" \
  --kind gate \
  --status pass \
  --summary "cosheaf gate run completed during the workspace operator-session demo" \
  --report-path "$OUTPUT_DIR/03-gate.json" \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/09-append-check-test-skipped.json" operator session append-check "$SESSION_ID" \
  --kind test \
  --status skipped \
  --summary "Skipped operator-session checks are not pass evidence. The workspace demo does not run a separate test suite." \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/10-append-check-eval-skipped.json" operator session append-check "$SESSION_ID" \
  --kind eval \
  --status skipped \
  --summary "Skipped operator-session checks are not pass evidence. The workspace demo does not run evals." \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/11-append-ref-private-draft.json" operator session append-ref "$SESSION_ID" \
  --kind draft \
  --path "$PRIVATE_DRAFT_PATH" \
  --artifact claim.example-private \
  --scope private \
  --summary "Private draft example reference only; not accepted knowledge." \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/12-append-ref-context.json" operator session append-ref "$SESSION_ID" \
  --kind runtime \
  --path "${CONTEXT_DIR}/CONTEXT.md" \
  --scope private \
  --summary "Context pack generated for the private demo issue." \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/13-append-ref-strategy.json" operator session append-ref "$SESSION_ID" \
  --kind runtime \
  --path ".cosheaf/strategy/${PLAN_ID}/strategy.json" \
  --scope private \
  --summary "Strategy-plan runtime record generated for demo review context." \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/14-session-finalize.json" operator session finalize "$SESSION_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/15-session-scan.json" operator session scan "$SESSION_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/16-handoff-build.json" operator handoff build --session "$SESSION_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/17-handoff-show.json" operator handoff show "$HANDOFF_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/18-handoff-export-dry-run.json" operator handoff export \
  --handoff "$HANDOFF_ID" \
  --dry-run \
  --json

run_cosheaf validate
run_cosheaf gate run

printf '\nOperator-session demo complete.\n'
printf 'Session ID: %s\n' "$SESSION_ID"
printf 'Handoff ID: %s\n' "$HANDOFF_ID"
printf 'Runtime outputs are under %s and .cosheaf/operator-sessions/%s.\n' "$OUTPUT_DIR" "$SESSION_ID"
printf 'The handoff export was previewed with --dry-run only; no reviews/operator file was written.\n'
printf 'No hosted provider, API key, MCP server, public KB change, accepted write, promotion, verifier mutation, or human review was performed.\n'
