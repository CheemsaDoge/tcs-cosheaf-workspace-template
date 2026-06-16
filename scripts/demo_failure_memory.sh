#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.5.0}"
INSTALL_FRAMEWORK="${COSHEAF_INSTALL_FRAMEWORK:-0}"
OUTPUT_DIR="${COSHEAF_FAILURE_DEMO_OUTPUT_DIR:-.cosheaf/failure-memory-demo}"
DEMO_WORKSPACE="$OUTPUT_DIR/workspace"
ARTIFACT_ID="${COSHEAF_FAILURE_DEMO_ARTIFACT:-claim.example-private}"

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
  local output_path="$REPO_ROOT/$OUTPUT_DIR/$name.json"
  printf '\n# output: %s\n' "$output_path"
  run_cosheaf "$@" | tee "$output_path"
}

capture_json_allow_status() {
  local name="$1"
  local expected_status="$2"
  shift 2
  local output_path="$REPO_ROOT/$OUTPUT_DIR/$name.json"
  local statuses
  local command_status
  local tee_status

  printf '\n# output: %s\n' "$output_path"
  set +e
  run_cosheaf "$@" | tee "$output_path"
  statuses=("${PIPESTATUS[@]}")
  set -e

  command_status="${statuses[0]}"
  tee_status="${statuses[1]:-0}"
  if [[ "$tee_status" -ne 0 ]]; then
    printf 'tee failed with exit status %s\n' "$tee_status" >&2
    exit "$tee_status"
  fi
  if [[ "$command_status" -ne "$expected_status" ]]; then
    printf 'Expected command exit status %s, got %s\n' \
      "$expected_status" "$command_status" >&2
    exit "$command_status"
  fi
  printf '# expected command exit status: %s\n' "$command_status" >&2
}

if [[ "$INSTALL_FRAMEWORK" == "1" && "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  run "$PYTHON_BIN" -m pip install \
    "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
  add_python_user_scripts_to_path
fi

if ! run_cosheaf artifact failure add --help >/dev/null 2>&1; then
  printf 'The active cosheaf CLI does not expose artifact failure-log commands.\n' >&2
  printf 'Use a framework checkout or release with artifact failure-log support, for example:\n' >&2
  printf '  COSHEAF_CMD="python -m cosheaf.cli" PYTHONPATH="<path-to-tcs-cosheaf>" bash scripts/demo_failure_memory.sh\n' >&2
  printf 'Or explicitly install a source with COSHEAF_INSTALL_FRAMEWORK=1 COSHEAF_FRAMEWORK_REF=<ref>.\n' >&2
  exit 2
fi

case "$DEMO_WORKSPACE" in
  .cosheaf/failure-memory-demo/workspace)
    rm -rf "$DEMO_WORKSPACE"
    ;;
  *)
    printf 'Refusing to remove unexpected demo workspace path: %s\n' \
      "$DEMO_WORKSPACE" >&2
    exit 1
    ;;
esac

mkdir -p "$OUTPUT_DIR"
mkdir -p "$DEMO_WORKSPACE"
cp cosheaf.toml "$DEMO_WORKSPACE/"
cp -R kb "$DEMO_WORKSPACE/"
cp -R issues "$DEMO_WORKSPACE/"
cp -R formal-libs "$DEMO_WORKSPACE/"
mkdir -p "$DEMO_WORKSPACE/.github"
cp .github/pull_request_template.md "$DEMO_WORKSPACE/.github/"

FAILURE_ENTRY="$REPO_ROOT/$OUTPUT_DIR/failure-entry.json"
cat > "$FAILURE_ENTRY" <<'JSON'
{
  "failure_id": "failure.workspace-demo.0001",
  "attempted_at": "2026-06-15T00:00:00Z",
  "recorded_by": "workspace-demo",
  "origin": "human",
  "attempt_kind": "proof_attempt",
  "target": "claim.example-private",
  "direction": "Try to prove the private draft directly from the graph definition.",
  "summary": "The demo records a failed direct proof direction on the private draft example.",
  "failed_because": "The draft statement is only a template example and has no reviewed mathematical proof obligation.",
  "evidence_paths": [],
  "related_verifier_results": [],
  "related_counterexample_candidates": [],
  "next_possible_directions": [
    "Replace the template claim with a real private draft before attempting proof work.",
    "Mount tcs-kb-public as readonly public context for real dependencies."
  ],
  "status": "open",
  "limitations": "Workspace demo failure memory only; not proof, refutation, verifier evidence, human review, gate success, or accepted knowledge."
}
JSON

pushd "$DEMO_WORKSPACE" >/dev/null
capture_json 01-workspace-info workspace info --json
capture_json 02-validate-before validate --json
capture_json 03-gate-before gate run --json
capture_json 04-pr-checklist-before gate run \
  --pr-checklist .github/pull_request_template.md \
  --json
capture_json 05-failures-before artifact failures "$ARTIFACT_ID" --json
capture_json 06-failure-add-dry-run artifact failure add \
  --artifact "$ARTIFACT_ID" \
  --input-json "$FAILURE_ENTRY" \
  --json \
  --dry-run
capture_json 07-failure-add artifact failure add \
  --artifact "$ARTIFACT_ID" \
  --input-json "$FAILURE_ENTRY" \
  --json
capture_json 08-failures-after artifact failures "$ARTIFACT_ID" --json
capture_json_allow_status 09-promotion-readiness 1 promotion readiness \
  --artifact "$ARTIFACT_ID" \
  --json
capture_json 10-validate-after validate --json
capture_json 11-gate-after gate run --json
popd >/dev/null

printf '\nFailure-memory demo complete.\n'
printf 'Runtime workspace and JSON outputs are under %s.\n' "$OUTPUT_DIR"
printf 'The source kb/private artifact was not modified.\n'
printf 'No accepted write, promotion, provider call, API key, network install, or human-review spoofing was performed by default.\n'
