# Workspace Model

The intended user model is:

```text
framework package + readonly public KB + writable private KB overlay
```

The `tcs-cosheaf` framework package provides the CLI, schemas, validation,
gates, graph tools, and context-pack tooling. The `tcs-kb-public` repository
provides shared public knowledge. The private KB stores the user's own research.
Users should not manually merge framework and KB repositories.

## KB Roots

`cosheaf.toml` defines two KB roots:

- `public`: `kb/public`, readonly, priority 10.
- `private`: `kb/private`, writable, priority 20.

Private artifacts may depend on public artifacts. Public artifacts must not
depend on private artifacts. Accepted artifacts must not depend on draft
artifacts. Public accepted artifacts require structured source metadata.

## Demo Flow

The template includes a small end-to-end draft-only demo:

- `kb/public/definitions/definition.graph.yaml` is a public seed definition.
- `kb/private/claims/claim.example-private.yaml` is a private draft claim.
- `issues/open/issue.example-private-claim.yaml` describes the task and links
  both artifacts for context-pack generation.

The demo exercises the intended direction:

```text
private draft claim -> public graph definition seed
```

Run the flow with:

```bash
cosheaf workspace info
cosheaf validate
cosheaf gate run
cosheaf gate run --pr-checklist .github/pull_request_template.md
cosheaf context build issue.example-private-claim
```

The demo does not create accepted artifacts, does not claim novelty, and does
not require SAT, SMT, Lean, or imported papers.

## Promotion

Private work may be promoted only when the user explicitly chooses to do so and
the artifact passes review and gates. Promotion should create a focused issue
and PR in the target public repository.
