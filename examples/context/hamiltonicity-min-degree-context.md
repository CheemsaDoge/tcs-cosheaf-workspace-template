# Hamiltonicity Minimum-Degree Context

Issue: `issue.hamiltonicity-min-degree-counterexample`

GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#104

## Commands

Required plan command:

```bash
make context
```

That target currently builds the template example issue:
`issue.example-private-claim`.

Case-study context command:

```bash
cosheaf context build issue.hamiltonicity-min-degree-counterexample
```

Generated runtime output:

```text
context/TASKS/issue.hamiltonicity-min-degree-counterexample/
```

The generated directory is ignored by repository policy, so this committed file
records the reproducible summary instead of committing the raw pack.

## Context Summary

The case-study pack is cards-only:

- artifact cards: 2
- accepted artifacts: 0
- full artifact pulls: 0
- failure-memory entries: 0
- checked counterexample evidence entries: 0

The pack is context for a researcher or agent. It is not proof, verifier
success, gate success, human review, promotion evidence, or accepted
knowledge.

## Included Artifacts And Sources

- `definition.graph`
  - path: `kb/public/definitions/definition.graph.yaml`
  - status: draft
  - root scope: public
  - relevance: direct reference from the issue, graph-domain lexical matches,
    and memory-graph ranking
  - formal-link note: planned CSLib metadata only; no Lean check or semantic
    alignment review is claimed
- `claim.example-private`
  - path: `kb/private/claims/claim.example-private.yaml`
  - status: draft
  - root scope: private
  - relevance: graph-domain and dependency matches from the template example

## Excluded Artifacts And Sources

The retrieval audit reported no explicit exclusions. The default build did not
pull full artifact YAML because `--max-full-artifacts` defaults to `0`.

## Known Context Gaps

- No accepted public graph-theory foundation artifact was included.
- The workspace seed `definition.graph` is draft demo material, not accepted
  public KB.
- No candidate theorem, counterexample, construction, proof attempt, or
  checker evidence exists yet for this issue.
- No failure memory exists yet for this issue.
- `PROJECT_STATE.md` and `INTERFACE_REGISTRY.md` were unavailable in the
  generated context pack.
- Formal links in included cards are metadata only and do not show checker
  execution or informal/formal semantic alignment.
