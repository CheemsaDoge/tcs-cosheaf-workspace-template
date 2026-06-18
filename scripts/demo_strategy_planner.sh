#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.12.0}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
OUTPUT_DIR="${COSHEAF_STRATEGY_DEMO_OUTPUT_DIR:-.cosheaf/strategy-demo}"
ISSUE_ID="${COSHEAF_STRATEGY_DEMO_ISSUE:-issue.example-private-claim}"
OPERATOR_LABEL="${COSHEAF_STRATEGY_DEMO_OPERATOR:-workspace-template strategy demo}"
SOURCE_CONTEXT_DIR="context/TASKS/${ISSUE_ID}"
RUNTIME_CONTEXT_DIR="${OUTPUT_DIR}/context/${ISSUE_ID}"
SOURCE_CONTEXT_PREEXISTED=0

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

utc_now() {
  "$PYTHON_BIN" - <<'PY'
from datetime import UTC, datetime

print(datetime.now(UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z"))
PY
}

write_command_payload() {
  local payload_path="$1"
  local status="$2"
  local exit_code="$3"
  local started_at="$4"
  local ended_at="$5"
  local stdout_path="$6"
  local stderr_path="$7"
  shift 7
  "$PYTHON_BIN" - "$payload_path" "$status" "$exit_code" "$started_at" "$ended_at" "$stdout_path" "$stderr_path" "$@" <<'PY'
import json
import sys

payload_path, status, exit_code, started_at, ended_at, stdout_path, stderr_path, *argv = sys.argv[1:]
payload = {
    "argv": argv,
    "cwd": ".",
    "started_at": started_at,
    "ended_at": ended_at,
    "status": status,
    "stdout_path": stdout_path,
    "stderr_path": stderr_path,
}
if exit_code != "null":
    payload["exit_code"] = int(exit_code)
with open(payload_path, "w", encoding="utf-8", newline="\n") as handle:
    json.dump(payload, handle, ensure_ascii=True, indent=2)
    handle.write("\n")
PY
}

write_output_payload() {
  local payload_path="$1"
  local kind="$2"
  local path_value="$3"
  local identifier="$4"
  local status="$5"
  local summary="$6"
  "$PYTHON_BIN" - "$payload_path" "$kind" "$path_value" "$identifier" "$status" "$summary" <<'PY'
import json
import sys

payload_path, kind, path_value, identifier, status, summary = sys.argv[1:]
payload = {"kind": kind}
if path_value:
    payload["path"] = path_value
if identifier:
    payload["identifier"] = identifier
if status:
    payload["status"] = status
if summary:
    payload["summary"] = summary
with open(payload_path, "w", encoding="utf-8", newline="\n") as handle:
    json.dump(payload, handle, ensure_ascii=True, indent=2)
    handle.write("\n")
PY
}

recorded_cosheaf() {
  local name="$1"
  shift
  local cmd
  mapfile -t cmd < <(cosheaf_command)
  cmd+=("$@")

  local stdout_path="$OUTPUT_DIR/commands/${name}.stdout.txt"
  local stderr_path="$OUTPUT_DIR/commands/${name}.stderr.txt"
  local payload_path="$OUTPUT_DIR/commands/${name}.command.json"
  local append_path="$OUTPUT_DIR/commands/${name}.append-command.json"
  local started_at
  local ended_at
  local exit_code
  local status

  mkdir -p "$OUTPUT_DIR/commands"
  started_at="$(utc_now)"
  printf '\n# recorded command: %s\n' "$name"
  printf '+' >&2
  printf ' %q' "${cmd[@]}" >&2
  printf '\n' >&2
  set +e
  "${cmd[@]}" >"$stdout_path" 2>"$stderr_path"
  exit_code=$?
  set -e
  ended_at="$(utc_now)"
  if [[ "$exit_code" -eq 0 ]]; then
    status="completed"
  else
    status="failed"
  fi

  if [[ -s "$stdout_path" ]]; then
    cat "$stdout_path"
  fi
  if [[ -s "$stderr_path" ]]; then
    cat "$stderr_path" >&2
  fi

  write_command_payload "$payload_path" "$status" "$exit_code" "$started_at" "$ended_at" "$stdout_path" "$stderr_path" "${cmd[@]}"
  run_cosheaf run append-command --run "$RUN_ID" --input-json "$payload_path" --json >"$append_path"

  if [[ "$exit_code" -ne 0 ]]; then
    printf 'Command failed; recorded failure in %s.\n' "$payload_path" >&2
    exit "$exit_code"
  fi
}

append_output() {
  local name="$1"
  local kind="$2"
  local path_value="$3"
  local identifier="$4"
  local status="$5"
  local summary="$6"
  local payload_path="$OUTPUT_DIR/outputs/${name}.output.json"
  local append_path="$OUTPUT_DIR/outputs/${name}.append-output.json"
  mkdir -p "$OUTPUT_DIR/outputs"
  write_output_payload "$payload_path" "$kind" "$path_value" "$identifier" "$status" "$summary"
  run_cosheaf run append-output --run "$RUN_ID" --input-json "$payload_path" --json >"$append_path"
}

copy_context_pack_to_runtime() {
  "$PYTHON_BIN" - "$REPO_ROOT" "$SOURCE_CONTEXT_DIR" "$RUNTIME_CONTEXT_DIR" <<'PY'
from pathlib import Path
import shutil
import sys

repo = Path(sys.argv[1]).resolve()
source = (repo / sys.argv[2]).resolve()
target = (repo / sys.argv[3]).resolve()
allowed_source_root = (repo / "context" / "TASKS").resolve()
allowed_target_root = (repo / ".cosheaf").resolve()

try:
    source.relative_to(allowed_source_root)
    target.relative_to(allowed_target_root)
except ValueError as exc:
    raise SystemExit(f"context copy path is outside the expected runtime roots: {exc}")

if not source.is_dir():
    raise SystemExit(f"context pack source directory does not exist: {source}")

if target.exists():
    shutil.rmtree(target)
target.parent.mkdir(parents=True, exist_ok=True)
shutil.copytree(source, target)
PY
}

cleanup_generated_context_pack() {
  if [[ "$SOURCE_CONTEXT_PREEXISTED" != "0" || ! -d "$SOURCE_CONTEXT_DIR" ]]; then
    return 0
  fi
  "$PYTHON_BIN" - "$REPO_ROOT" "$SOURCE_CONTEXT_DIR" <<'PY'
from pathlib import Path
import shutil
import sys

repo = Path(sys.argv[1]).resolve()
target = (repo / sys.argv[2]).resolve()
allowed_root = (repo / "context" / "TASKS").resolve()

try:
    target.relative_to(allowed_root)
except ValueError as exc:
    raise SystemExit(f"refusing to clean context path outside context/TASKS: {exc}")

if target.is_dir():
    shutil.rmtree(target)
PY
}

extract_json_field() {
  local json_path="$1"
  local field="$2"
  "$PYTHON_BIN" - "$json_path" "$field" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    payload = json.load(handle)
print(payload[sys.argv[2]])
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
if [[ -d "$SOURCE_CONTEXT_DIR" ]]; then
  SOURCE_CONTEXT_PREEXISTED=1
fi
trap cleanup_generated_context_pack EXIT

run_cosheaf run start \
  --issue "$ISSUE_ID" \
  --operator external \
  --operator-label "$OPERATOR_LABEL" \
  --json | tee "$OUTPUT_DIR/00-run-start.json"

RUN_ID="$(extract_json_field "$OUTPUT_DIR/00-run-start.json" run_id)"
export RUN_ID

append_output "00-issue-reference" "issue_reference" "" "$ISSUE_ID" "in_progress" "workspace-template strategy demo issue"

recorded_cosheaf 01-workspace-info workspace info --json
if [[ "$SOURCE_CONTEXT_PREEXISTED" == "1" ]]; then
  printf '\n# reusing existing context pack: %s\n' "$SOURCE_CONTEXT_DIR"
else
  recorded_cosheaf 02-context-build context build "$ISSUE_ID" --json
fi
copy_context_pack_to_runtime
cleanup_generated_context_pack
append_output "02-context-pack" "context_pack" "${RUNTIME_CONTEXT_DIR}/CONTEXT.md" "" "completed" "bounded context pack for the strategy demo issue"

recorded_cosheaf 03-strategy-plan strategy plan --issue "$ISSUE_ID" --from-context "$RUNTIME_CONTEXT_DIR" --json
PLAN_ID="$(extract_json_field "$OUTPUT_DIR/commands/03-strategy-plan.stdout.txt" plan_id)"
export PLAN_ID
append_output "03-strategy-plan" "other" ".cosheaf/strategy/${PLAN_ID}/strategy.json" "$PLAN_ID" "completed" "strategy plan runtime record"

recorded_cosheaf 04-strategy-next strategy next "$PLAN_ID" --json
recorded_cosheaf 05-validate validate --json
append_output "05-validation" "validation_report" "$OUTPUT_DIR/commands/05-validate.stdout.txt" "" "completed" "strategy demo validation JSON output"

recorded_cosheaf 06-gate gate run --json
append_output "06-gate" "gate_report" "$OUTPUT_DIR/commands/06-gate.stdout.txt" "" "completed" "strategy demo gate JSON output"

run_cosheaf run finalize \
  --run "$RUN_ID" \
  --status completed \
  --stop-reason "workspace strategy demo completed without accepted writes" \
  --json | tee "$OUTPUT_DIR/07-run-finalize.json"

run_cosheaf strategy update-from-run --plan "$PLAN_ID" --run "$RUN_ID" --json | tee "$OUTPUT_DIR/08-strategy-update-from-run.json"
run_cosheaf strategy export-review --plan "$PLAN_ID" --dry-run --json | tee "$OUTPUT_DIR/09-strategy-export-review-dry-run.json"

if [[ "${COSHEAF_STRATEGY_DEMO_EXPORT_REVIEW:-0}" == "1" ]]; then
  run_cosheaf strategy export-review --plan "$PLAN_ID" --json | tee "$OUTPUT_DIR/10-strategy-export-review.json"
else
  printf '\n# Strategy review export was previewed only. Set COSHEAF_STRATEGY_DEMO_EXPORT_REVIEW=1 to write reviews/strategy/%s.yaml.\n' "$PLAN_ID"
fi

run_cosheaf run evidence-report --run "$RUN_ID" --json | tee "$OUTPUT_DIR/11-run-evidence-report.json"
run_cosheaf run replay-plan --run "$RUN_ID" --json | tee "$OUTPUT_DIR/12-run-replay-plan.json"
run_cosheaf validate
run_cosheaf gate run

printf '\nStrategy planner demo complete.\n'
printf 'Run ID: %s\n' "$RUN_ID"
printf 'Plan ID: %s\n' "$PLAN_ID"
printf 'Runtime outputs are under %s.\n' "$OUTPUT_DIR"
printf 'Run record: .cosheaf/runs/%s/run.json\n' "$RUN_ID"
printf 'Strategy plan: .cosheaf/strategy/%s/strategy.json\n' "$PLAN_ID"
printf 'No hosted provider, MCP, accepted write, promotion, or human review was performed.\n'
