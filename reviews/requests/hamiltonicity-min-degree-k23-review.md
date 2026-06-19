# Human Review Request: K2,3 Hamiltonicity Minimum-Degree Candidate

Status: not yet human-reviewed

GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#114

## Target Artifact

`kb/private/counterexamples/counterexample.hamiltonicity-min-degree.k23.yaml`

Artifact id:
`counterexample.hamiltonicity-min-degree.k23`

Current lifecycle status:
`draft`

Current review state:
`requested`

This packet is informational review context only. It does not approve the
artifact, create `human_reviewed` status, promote the artifact, or create
accepted knowledge.

## Original Issue

Local research issue:
`issues/open/issue.hamiltonicity-min-degree-counterexample.yaml`

Research question:

```text
Does every finite connected simple graph with minimum degree at least 2 have a
Hamiltonian cycle, or can a small counterexample be found and checked?
```

## Statement Under Review

Candidate counterexample to the statement:

```text
Every finite connected simple graph with minimum degree at least 2 has a
Hamiltonian cycle.
```

The candidate graph is the complete bipartite graph `K_{2,3}` with parts:

```text
A = {a1, a2}
B = {b1, b2, b3}
```

The edge set contains exactly the six cross-part edges:

```text
a1-b1, a1-b2, a1-b3,
a2-b1, a2-b2, a2-b3
```

Under the standard finite simple undirected graph convention, this graph is
connected and has minimum degree 2. The candidate non-Hamiltonicity reason is
that every cycle in a bipartite graph alternates parts, so a Hamiltonian cycle
would need equal part sizes, but `K_{2,3}` has part sizes 2 and 3.

## Dependencies

- `definition.graph`
- `proof-attempt.hamiltonicity-min-degree.longest-path-closure`

Dependency paths:

- `kb/public/definitions/definition.graph.yaml`
- `kb/private/proof_attempts/proof-attempt.hamiltonicity-min-degree.longest-path-closure.yaml`

The `definition.graph` dependency is template seed material in this workspace,
not accepted public KB. The candidate remains private draft material.

## Sources

The candidate artifact currently records one internal source note:

- kind: `internal_note`
- title: `Closed-loop case study draft candidate note`
- authors: `workspace-user`
- year: `2026`

No external source or published citation is claimed for this draft candidate.
The reviewer should treat the statement and reasoning as workspace draft
material.

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

Recorded finite-check facts:

- graph is simple: `true`
- graph is connected: `true`
- minimum degree: `2`
- Hamiltonian cycle count: `0`

Checker limitation:
the checker enumerates Hamiltonian cycles for this one finite graph only. It
does not prove a general theorem, perform human review, establish semantic
alignment, create gate or verifier authority, or promote the artifact.

## Failed Attempts And Failure Memory

Attempt record:
`examples/attempts/hamiltonicity-min-degree-attempt-1.md`

Failure-memory artifact:
`kb/private/proof_attempts/proof-attempt.hamiltonicity-min-degree.longest-path-closure.yaml`

Failure id:
`failure.hamiltonicity-min-degree.longest-path-extension`

Summary:
the direct longest-path argument shows that some cycle exists in a finite
connected simple graph with minimum degree at least 2, but it does not justify
extending that cycle to every vertex. The failure memory recommends searching
for a small non-Hamiltonian candidate and attaching checker evidence.

## Known Risks

- The candidate is still draft/private and has not received human review.
- The graph convention depends on the workspace seed `definition.graph`, which
  is draft template material rather than accepted public KB.
- The checker validates only the finite `K_{2,3}` candidate.
- The checker status is not human review, accepted status, verifier authority,
  gate authority, formal proof, or promotion authority.
- No external source is claimed for this draft candidate.
- Public KB movement would require source metadata, real human review, policy
  checks, and a separate public-KB decision.

## Questions For Reviewer

1. Are the graph conventions clear enough to interpret the candidate as a
   finite simple undirected graph?
2. Is `K_{2,3}` a valid connected simple graph with minimum degree at least 2
   under those conventions?
3. Is the bipartite unequal-part argument sufficient to establish that this
   graph has no Hamiltonian cycle?
4. Does the local checker accurately encode the intended `K_{2,3}` graph and
   Hamiltonian-cycle enumeration?
5. Are the limitations and non-authority boundaries stated strongly enough?
6. Should the artifact remain draft, receive changes, be refuted, or be marked
   as a candidate for a later public-KB proposal?

## Explicit Review Boundary

This review request is not a review decision. The artifact is not yet
human-reviewed. No accepted status, promotion, public-KB write, verifier pass,
gate pass, or human-review state is created by this packet.
