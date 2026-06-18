#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
BASH_BIN="${COSHEAF_DEMO_BASH:-${BASH:-bash}}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.12.0}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
OUTPUT_DIR="${COSHEAF_AI_MATH_DEMO_OUTPUT_DIR:-.cosheaf/ai-math-collaborator-demo}"
BENCHMARK_REPORT_DIR="${COSHEAF_AI_MATH_BENCHMARK_REPORT_DIR:-.cosheaf/ai-math-collaborator-demo}"
ISSUE_ID="${COSHEAF_AI_MATH_DEMO_ISSUE:-issue.example-private-claim}"

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
    export COSHEAF_SKIP_INSTALL=1
    return 0
  fi
  if [[ -d "$FRAMEWORK_ROOT/cosheaf" ]]; then
    FRAMEWORK_ROOT="$(cd "$FRAMEWORK_ROOT" && pwd)"
    export PYTHONPATH="$FRAMEWORK_ROOT${PYTHONPATH:+:$PYTHONPATH}"
    export COSHEAF_CMD="$PYTHON_BIN -m cosheaf.cli"
    export COSHEAF_SKIP_INSTALL=1
    printf '# using local framework checkout: %s\n' "$FRAMEWORK_ROOT"
    return 0
  fi
  return 1
}

cosheaf_command() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    local cmd=($COSHEAF_CMD)
    printf '%s\n' "${cmd[@]}"
  else
    printf '%s\n' "${COSHEAF:-cosheaf}"
  fi
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

write_skipped_json() {
  local output_path="$1"
  local reason="$2"
  "$PYTHON_BIN" - "$output_path" "$reason" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
payload = {
    "schema_version": 1,
    "status": "skipped",
    "reason": sys.argv[2],
    "skipped_rows_are_passes": False,
}
path.write_text(json.dumps(payload, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
PY
}

json_field() {
  local json_path="$1"
  local field="$2"
  "$PYTHON_BIN" - "$json_path" "$field" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    print(json.load(handle)[sys.argv[2]])
PY
}

benchmark_repo_root() {
  if [[ -n "${COSHEAF_AI_MATH_BENCHMARK_REPO_ROOT:-}" ]]; then
    printf '%s\n' "$COSHEAF_AI_MATH_BENCHMARK_REPO_ROOT"
    return 0
  fi
  if [[ -f "$REPO_ROOT/evals/retrieval/cases.yaml" ]]; then
    printf '%s\n' "$REPO_ROOT"
    return 0
  fi
  if [[ -f "$FRAMEWORK_ROOT/evals/retrieval/cases.yaml" ]]; then
    printf '%s\n' "$FRAMEWORK_ROOT"
    return 0
  fi
  return 1
}

run_benchmark_if_available() {
  local repo_root
  if ! repo_root="$(benchmark_repo_root)"; then
    write_skipped_json \
      "$OUTPUT_DIR/06-benchmark-run.json" \
      "smoke benchmark skipped because no repository-local evals/retrieval/cases.yaml was found"
    write_skipped_json \
      "$OUTPUT_DIR/07-benchmark-report.json" \
      "benchmark report skipped because benchmark run was skipped"
    write_skipped_json \
      "$OUTPUT_DIR/08-static-benchmark-report.json" \
      "static benchmark report skipped because benchmark run was skipped"
    return 0
  fi

  run_cosheaf_to_file "$OUTPUT_DIR/06-benchmark-run.json" benchmark run \
    --suite smoke \
    --repo-root "$repo_root" \
    --json
  BENCHMARK_RUN_ID="$(json_field "$OUTPUT_DIR/06-benchmark-run.json" run_id)"
  run_cosheaf_to_file "$OUTPUT_DIR/07-benchmark-report.json" benchmark report \
    "$BENCHMARK_RUN_ID" \
    --repo-root "$repo_root" \
    --out "$BENCHMARK_REPORT_DIR/benchmark-report.md" \
    --json
  run_cosheaf_to_file "$OUTPUT_DIR/08-static-benchmark-report.json" report benchmark \
    "$BENCHMARK_RUN_ID" \
    --repo-root "$repo_root" \
    --out "$BENCHMARK_REPORT_DIR/static-benchmark-report" \
    --json
}

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  if ! use_local_framework_if_available; then
    run "$PYTHON_BIN" -m pip install \
      "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
    add_python_user_scripts_to_path
    export COSHEAF_SKIP_INSTALL=1
  fi
else
  use_local_framework_if_available || true
fi

mkdir -p "$OUTPUT_DIR"

run_cosheaf_to_file "$OUTPUT_DIR/01-workspace-info.json" workspace info --json
if run_cosheaf_to_file "$OUTPUT_DIR/02-interface-list.json" interface list --json; then
  :
else
  write_skipped_json \
    "$OUTPUT_DIR/02-interface-list.json" \
    "installed framework does not expose cosheaf interface list"
fi
run_cosheaf_to_file "$OUTPUT_DIR/03-validate.json" validate --json
run_cosheaf_to_file "$OUTPUT_DIR/04-gate.json" gate run --json
run_cosheaf_to_file "$OUTPUT_DIR/05-context-build.json" context build "$ISSUE_ID" --json

run "$BASH_BIN" scripts/demo_cli_agent.sh
run "$BASH_BIN" scripts/demo_strategy_planner.sh
run "$BASH_BIN" scripts/demo_research_run.sh
run "$BASH_BIN" scripts/demo_campaign.sh

run_benchmark_if_available

run_cosheaf_to_file "$OUTPUT_DIR/09-validate-after.json" validate --json
run_cosheaf_to_file "$OUTPUT_DIR/10-gate-after.json" gate run --json

printf '\nAI math collaborator demo complete.\n'
printf 'Runtime outputs are under %s plus child demo .cosheaf/ directories.\n' "$OUTPUT_DIR"
printf 'No hosted provider, MCP requirement, accepted write, promotion, public KB write, or human-review spoofing was performed.\n'
printf 'Skipped optional rows are recorded as skipped, not pass.\n'
