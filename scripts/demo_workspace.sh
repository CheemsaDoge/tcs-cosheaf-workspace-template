#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python}"
cd "$REPO_ROOT"

run() {
  printf '\n+'
  printf ' %q' "$@"
  printf '\n'
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

run "$PYTHON_BIN" -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.6.0"
add_python_user_scripts_to_path
run cosheaf workspace info
run cosheaf validate
run cosheaf gate run
run cosheaf gate run --pr-checklist .github/pull_request_template.md
run cosheaf context build issue.example-private-claim
