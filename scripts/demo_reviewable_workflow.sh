#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.11.0}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
OUTPUT_DIR="${COSHEAF_REVIEWABLE_WORKFLOW_DEMO_OUTPUT_DIR:-.cosheaf/reviewable-workflow-demo}"
ISSUE_ID="${COSHEAF_REVIEWABLE_WORKFLOW_DEMO_ISSUE:-issue.example-private-claim}"
QUERY="${COSHEAF_REVIEWABLE_WORKFLOW_DEMO_QUERY:-workspace template reviewable workflow demo}"

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
  local proposal_path="$1"
  local handoff_path="$2"
  local export_path="$3"
  "$PYTHON_BIN" - "$proposal_path" "$handoff_path" "$export_path" <<'PY'
import json
import sys

proposal_path, handoff_path, export_path = sys.argv[1:]
with open(proposal_path, encoding="utf-8") as handle:
    proposal = json.load(handle)
with open(handoff_path, encoding="utf-8") as handle:
    handoff = json.load(handle)
with open(export_path, encoding="utf-8") as handle:
    export = json.load(handle)

checks = [
    (proposal.get("dry_run") is True, "draft proposal must be dry-run"),
    (proposal.get("written") is False, "draft proposal must not write files"),
    (proposal.get("artifact_written") is False, "draft proposal must not write artifacts"),
    (handoff.get("review_context_only") is True, "handoff must remain review context"),
    (handoff.get("accepted_write_performed") is False, "handoff must not perform accepted writes"),
    (handoff.get("human_review_created") is False, "handoff must not create human review"),
    (handoff.get("source_metadata_created") is False, "handoff must not create source metadata"),
    (export.get("dry_run") is True, "handoff export must be dry-run"),
    (export.get("written_paths") == [], "handoff export dry-run must not write files"),
    (export.get("promotion_performed") is False, "handoff export must not promote"),
]
failed = [message for ok, message in checks if not ok]
if failed:
    for message in failed:
        print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

require_reviewable_workflow_surface() {
  if ! run_cosheaf workflow draft-proposal --help >/dev/null; then
    cat >&2 <<EOF

This demo requires a framework checkout or tag with the V14 reviewable-workflow
follow-up surface: workflow draft-proposal and workflow handoff commands.

Use a sibling checkout:
  COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/demo_reviewable_workflow.sh

or install a newer explicit ref:
  COSHEAF_FRAMEWORK_REF=<tag-or-commit> bash scripts/demo_reviewable_workflow.sh

The published v0.11.0 tag contains the workflow draft-proposal and handoff
surface required by this demo.
EOF
    exit 1
  fi
  run_cosheaf workflow handoff --help >/dev/null
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

require_reviewable_workflow_surface
mkdir -p "$OUTPUT_DIR"

run_cosheaf_to_file "$OUTPUT_DIR/01-workflow-start.json" workflow start \
  --issue "$ISSUE_ID" \
  --query "$QUERY" \
  --json
WORKFLOW_ID="$(extract_json_field "$OUTPUT_DIR/01-workflow-start.json" workflow.workflow_id)"
HANDOFF_ID="handoff.${WORKFLOW_ID}"

run_cosheaf_to_file "$OUTPUT_DIR/02-workflow-run.json" workflow run "$WORKFLOW_ID" \
  --max-steps 4 \
  --execute-local-actions \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/03-readiness.json" workflow readiness "$WORKFLOW_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/04-draft-proposal-dry-run.json" workflow draft-proposal "$WORKFLOW_ID" \
  --dry-run \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/05-handoff-build.json" workflow handoff build "$WORKFLOW_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/06-handoff-show.json" workflow handoff show "$HANDOFF_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/07-handoff-scan.json" workflow handoff scan "$HANDOFF_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/08-handoff-export-dry-run.json" workflow handoff export "$HANDOFF_ID" \
  --dry-run \
  --json

assert_review_only_outputs \
  "$OUTPUT_DIR/04-draft-proposal-dry-run.json" \
  "$OUTPUT_DIR/05-handoff-build.json" \
  "$OUTPUT_DIR/08-handoff-export-dry-run.json"

run_cosheaf validate
run_cosheaf gate run

printf '\nReviewable-workflow demo complete.\n'
printf 'Workflow ID: %s\n' "$WORKFLOW_ID"
printf 'Handoff ID: %s\n' "$HANDOFF_ID"
printf 'Runtime outputs are under %s and .cosheaf/workflows/%s.\n' "$OUTPUT_DIR" "$WORKFLOW_ID"
printf 'The draft proposal and handoff export were both dry-run only.\n'
printf 'No public KB write, accepted artifact, promotion, verifier mutation, gate mutation, source metadata, or human review was performed.\n'
