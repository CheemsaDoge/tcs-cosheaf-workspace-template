#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_KB_REPO_URL="${PUBLIC_KB_REPO_URL:-https://github.com/CheemsaDoge/tcs-kb-public.git}"
TARGET_REL="${1:-.cosheaf/public-kb/tcs-kb-public}"
MODE="${2:-}"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/bootstrap_public_kb.sh [target-path] [--update]

Clones tcs-kb-public into an ignored local checkout for real-work reference.
Default target:
  .cosheaf/public-kb/tcs-kb-public

Rules:
  - Does not modify kb/public.
  - Does not copy private artifacts.
  - Refuses to overwrite an existing directory.
  - If target is an existing git checkout, --update runs a fast-forward update.
EOF
}

manual_setup_instructions() {
  cat >&2 <<EOF

Manual public KB setup:
  1. Ensure Git and network access are available, then clone:
       git clone "$PUBLIC_KB_REPO_URL" "$target_path"
  2. Keep the checkout readonly from this workspace.
  3. Do not copy private artifacts into the public KB.
  4. If you want this workspace to use that checkout directly, edit
     cosheaf.toml so the public KB root points at the checkout path.

This script did not modify kb/public.
EOF
}

case "$TARGET_REL" in
  -h|--help)
    usage
    exit 0
    ;;
  --update)
    TARGET_REL=".cosheaf/public-kb/tcs-kb-public"
    MODE="--update"
    ;;
esac

case "$MODE" in
  ""|--update) ;;
  *)
    printf 'Unsupported option: %s\n\n' "$MODE" >&2
    usage >&2
    exit 2
    ;;
esac

cd "$REPO_ROOT"

target_path="$TARGET_REL"
case "$target_path" in
  /*) ;;
  [A-Za-z]:/*|[A-Za-z]:\\*) ;;
  *) target_path="$REPO_ROOT/$target_path" ;;
esac

if ! command -v git >/dev/null 2>&1; then
  printf 'Git is required to clone or update tcs-kb-public, but git was not found on PATH.\n' >&2
  manual_setup_instructions
  exit 1
fi

if [[ -e "$target_path" ]]; then
  if [[ -d "$target_path/.git" ]]; then
    if [[ "$MODE" != "--update" ]]; then
      cat >&2 <<EOF
Public KB checkout already exists:
  $target_path

Refusing to modify it without explicit confirmation.
Run again with --update to fetch and fast-forward this checkout:
  bash scripts/bootstrap_public_kb.sh "$TARGET_REL" --update
EOF
      exit 1
    fi

    current_branch="$(git -C "$target_path" branch --show-current)"
    if [[ -z "$current_branch" ]]; then
      printf 'Target checkout is not on a branch: %s\n' "$target_path" >&2
      exit 1
    fi

    if ! git -C "$target_path" fetch --tags origin "$current_branch"; then
      printf 'Failed to fetch public KB updates for: %s\n' "$target_path" >&2
      manual_setup_instructions
      exit 1
    fi

    if ! git -C "$target_path" merge --ff-only "origin/$current_branch"; then
      printf 'Failed to fast-forward public KB checkout: %s\n' "$target_path" >&2
      manual_setup_instructions
      exit 1
    fi

    printf '\nUpdated public KB checkout: %s\n' "$target_path"
    exit 0
  fi

  cat >&2 <<EOF
Target path already exists and is not a git checkout:
  $target_path

Refusing to overwrite user work. Choose a different target path or move the
existing directory yourself after checking its contents.
EOF
  exit 1
fi

mkdir -p "$(dirname "$target_path")"
if ! git clone "$PUBLIC_KB_REPO_URL" "$target_path"; then
  printf 'Failed to clone public KB into: %s\n' "$target_path" >&2
  manual_setup_instructions
  exit 1
fi

cat <<EOF

Cloned public KB checkout:
  $target_path

This script did not modify kb/public and did not copy private artifacts.
Use this checkout as a readonly reference, or explicitly edit cosheaf.toml if
you want this workspace to point at a different public KB root.
EOF
