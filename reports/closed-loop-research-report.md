# Closed-Loop Research Report: Hamiltonicity Minimum-Degree Case Study

GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#118

## Original Question

Does every finite connected simple graph with minimum degree at least 2 have a
Hamiltonian cycle, or can a small counterexample be found and checked?

Local issue:
`issues/open/issue.hamiltonicity-min-degree-counterexample.yaml`

## Context Used

The case-study context was built with:

```bash
cosheaf context build issue.hamiltonicity-min-degree-counterexample
```

Committed context summary:
`examples/context/hamiltonicity-min-degree-context.md`

The context pack was cards-only. It included draft cards for `definition.graph`
and `claim.example-private`. It included no accepted artifacts, no full
artifact YAML, no failure memory, and no checked counterexample evidence at
that stage.

## Attempts

The first attempt tried a longest-path proof of the universal statement:

```text
Every finite connected simple graph with minimum degree at least 2 has a
Hamiltonian cycle.
```

Attempt record:
`examples/attempts/hamiltonicity-min-degree-attempt-1.md`

The attempt failed because the longest-path argument shows that some cycle
exists, but does not justify extending that cycle to all vertices.

## Failure Memory

Failure-memory artifact:
`kb/private/proof_attempts/proof-attempt.hamiltonicity-min-degree.longest-path-closure.yaml`

Failure id:
`failure.hamiltonicity-min-degree.longest-path-extension`

The failure memory kept the incomplete extension step visible and directed the
next step toward a small checked counterexample.

## Candidate Result

Draft candidate artifact:
`kb/private/counterexamples/counterexample.hamiltonicity-min-degree.k23.yaml`

Candidate:
`K_{2,3}`, the complete bipartite graph with part sizes 2 and 3.

Draft reasoning:
`K_{2,3}` is finite, connected, simple, and has minimum degree 2. Any cycle in
a bipartite graph alternates between the two parts, so a Hamiltonian cycle
would require equal part sizes. The parts of `K_{2,3}` are unequal.

## Evidence And Checker Status

Checker:
`checkers/check_k23_hamiltonicity.py`

Saved output:
`evidence/hamiltonicity-min-degree-k23-check.json`

Reproduction command:

```bash
python checkers/check_k23_hamiltonicity.py --json
```

Recorded checker status:
`pass`

Recorded finite-check result:
the graph is simple, connected, has minimum degree 2, and has zero enumerated
Hamiltonian cycles.

The checker is evidence for this finite graph only. It is not a proof of a
general theorem, not human review, not gate or verifier authority, and not
accepted knowledge.

## Review Handoff

Human review request:
`reviews/requests/hamiltonicity-min-degree-k23-review.md`

The handoff packet collected the target artifact, original issue, statement,
dependencies, source note, checker status, failed attempt, failure memory,
risks, and reviewer questions.

## Human Review Outcome

Human review decision:
`reviews/human/hamiltonicity-min-degree-k23-decision.md`

Decision:
`keep_draft`

The maintainer stated that review was completed. No explicit acceptance,
changes-requested, refutation, or public-KB suitability decision was supplied,
so the conservative lifecycle outcome is to keep the candidate as a private
draft.

## Final Artifact Lifecycle State

Final artifact id:
`counterexample.hamiltonicity-min-degree.k23`

Final artifact status:
`draft`

Final review state:
`human_reviewed`

No accepted status, public KB write, source-metadata upgrade, verifier pass,
gate-authority claim, or promotion was created.

## What Cosheaf Improved

Cosheaf made the research loop inspectable:

- the question was captured as a local issue;
- the context pack showed what the researcher had available;
- the failed proof direction stayed visible as failure memory;
- the candidate result stayed private and draft;
- checker evidence was tied to the exact candidate artifact;
- the human review request was self-contained;
- the final lifecycle state stayed separate from checker and gate results.

## Remaining Limitations

- The public seed `definition.graph` in this workspace is draft demo material,
  not accepted public KB.
- The checker covers only `K_{2,3}`.
- The artifact remains private draft and is not public-KB material.
- The workflow did not prove a general theorem or run a formal verifier.
- R7 public KB contribution is intentionally skipped because the review
  outcome did not mark the result suitable for public KB.
