#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.12.0}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
EVAL_REPO_ROOT="${COSHEAF_CAMPAIGN_EVAL_REPO_ROOT:-$FRAMEWORK_ROOT}"
OUTPUT_DIR="${COSHEAF_CAMPAIGN_DEMO_OUTPUT_DIR:-.cosheaf/campaign-demo}"
ISSUE_ID="${COSHEAF_CAMPAIGN_DEMO_ISSUE:-issue.example-private-claim}"
CAMPAIGN_ID="${COSHEAF_CAMPAIGN_DEMO_ID:-campaign.workspace.demo}"

cd "$REPO_ROOT"

run() {
  printf '\n+' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  "$@"
}

use_local_framework_if_available() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    return 0
  fi
  if [[ -d "$FRAMEWORK_ROOT/cosheaf" ]]; then
    FRAMEWORK_ROOT="$(cd "$FRAMEWORK_ROOT" && pwd)"
    EVAL_REPO_ROOT="${COSHEAF_CAMPAIGN_EVAL_REPO_ROOT:-$FRAMEWORK_ROOT}"
    export PYTHONPATH="$FRAMEWORK_ROOT${PYTHONPATH:+:$PYTHONPATH}"
    export COSHEAF_CMD="$PYTHON_BIN -m cosheaf.cli"
    printf '# using local framework checkout: %s\n' "$FRAMEWORK_ROOT"
    return 0
  fi
  return 1
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

run_cosheaf() {
  local cmd
  mapfile -t cmd < <(cosheaf_command)
  run "${cmd[@]}" "$@"
}

clean_runtime() {
  "$PYTHON_BIN" - "$REPO_ROOT" "$OUTPUT_DIR" "$CAMPAIGN_ID" <<'PY'
import shutil
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
paths = [
    (repo / sys.argv[2]).resolve(),
    (repo / ".cosheaf" / "campaigns" / sys.argv[3]).resolve(),
]
for path in paths:
    rel = path.relative_to(repo)
    if not rel.parts or rel.parts[0] != ".cosheaf":
        raise SystemExit(f"refusing to clean non-runtime path: {rel}")
    if path.exists():
        shutil.rmtree(path)
PY
}

write_attempt() {
  "$PYTHON_BIN" - "$OUTPUT_DIR/attempt.json" "$CAMPAIGN_ID" <<'PY'
import json
import sys
from pathlib import Path

campaign_id = sys.argv[2]
payload = {
    "attempt_id": f"{campaign_id}.attempt.1",
    "campaign_id": campaign_id,
    "attempt_number": 1,
    "outcome": "result",
    "attempted_direction": "Build a draft campaign note",
    "completed_at": "2026-06-18T04:40:00+00:00",
    "result_summary": "Draft campaign note ready for maintainer inspection.",
    "actions_taken": ["cosheaf validate", "cosheaf gate run"],
    "workflow_refs": ["workflow.issue.example-private-claim.campaign"],
    "check_report_refs": [".cosheaf/campaign-demo/02-validate-before.json"],
    "proof_obligation_refs": ["gap.issue.example-private-claim.source-locator"],
    "draft_proposal_refs": [".cosheaf/campaign-demo/draft-note.json"],
    "benchmark_report_refs": [".cosheaf/campaign-demo/operator_task_v2.json"],
}
path = Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(payload, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")
PY
}

assert_review_context_only() {
  "$PYTHON_BIN" - "$OUTPUT_DIR/08-handoff.json" "$OUTPUT_DIR/09-campaign-eval.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    handoff = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    eval_report = json.load(handle)

handoff_payload = handoff["handoff"]
checks = [
    (handoff.get("accepted_write_performed") is False, "handoff export wrote accepted knowledge"),
    (handoff_payload.get("limitations", {}).get("not_proof") is True, "handoff must be non-proof"),
    (handoff_payload.get("limitations", {}).get("not_human_review") is True, "handoff must not be human review"),
    (handoff_payload.get("limitations", {}).get("not_promotion_authority") is True, "handoff must not promote"),
    (eval_report.get("kind") == "campaign_eval", "campaign eval kind mismatch"),
    (eval_report.get("passed") is True, "campaign eval did not pass"),
    (eval_report.get("metrics", {}).get("accepted_write_violation_count") == 0, "eval wrote accepted knowledge"),
]
failed = [message for ok, message in checks if not ok]
if failed:
    for message in failed:
        print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

require_campaign_surface() {
  run_cosheaf campaign handoff --help >/dev/null
  run_cosheaf eval campaign --help >/dev/null
  if [[ ! -f "$EVAL_REPO_ROOT/evals/campaign/cases.yaml" ]]; then
    cat >&2 <<EOF
Campaign eval cases were not found at:
  $EVAL_REPO_ROOT/evals/campaign/cases.yaml

Use a sibling framework checkout or set COSHEAF_CAMPAIGN_EVAL_REPO_ROOT.
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

require_campaign_surface
clean_runtime
mkdir -p "$OUTPUT_DIR"

run_cosheaf_to_file "$OUTPUT_DIR/01-workspace-info.json" workspace info --json
run_cosheaf_to_file "$OUTPUT_DIR/02-validate-before.json" validate --json
run_cosheaf_to_file "$OUTPUT_DIR/03-gate-before.json" gate run --json
run_cosheaf_to_file "$OUTPUT_DIR/04-campaign-start.json" campaign start \
  --issue "$ISSUE_ID" \
  --campaign-id "$CAMPAIGN_ID" \
  --max-attempts 2 \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/05-campaign-next.json" campaign next "$CAMPAIGN_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/06-export-task.json" campaign export-task "$CAMPAIGN_ID" \
  --out "$OUTPUT_DIR/operator_task_v2.json" \
  --json
write_attempt
run_cosheaf_to_file "$OUTPUT_DIR/07-append-attempt.json" campaign append-attempt "$CAMPAIGN_ID" \
  --input-json "$OUTPUT_DIR/attempt.json" \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/08-handoff.json" campaign handoff "$CAMPAIGN_ID" \
  --out "$OUTPUT_DIR/handoff" \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/09-campaign-eval.json" eval campaign \
  --repo-root "$EVAL_REPO_ROOT" \
  --json
run_cosheaf_to_file "$OUTPUT_DIR/10-scan.json" campaign scan "$CAMPAIGN_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/11-run.json" campaign run "$CAMPAIGN_ID" \
  --max-attempts 2 \
  --json

assert_review_context_only
run_cosheaf validate
run_cosheaf gate run

printf '\nCampaign demo complete.\n'
printf 'Campaign ID: %s\n' "$CAMPAIGN_ID"
printf 'Runtime outputs are under %s and .cosheaf/campaigns/%s.\n' "$OUTPUT_DIR" "$CAMPAIGN_ID"
printf 'No hosted provider, shell-backed campaign loop, public KB write, accepted write, source metadata, human review, verifier/gate authority, or promotion was performed.\n'
