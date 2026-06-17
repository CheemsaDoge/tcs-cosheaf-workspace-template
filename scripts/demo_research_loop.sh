#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
OUTPUT_DIR="${COSHEAF_RESEARCH_LOOP_DEMO_OUTPUT_DIR:-.cosheaf/research-loop-demo}"
ISSUE_ID="${COSHEAF_RESEARCH_LOOP_DEMO_ISSUE:-issue.example-private-claim}"
LOOP_ID="${COSHEAF_RESEARCH_LOOP_DEMO_LOOP:-loop.workspace.research}"
PUBLIC_ARTIFACT_ID="${COSHEAF_RESEARCH_LOOP_DEMO_PUBLIC_ARTIFACT:-definition.graph}"
PRIVATE_ARTIFACT_ID="${COSHEAF_RESEARCH_LOOP_DEMO_PRIVATE_ARTIFACT:-claim.example-private}"

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

write_failed_attempt_payload() {
  local output_path="$1"
  "$PYTHON_BIN" - "$output_path" "$LOOP_ID" "$PUBLIC_ARTIFACT_ID" "$PRIVATE_ARTIFACT_ID" <<'PY'
import json
import sys

output_path, loop_id, public_artifact_id, private_artifact_id = sys.argv[1:]
attempt_id = f"{loop_id}.attempt.1"
payload = {
    "attempt_id": attempt_id,
    "loop_id": loop_id,
    "attempt_number": 1,
    "status": "failed",
    "planned_direction": "Try direct induction",
    "started_at": "2026-06-17T00:00:00+00:00",
    "completed_at": "2026-06-17T00:01:00+00:00",
    "result_summary": "Direct induction failed on the workspace demo fixture.",
    "actions_taken": ["inspect the private draft and public seed"],
    "failures": [
        {
            "failure_id": f"failure.{attempt_id}",
            "attempt_id": attempt_id,
            "attempted_direction": "Try direct induction",
            "why_it_failed": "The induction step needs an explicit invariant.",
            "evidence_for_failure": [
                ".cosheaf/research-loop-demo/operator_task.json"
            ],
            "related_artifacts": [public_artifact_id, private_artifact_id],
            "should_retry": False,
            "avoid_in_future": (
                "Do not retry direct induction without an explicit invariant."
            ),
            "tags": ["insufficient_evidence"],
            "signature": "direct-induction-missing-invariant",
        }
    ],
    "evidence": {
        "related_artifacts": [public_artifact_id, private_artifact_id],
        "draft_artifact_refs": [private_artifact_id],
        "summary": "Workspace demo evidence is review context only.",
    },
}
with open(output_path, "w", encoding="utf-8", newline="\n") as handle:
    json.dump(payload, handle, ensure_ascii=True, indent=2)
    handle.write("\n")
PY
}

write_operator_result_payload() {
  local output_path="$1"
  "$PYTHON_BIN" - "$output_path" "$PUBLIC_ARTIFACT_ID" "$PRIVATE_ARTIFACT_ID" <<'PY'
import json
import sys

output_path, public_artifact_id, private_artifact_id = sys.argv[1:]
payload = {
    "attempted_direction": "Try direct induction",
    "actions_taken": ["retry with the missing invariant made explicit"],
    "artifacts_referenced": [public_artifact_id, private_artifact_id],
    "drafts_created": [],
    "checks_run": ["cosheaf validate", "cosheaf gate run"],
    "failures": [],
    "candidate_counterexamples": [],
    "checked_counterexamples": [],
    "evidence_refs": [".cosheaf/research-loop-demo/operator_task.json"],
    "next_recommendation": "Keep the result as draft review context only.",
    "result_summary": "Retry completed as deterministic demo output.",
    "retry_justification": "The missing invariant was made explicit before retry.",
    "claimed_authority_flags": {
        "accepted": False,
        "human_review": False,
        "verifier_pass": False,
        "gate_pass": False,
        "promotion": False,
    },
}
with open(output_path, "w", encoding="utf-8", newline="\n") as handle:
    json.dump(payload, handle, ensure_ascii=True, indent=2)
    handle.write("\n")
PY
}

clean_demo_runtime() {
  "$PYTHON_BIN" - "$REPO_ROOT" "$OUTPUT_DIR" "$LOOP_ID" <<'PY'
import shutil
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
output_dir = (repo_root / sys.argv[2]).resolve()
loop_dir = (repo_root / ".cosheaf" / "research-loops" / sys.argv[3]).resolve()

for path in (output_dir, loop_dir):
    try:
        relative = path.relative_to(repo_root)
    except ValueError:
        raise SystemExit(f"refusing to clean path outside repository: {path}") from None
    if not relative.parts or relative.parts[0] != ".cosheaf":
        raise SystemExit(f"refusing to clean non-runtime path: {relative}")
    if path.exists():
        shutil.rmtree(path)
PY
}

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  if ! use_local_framework_if_available; then
    if [[ -n "${COSHEAF_FRAMEWORK_REF:-}" ]]; then
      run "$PYTHON_BIN" -m pip install \
        "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${COSHEAF_FRAMEWORK_REF}"
      add_python_user_scripts_to_path
    else
      cat >&2 <<'EOF'
research-loop demo requires a v0.7-capable framework checkout or command.

Use one of:
  COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/demo_research_loop.sh
  COSHEAF_SKIP_INSTALL=1 COSHEAF_CMD="python -m cosheaf.cli" PYTHONPATH=../tcs-cosheaf bash scripts/demo_research_loop.sh
  COSHEAF_FRAMEWORK_REF=<v0.7-capable-ref> bash scripts/demo_research_loop.sh

The template install target remains pinned to the latest published release.
EOF
      exit 2
    fi
  fi
else
  use_local_framework_if_available || true
fi

clean_demo_runtime
mkdir -p "$OUTPUT_DIR"

run_cosheaf_to_file "$OUTPUT_DIR/01-workspace-info.json" workspace info --json
run_cosheaf_to_file "$OUTPUT_DIR/02-validate-before.json" validate --json
run_cosheaf_to_file "$OUTPUT_DIR/03-gate-before.json" gate run --json
run_cosheaf_to_file "$OUTPUT_DIR/04-loop-start.json" research-loop start \
  --issue "$ISSUE_ID" \
  --loop-id "$LOOP_ID" \
  --max-attempts 3 \
  --json

write_failed_attempt_payload "$OUTPUT_DIR/failed_attempt.json"
run_cosheaf_to_file "$OUTPUT_DIR/05-append-failed-attempt.json" research-loop append-attempt "$LOOP_ID" \
  --input-json "$OUTPUT_DIR/failed_attempt.json" \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/06-next.json" research-loop next "$LOOP_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/07-export-task.json" research-loop export-task "$LOOP_ID" \
  --out "$OUTPUT_DIR/operator_task.json" \
  --json

write_operator_result_payload "$OUTPUT_DIR/operator_result.json"
run_cosheaf_to_file "$OUTPUT_DIR/08-import-result.json" research-loop import-result "$LOOP_ID" \
  --input-json "$OUTPUT_DIR/operator_result.json" \
  --json

run_cosheaf_to_file "$OUTPUT_DIR/09-scan.json" research-loop scan "$LOOP_ID" --json
run_cosheaf_to_file "$OUTPUT_DIR/10-finalize.json" research-loop finalize "$LOOP_ID" \
  --reason "workspace research-loop demo completed without accepted writes" \
  --json

run_cosheaf validate
run_cosheaf gate run

printf '\nResearch-loop demo complete.\n'
printf 'Loop ID: %s\n' "$LOOP_ID"
printf 'Runtime outputs are under %s and .cosheaf/research-loops/%s.\n' "$OUTPUT_DIR" "$LOOP_ID"
printf 'No hosted provider, API key, MCP server, public KB change, accepted write, promotion, verifier mutation, gate mutation, or human review was performed.\n'
