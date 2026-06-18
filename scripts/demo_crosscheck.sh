#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.11.0}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
EVAL_REPO_ROOT="${COSHEAF_CHECKER_EVAL_REPO_ROOT:-$FRAMEWORK_ROOT}"
OUTPUT_DIR="${COSHEAF_CROSSCHECK_DEMO_OUTPUT_DIR:-.cosheaf/crosscheck-demo}"
ISSUE_ID="${COSHEAF_CROSSCHECK_DEMO_ISSUE:-issue.example-private-claim}"
QUERY="${COSHEAF_CROSSCHECK_DEMO_QUERY:-workspace template cross-check demo}"

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
    EVAL_REPO_ROOT="${COSHEAF_CHECKER_EVAL_REPO_ROOT:-$FRAMEWORK_ROOT}"
    export PYTHONPATH="$FRAMEWORK_ROOT${PYTHONPATH:+:$PYTHONPATH}"
    export COSHEAF_CMD="$PYTHON_BIN -m cosheaf.cli"
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

assert_review_only_outputs() {
  local crosscheck_path="$1"
  local evidence_path="$2"
  local gap_path="$3"
  local eval_path="$4"
  "$PYTHON_BIN" - "$crosscheck_path" "$evidence_path" "$gap_path" "$eval_path" <<'PY'
import json
import sys

crosscheck_path, evidence_path, gap_path, eval_path = sys.argv[1:]
with open(crosscheck_path, encoding="utf-8") as handle:
    crosscheck = json.load(handle)
with open(evidence_path, encoding="utf-8") as handle:
    evidence = json.load(handle)
with open(gap_path, encoding="utf-8") as handle:
    gaps = json.load(handle)
with open(eval_path, encoding="utf-8") as handle:
    checker_eval = json.load(handle)

checks = [
    (crosscheck.get("kind") == "workflow_crosscheck_report", "cross-check report kind mismatch"),
    (crosscheck.get("checked_pass_is_accepted") is False, "checked pass must not become accepted"),
    (crosscheck.get("human_review_created") is False, "cross-check must not create human review"),
    (crosscheck.get("source_metadata_created") is False, "cross-check must not create source metadata"),
    (crosscheck.get("accepted_status_created") is False, "cross-check must not create accepted status"),
    (crosscheck.get("promotion_performed") is False, "cross-check must not promote"),
    (evidence.get("kind") == "workflow_evidence_report", "evidence report kind mismatch"),
    (evidence.get("checked_pass_is_accepted") is False, "evidence report must not accept checked pass"),
    (evidence.get("human_review_created") is False, "evidence report must not create human review"),
    (gaps.get("kind") == "workflow_gap_report", "gap report kind mismatch"),
    (gaps.get("gaps_are_defects") is False, "gaps are triage guidance, not defects"),
    (checker_eval.get("kind") == "checker_crosscheck_eval", "checker-crosscheck eval kind mismatch"),
    (checker_eval.get("passed") is True, "checker-crosscheck eval must pass"),
    (checker_eval.get("metrics", {}).get("accepted_write_violation_count") == 0, "eval must not write accepted knowledge"),
    (checker_eval.get("metrics", {}).get("skipped_not_pass_count", 0) >= 1, "eval must preserve skipped-not-pass"),
    (checker_eval.get("metrics", {}).get("inconclusive_not_pass_count", 0) >= 1, "eval must preserve inconclusive-not-pass"),
]
failed = [message for ok, message in checks if not ok]
if failed:
    for message in failed:
        print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

require_crosscheck_surface() {
  if ! run_cosheaf workflow cross-check --help >/dev/null; then
    cat >&2 <<EOF

This demo requires a framework checkout or tag with the V15 cross-check
surface: workflow cross-check, workflow evidence-report, gap list, and
eval checker-crosscheck.

Use a sibling checkout:
  COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/demo_crosscheck.sh

or install a newer explicit ref:
  COSHEAF_FRAMEWORK_REF=<tag-or-commit> bash scripts/demo_crosscheck.sh

The published v0.11.0 tag contains the V15 checker/cross-check CLI surface.
The eval case file still comes from a framework repository checkout.
EOF
    exit 1
  fi
  run_cosheaf workflow evidence-report --help >/dev/null
  run_cosheaf gap list --help >/dev/null
  run_cosheaf eval checker-crosscheck --help >/dev/null
}

require_checker_eval_cases() {
  local case_path="$EVAL_REPO_ROOT/evals/checker_crosscheck/cases.yaml"
  if [[ ! -f "$case_path" ]]; then
    cat >&2 <<EOF

The checker/cross-check eval needs the framework repository case file:
  evals/checker_crosscheck/cases.yaml

Set COSHEAF_CHECKER_EVAL_REPO_ROOT to a local tcs-cosheaf checkout that
contains the V15 eval cases.
EOF
    exit 1
  fi
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

require_crosscheck_surface
require_checker_eval_cases
mkdir -p "$OUTPUT_DIR"

run_cosheaf_to_file "$OUTPUT_DIR/01-workspace-info.json" workspace info --json
run_cosheaf_to_file "$OUTPUT_DIR/02-validate.json" validate --json
run_cosheaf_to_file "$OUTPUT_DIR/03-gate.json" gate run --json
run_cosheaf_to_file "$OUTPUT_DIR/04-workflow-start.json" workflow start \
  --issue "$ISSUE_ID" \
  --query "$QUERY" \
  --json

WORKFLOW_ID="$(extract_json_field "$OUTPUT_DIR/04-workflow-start.json" workflow.workflow_id)"

run_cosheaf_to_file "$OUTPUT_DIR/05-workflow-run.json" workflow run "$WORKFLOW_ID" \
  --max-steps 4 \
  --execute-local-actions \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/06-workflow-crosscheck.json" workflow cross-check "$WORKFLOW_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/07-workflow-evidence-report.json" workflow evidence-report "$WORKFLOW_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/08-workflow-gaps.json" gap list "$WORKFLOW_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/09-checker-crosscheck-eval.json" eval checker-crosscheck \
  --repo-root "$EVAL_REPO_ROOT" \
  --json

assert_review_only_outputs \
  "$OUTPUT_DIR/06-workflow-crosscheck.json" \
  "$OUTPUT_DIR/07-workflow-evidence-report.json" \
  "$OUTPUT_DIR/08-workflow-gaps.json" \
  "$OUTPUT_DIR/09-checker-crosscheck-eval.json"

run_cosheaf validate
run_cosheaf gate run

printf '\nCross-check demo complete.\n'
printf 'Workflow ID: %s\n' "$WORKFLOW_ID"
printf 'Runtime outputs are under %s and .cosheaf/workflows/%s.\n' "$OUTPUT_DIR" "$WORKFLOW_ID"
printf 'The cross-check, gap, and eval reports are review context only.\n'
printf 'No public KB write, accepted artifact, promotion, verifier mutation, gate mutation, source metadata, or human review was performed.\n'
