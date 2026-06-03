# Workspace Model

The intended user model is:

```text
framework package + readonly public KB + writable private KB overlay
```

The framework package provides the CLI, schemas, validation, gates, graph tools, and context-pack tooling. The public KB provides shared public knowledge. The private KB stores the user's own research.

## KB Roots

`cosheaf.toml` defines two KB roots:

- `public`: `kb/public`, readonly, priority 10.
- `private`: `kb/private`, writable, priority 20.

Private artifacts may depend on public artifacts. Public artifacts must not depend on private artifacts. Accepted artifacts must not depend on draft artifacts.

## Promotion

Private work may be promoted only when the user explicitly chooses to do so and the artifact passes review and gates. Promotion should create a focused issue and PR in the target public repository.
