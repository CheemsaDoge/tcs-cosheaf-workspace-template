#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
FRAMEWORK_ROOT="${COSHEAF_FRAMEWORK_ROOT:-$REPO_ROOT/../tcs-cosheaf}"
WORKTREE_FRAMEWORK_ROOT="$REPO_ROOT/../../tcs-cosheaf"
OUTPUT_DIR="${COSHEAF_SITE_DEMO_OUTPUT_DIR:-examples/site-data}"

cd "$REPO_ROOT"

use_local_framework_if_available() {
  if [[ -n "${COSHEAF_CMD:-}" ]]; then
    return 0
  fi
  if [[ ! -d "$FRAMEWORK_ROOT/cosheaf" && -d "$WORKTREE_FRAMEWORK_ROOT/cosheaf" ]]; then
    FRAMEWORK_ROOT="$WORKTREE_FRAMEWORK_ROOT"
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
  printf '\n+' >&2
  printf ' %q' "${cmd[@]}" "$@" >&2
  printf '\n' >&2
  "${cmd[@]}" "$@"
}

clean_output_dir() {
  "$PYTHON_BIN" - "$REPO_ROOT" "$OUTPUT_DIR" <<'PY'
import shutil
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
output = (repo_root / sys.argv[2]).resolve()
allowed = (repo_root / "examples" / "site-data").resolve()
if output != allowed:
    raise SystemExit(f"refusing to clean unexpected output dir: {output}")
if output.exists():
    shutil.rmtree(output)
output.mkdir(parents=True, exist_ok=True)
PY
}

check_export() {
  "$PYTHON_BIN" - "$REPO_ROOT" "$OUTPUT_DIR" <<'PY'
import json
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
out = (repo_root / sys.argv[2]).resolve()
required = [
    "site.json",
    "workspace.json",
    "artifacts.json",
    "issues.json",
    "graph.json",
    "gates.json",
    "context_packs.json",
    "reports.json",
    "authority_boundaries.json",
]
missing = [name for name in required if not (out / name).is_file()]
if missing:
    raise SystemExit(f"missing site export files: {missing}")

artifacts = json.loads((out / "artifacts.json").read_text(encoding="utf-8"))
issues = json.loads((out / "issues.json").read_text(encoding="utf-8"))
artifact_ids = {item["id"] for item in artifacts["artifacts"]}
issue_ids = {item["id"] for item in issues["issues"]}
if "definition.graph" not in artifact_ids:
    raise SystemExit("site demo export is missing definition.graph")
if "claim.example-private" not in artifact_ids:
    raise SystemExit("site demo export is missing the demo private claim")
if "issue.example-private-claim" not in issue_ids:
    raise SystemExit("site demo export is missing the demo issue")

combined = "\n".join((out / name).read_text(encoding="utf-8") for name in required)
for forbidden in [
    "This private draft example depends on artifact id",
    "API_KEY",
    "OPENAI_API_KEY",
    "sk-",
]:
    if forbidden in combined:
        raise SystemExit(f"site demo export contains forbidden text: {forbidden}")
PY
}

use_local_framework_if_available || true
if ! run_cosheaf site export --help >/dev/null; then
  cat >&2 <<'EOF'
cosheaf site export is unavailable.

Use a framework checkout or command that includes Longplan B W1.1:

  COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/export_site_demo.sh
  COSHEAF_CMD="python -m cosheaf.cli" PYTHONPATH=../tcs-cosheaf bash scripts/export_site_demo.sh
EOF
  exit 1
fi

clean_output_dir
run_cosheaf site export --demo --out "$OUTPUT_DIR" --repo-root "$REPO_ROOT" --json
check_export

printf '\nSite demo export complete: %s\n' "$OUTPUT_DIR"
printf 'The fixture is demo-only display data, not accepted knowledge or review authority.\n'
