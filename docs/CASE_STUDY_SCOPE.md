# Closed-Loop Case Study Scope

Status: planned

GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#100

## Research Question

Does every finite connected simple graph with minimum degree at least 2 have a
Hamiltonian cycle, or can a small counterexample be found and checked?

This is a deliberately bounded graph-theory case study for the closed-loop
research workflow:

```text
research issue -> context -> attempt -> failure memory -> candidate result
-> evidence -> review handoff -> human decision or waiting-for-review report
```

## Why This Is Small Enough

- The objects are finite simple graphs.
- The search space can be bounded to tiny graphs, initially at most 6 vertices.
- A checker can enumerate Hamiltonian cycles for a concrete candidate graph.
- The expected result is one draft artifact, not a batch import.
- The workflow can honestly record a failed proof attempt before recording any
  candidate result.

## Expected Artifact Types

- One repository-local research issue under `issues/open/`.
- One recorded attempt under an example or private research path.
- One structured failure-memory entry if the first attempt is incomplete or
  fails.
- One private draft candidate artifact, likely a counterexample or a corrected
  claim.
- One reproducible checker/evidence record when the candidate is added.
- One human review request packet.
- One final closed-loop report.

R0.1 does not add any of these artifacts yet. It only selects and bounds the
case study.

## Required Sources

This workspace currently contains only a draft seed definition for graphs:

```text
kb/public/definitions/definition.graph.yaml
```

That seed is enough to build workspace context, but it is not accepted public
knowledge. No external citation is asserted by this scope document.

Before any result can be promoted or proposed for public KB reuse, a maintainer
must provide or approve source metadata for the graph-theory terminology being
used, including connected graph, minimum degree, and Hamiltonian cycle.

## Candidate Checker And Evidence Path

The later evidence task should use a small deterministic Python checker. The
checker should be able to:

1. read a concrete finite graph adjacency list;
2. verify the graph is simple and connected;
3. compute every vertex degree and check the minimum-degree condition;
4. enumerate Hamiltonian cycles by permutations for the tiny graph size;
5. emit a machine-readable pass, fail, skipped, unavailable, or not-applicable
   status with explicit limitations.

The checker result will be evidence for the bounded finite graph only. It will
not create accepted status, human review, promotion authority, or a general
proof of any broader theorem.

## Success Criteria

The case study succeeds if it produces a complete and reviewable closed loop:

- the original research issue is clear;
- context used by the attempt is documented;
- at least one failed or incomplete attempt is preserved;
- exactly one candidate draft result is created;
- checker evidence is recorded or a non-applicable/skipped status is justified;
- a review handoff packet asks concrete reviewer questions;
- a final report explains the outcome and remaining limitations.

## Failure Or Refutation Criteria

Failure is acceptable and must be recorded. Examples include:

- the first proof attempt is incomplete;
- the candidate checker finds the proposed graph does not meet the premise;
- the candidate checker finds a Hamiltonian cycle after all;
- source metadata is unavailable;
- a reviewer requests changes or keeps the result as draft.

These outcomes do not count as accepted knowledge. They are research memory and
review context.

## Review Criteria

A human reviewer should be able to answer:

1. Is the research question stated correctly?
2. Are the graph definitions and conventions clear enough?
3. Does the candidate artifact stay draft/private until reviewed?
4. Does the checker verify exactly what the report says it verifies?
5. Are failed attempts and limitations preserved honestly?
6. Is there enough source metadata for any later public-KB proposal?

## Human-Reviewed Boundary

Codex must not record `human_reviewed`, `accepted`, or an equivalent decision
unless a maintainer supplies actual review content. If no review is supplied,
the final report must say the case study is waiting for human review.

## Possible Public-KB Path

This case study may become a public-KB candidate only after:

- a real human review decision is recorded;
- source metadata is complete;
- private notes and attempt details are screened for leakage;
- public-KB policy checks pass;
- at most one artifact is proposed in a focused public-KB PR.

Until then, all candidate results remain private draft or review context.
