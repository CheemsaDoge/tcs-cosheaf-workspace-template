#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.8.0}"
OUTPUT_DIR="${COSHEAF_RESEARCH_DEMO_OUTPUT_DIR:-.cosheaf/research-run-demo}"
ISSUE_ID="${COSHEAF_RESEARCH_DEMO_ISSUE:-issue.example-private-claim}"
SEARCH_QUERY="${COSHEAF_RESEARCH_DEMO_QUERY:-graph private draft}"
OPERATOR_LABEL="${COSHEAF_RESEARCH_DEMO_OPERATOR:-workspace-template research-run demo}"

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

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  run "$PYTHON_BIN" -m pip install \
    "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
  add_python_user_scripts_to_path
fi

mkdir -p "$OUTPUT_DIR"

run_cosheaf run start \
  --issue "$ISSUE_ID" \
  --operator external \
  --operator-label "$OPERATOR_LABEL" \
  --json | tee "$OUTPUT_DIR/00-run-start.json"

RUN_ID="$("$PYTHON_BIN" - "$OUTPUT_DIR/00-run-start.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    print(json.load(handle)["run_id"])
PY
)"
export RUN_ID

append_output "00-issue-reference" "issue_reference" "" "$ISSUE_ID" "in_progress" "workspace-template research-run demo issue"

recorded_cosheaf 01-workspace-info workspace info --json
append_output "01-workspace-info" "workspace_info" "$OUTPUT_DIR/commands/01-workspace-info.stdout.txt" "" "completed" "workspace info JSON output"

recorded_cosheaf 02-validate-before validate --json
append_output "02-validate-before" "validation_report" "$OUTPUT_DIR/commands/02-validate-before.stdout.txt" "" "completed" "baseline validation JSON output"

recorded_cosheaf 03-gate-before gate run --json
append_output "03-gate-before" "gate_report" "$OUTPUT_DIR/commands/03-gate-before.stdout.txt" "" "completed" "baseline gate JSON output"

recorded_cosheaf 04-memory-search memory search "$SEARCH_QUERY" --issue "$ISSUE_ID" --json
recorded_cosheaf 05-context-build context build "$ISSUE_ID" --json
append_output "05-context-pack" "context_pack" "context/TASKS/${ISSUE_ID}/CONTEXT.md" "" "completed" "bounded context pack for the demo issue"

recorded_cosheaf 06-checked-evidence-help counterexample evidence validate --help
append_output "06-checked-evidence-note" "other" "" "checked-evidence-demo.not-staged" "skipped" "Skipped research-run steps are not pass evidence. The workspace template demo does not stage checked counterexample evidence."

recorded_cosheaf 07-validate-after validate --json
append_output "07-validate-after" "validation_report" "$OUTPUT_DIR/commands/07-validate-after.stdout.txt" "" "completed" "post-demo validation JSON output"

recorded_cosheaf 08-gate-after gate run --json
append_output "08-gate-after" "gate_report" "$OUTPUT_DIR/commands/08-gate-after.stdout.txt" "" "completed" "post-demo gate JSON output"

run_cosheaf run finalize \
  --run "$RUN_ID" \
  --status completed \
  --stop-reason "workspace research-run demo completed without accepted writes" \
  --json | tee "$OUTPUT_DIR/09-run-finalize.json"

run_cosheaf run evidence-report --run "$RUN_ID" --json | tee "$OUTPUT_DIR/10-evidence-report.json"
run_cosheaf run replay-plan --run "$RUN_ID" --json | tee "$OUTPUT_DIR/11-replay-plan.json"
run_cosheaf run export-review --run "$RUN_ID" --dry-run --json | tee "$OUTPUT_DIR/12-export-review-dry-run.json"

if [[ "${COSHEAF_RESEARCH_DEMO_EXPORT_REVIEW:-0}" == "1" ]]; then
  run_cosheaf run export-review --run "$RUN_ID" --json | tee "$OUTPUT_DIR/13-export-review.json"
else
  printf '\n# Review export was previewed only. Set COSHEAF_RESEARCH_DEMO_EXPORT_REVIEW=1 to write reviews/runs/%s.yaml.\n' "$RUN_ID"
fi

run_cosheaf validate
run_cosheaf gate run

printf '\nResearch run demo complete.\n'
printf 'Run ID: %s\n' "$RUN_ID"
printf 'Runtime outputs are under %s.\n' "$OUTPUT_DIR"
printf 'Run record: .cosheaf/runs/%s/run.json\n' "$RUN_ID"
printf 'No hosted provider, MCP, accepted write, promotion, or human review was performed.\n'
