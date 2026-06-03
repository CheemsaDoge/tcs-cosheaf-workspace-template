# Repository Instructions

This is a user workspace template for TCS-Cosheaf. It is not the framework repository and not the public KB repository.

## Workspace Model

- `tcs-cosheaf` is the framework repository and provides the CLI, schemas,
  validation, gates, graph tools, and context-pack tooling.
- `tcs-kb-public` is the public reusable KB repository.
- This repository is a user-facing workspace template that combines the
  framework package, a readonly public KB root, and a writable private KB root.
- Public KB is readonly common knowledge.
- Private KB is the user's writable research overlay.
- Private artifacts may depend on public artifacts.
- Public artifacts may not depend on private artifacts.
- Do not manually merge framework and KB repositories.
- Use `cosheaf.toml` to define the workspace and KB roots.
- Do not place private conjectures into the public KB.
- Do not promote private claims to accepted without review and gates.

## Workflow

- Use issues for nontrivial research tasks.
- Use branches named `codex/<task-id-or-short-name>`.
- Keep each branch focused on one reviewable increment.
- Use context packs for task-specific agent work when issue context exists.
- Record durable decisions in repository files; Codex conversations are not project memory.

## Knowledge Policy

- Keep public/common knowledge in `kb/public/`.
- Keep private conjectures, proof attempts, failures, and notes in `kb/private/`.
- Treat `kb/public/` as readonly once it is replaced by or mounted from `tcs-kb-public`.
- Never leak private research into public KB unless it is explicitly promoted, reviewed, and gated.
- Accepted artifacts require source metadata and human review.
- Public accepted artifacts require structured source metadata.

## Validation

Run available checks before opening or updating a PR:

- `cosheaf workspace info`
- `cosheaf validate`
- `cosheaf gate run`
- `cosheaf gate run --pr-checklist .github/pull_request_template.md`

If a command is unavailable or fails due to the environment, report it exactly. Skipped is not pass.
