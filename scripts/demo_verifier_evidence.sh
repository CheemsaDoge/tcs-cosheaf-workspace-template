#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_REF="${COSHEAF_FRAMEWORK_REF:-v0.9.0}"
OUTPUT_DIR="${COSHEAF_VERIFIER_DEMO_OUTPUT_DIR:-.cosheaf/verifier-evidence-demo}"
ARTIFACT_ID="${COSHEAF_VERIFIER_DEMO_ARTIFACT:-claim.example-private}"

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
    local cmd=($COSHEAF_CMD)
    run "${cmd[@]}" "$@"
  else
    run "${COSHEAF:-cosheaf}" "$@"
  fi
}

cosheaf_supports() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    local cmd=($COSHEAF_CMD)
    "${cmd[@]}" "$@" --help >/dev/null 2>&1
  else
    "${COSHEAF:-cosheaf}" "$@" --help >/dev/null 2>&1
  fi
}

capture_json() {
  local name="$1"
  shift
  local output_path="$OUTPUT_DIR/$name.json"
  printf '\n# output: %s\n' "$output_path"
  run_cosheaf "$@" | tee "$output_path"
}

capture_json_allow_nonzero() {
  local name="$1"
  shift
  local output_path="$OUTPUT_DIR/$name.json"
  printf '\n# output: %s\n' "$output_path"
  set +e
  run_cosheaf "$@" >"$output_path"
  local rc=$?
  set -e
  cat "$output_path"
  printf '\n# exit_code: %s\n' "$rc"
  return "$rc"
}

write_unavailable_json() {
  local output_path="$1"
  local command_name="$2"
  "$PYTHON_BIN" - "$output_path" "$command_name" <<'PY'
import json
import sys

path, command = sys.argv[1:3]
payload = {
    "schema_version": 1,
    "kind": "verifier_evidence_demo_unavailable",
    "command": command,
    "status": "unavailable",
    "treated_as_pass": False,
    "message": (
        "The installed framework does not expose this optional command. "
        "Unavailable is reported explicitly and is not a pass."
    ),
}
with open(path, "w", encoding="utf-8", newline="\n") as handle:
    json.dump(payload, handle, ensure_ascii=True, indent=2)
    handle.write("\n")
print(json.dumps(payload, ensure_ascii=True, indent=2))
PY
}

if [[ "${COSHEAF_SKIP_INSTALL:-0}" != "1" ]]; then
  run "$PYTHON_BIN" -m pip install \
    "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@${FRAMEWORK_REF}"
  add_python_user_scripts_to_path
fi

mkdir -p "$OUTPUT_DIR"

capture_json 01-workspace-info workspace info --json
capture_json 02-validate validate --json
capture_json 03-gate-run gate run --json

"$PYTHON_BIN" - \
  "$OUTPUT_DIR/03-gate-run.json" \
  "$OUTPUT_DIR/04-skipped-not-pass-summary.json" <<'PY'
import json
import sys
from pathlib import Path

gate_json = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
payload = json.loads(gate_json.read_text(encoding="utf-8"))
report_path = Path(payload["report_json_path"])
report = json.loads(report_path.read_text(encoding="utf-8"))
gates = {gate["id"]: gate for gate in report["gates"]}
g6 = gates.get("G6", {})
status = str(g6.get("status", "missing"))
summary = {
    "schema_version": 1,
    "kind": "skipped_not_pass_boundary",
    "gate_id": "G6",
    "gate_name": g6.get("name", "verifier gate"),
    "gate_status": status,
    "treated_as_pass": status == "pass",
    "message": g6.get("summary", "G6 verifier gate status was not available."),
}
summary_path.write_text(
    json.dumps(summary, ensure_ascii=True, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(summary, ensure_ascii=True, indent=2))
if summary["treated_as_pass"]:
    raise SystemExit("G6 verifier status was pass; expected skipped/not_applicable")
if status not in {"skipped", "not_applicable"}:
    raise SystemExit(f"Unexpected G6 verifier status for demo: {status}")
PY

if cosheaf_supports promotion readiness; then
  if capture_json_allow_nonzero 05-promotion-readiness \
    promotion readiness --artifact "$ARTIFACT_ID" --json; then
    readiness_rc=0
  else
    readiness_rc=$?
  fi
  "$PYTHON_BIN" - \
    "$OUTPUT_DIR/05-promotion-readiness.json" \
    "$readiness_rc" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
exit_code = int(sys.argv[2])
payload = json.loads(path.read_text(encoding="utf-8"))
if payload.get("accepted_write_performed") is not False:
    raise SystemExit("promotion readiness must not write accepted knowledge")
if payload.get("ready") is not False:
    raise SystemExit("template draft artifact should not be promotion-ready")
codes = {
    reason.get("code")
    for artifact in payload.get("artifacts", [])
    for reason in artifact.get("reasons", [])
}
required = {"draft_status", "missing_review"}
missing = required - codes
if missing:
    raise SystemExit(f"promotion readiness did not report expected blockers: {sorted(missing)}")
print(
    json.dumps(
        {
            "schema_version": 1,
            "kind": "promotion_readiness_boundary",
            "command_exit_code": exit_code,
            "ready": payload.get("ready"),
            "accepted_write_performed": payload.get("accepted_write_performed"),
            "blocking_codes": sorted(codes),
            "treated_as_pass": False,
        },
        ensure_ascii=True,
        indent=2,
    )
)
PY
else
  write_unavailable_json \
    "$OUTPUT_DIR/05-promotion-readiness-unavailable.json" \
    "cosheaf promotion readiness"
fi

printf '\nVerifier evidence demo complete.\n'
printf 'JSON outputs are under %s.\n' "$OUTPUT_DIR"
printf 'No API key, hosted provider, MCP, accepted write, promotion, or human review was performed.\n'
