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

run "$PYTHON_BIN" -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.10.0"
add_python_user_scripts_to_path

PUBLIC_KB_TARGET=".cosheaf/public-kb/tcs-kb-public"
if [[ -d "$PUBLIC_KB_TARGET/.git" ]]; then
  run bash scripts/bootstrap_public_kb.sh "$PUBLIC_KB_TARGET" --update
else
  run bash scripts/bootstrap_public_kb.sh "$PUBLIC_KB_TARGET"
fi
run cosheaf workspace info
run cosheaf validate
run cosheaf gate run
run cosheaf gate run --pr-checklist .github/pull_request_template.md
run cosheaf index rebuild
run cosheaf context build issue.example-private-claim

if cosheaf orchestrator run --help >/dev/null 2>&1; then
  run_root=".cosheaf/orchestrator/issue.example-private-claim/runs/run.issue.example-private-claim"
  task_root_prefix=".cosheaf/tasks/task.node.issue.example-private-claim."
  if [[ -d "$run_root" ]]; then
    case "$run_root" in
      .cosheaf/orchestrator/*)
        printf '\n# removing previous ignored runtime run: %s\n' "$run_root"
        rm -rf "$run_root"
        ;;
      *)
        printf 'Refusing to remove unexpected path: %s\n' "$run_root" >&2
        exit 1
        ;;
    esac
  fi
  if compgen -G "${task_root_prefix}*" >/dev/null; then
    for task_root in "${task_root_prefix}"*; do
      if [[ -e "$task_root" ]]; then
        case "$task_root" in
          .cosheaf/tasks/task.node.issue.example-private-claim.*)
            printf '\n# removing previous ignored task runtime: %s\n' "$task_root"
            rm -rf "$task_root"
            ;;
          *)
            printf 'Refusing to remove unexpected path: %s\n' "$task_root" >&2
            exit 1
            ;;
        esac
      fi
    done
  fi
  run cosheaf orchestrator run --issue issue.example-private-claim --dry-run --local-only
else
  printf '\n# Optional dry-run worker skipped: installed cosheaf does not expose orchestrator run.\n'
fi

printf '\nShowcase complete. No artifact promotion was performed.\n'
