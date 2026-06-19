# Closed-Loop Research Case Study

Status: final report complete; human-reviewed and kept as private draft

Scope document: [Closed-Loop Case Study Scope](CASE_STUDY_SCOPE.md)

Scope GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#100

Local research issue:
`issues/open/issue.hamiltonicity-min-degree-counterexample.yaml`

R1.1 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#102

R1.2 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#104

Context summary:
[Hamiltonicity minimum-degree context](../examples/context/hamiltonicity-min-degree-context.md)

R2.1 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#106

First attempt:
[Hamiltonicity minimum-degree attempt 1](../examples/attempts/hamiltonicity-min-degree-attempt-1.md)

R2.2 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#108

Failure memory artifact:
`kb/private/proof_attempts/proof-attempt.hamiltonicity-min-degree.longest-path-closure.yaml`

R3.1 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#110

Draft candidate artifact:
`kb/private/counterexamples/counterexample.hamiltonicity-min-degree.k23.yaml`

R3.2 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#112

Checker evidence:
`evidence/hamiltonicity-min-degree-k23-check.json`

R4.1 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#114

Review handoff packet:
[Human review request for K2,3 candidate](../reviews/requests/hamiltonicity-min-degree-k23-review.md)

R5.1 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#116

Human review decision:
[Human review decision for K2,3 candidate](../reviews/human/hamiltonicity-min-degree-k23-decision.md)

R6.1 GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#118

Final report:
[Closed-loop research report](../reports/closed-loop-research-report.md)

## Current State

R0.1 selected the case study:

```text
Does every finite connected simple graph with minimum degree at least 2 have a
Hamiltonian cycle, or can a small counterexample be found and checked?
```

R1.1 created a local file-based issue for this question. R1.2 built and
inspected a cards-only context pack for that issue. R2.1 recorded a failed or
incomplete proof attempt based on longest paths and cycle extension. R2.2
converted that failed direction into structured failure memory on a private
draft `proof_attempt` artifact. R3.1 added exactly one private draft
counterexample candidate, `K_{2,3}`. R3.2 attached reproducible local checker
evidence for that finite graph. R4.1 prepared a human review request packet.
R5.1 recorded maintainer review completion with decision `keep_draft`. R6.1
added the final closed-loop report. No proof, accepted artifact, verifier
pass, public-KB write, or promotion is recorded by this document.

## Planned Workflow

1. Create one local file-based research issue for the question. Done in R1.1.
2. Build a context pack for that issue and record what context was used. Done
   in R1.2.
3. Record a first attempt, including failure or incompleteness if present.
   Done in R2.1.
4. Convert the failure or incomplete direction into durable failure memory.
   Done in R2.2.
5. Add exactly one private draft candidate result. Done in R3.1.
6. Attach reproducible checker evidence or explain why no checker applies.
   Done in R3.2.
7. Export a review handoff packet for a human reviewer. Done in R4.1.
8. Record a real review decision only if a maintainer supplies one. Done in
   R5.1.
9. Write a final report for website/showcase use. Done in R6.1.

## Boundaries

- The workspace public seed is draft demo material, not accepted public KB.
- The case study must not use hosted providers.
- The case study must not invent citations.
- Checker output is evidence only for the stated finite check.
- Gate, verifier, AI, operator, and checker outputs are not human review.
- Skipped or unavailable checks are not pass.
- A final waiting-for-review report is acceptable if no real human review is
  supplied.

## Current Local Issue

The local issue records:

- the research question;
- expected outputs for the closed-loop workflow;
- review criteria;
- non-authority boundaries;
- the current dependency on the draft workspace seed `definition.graph`.

It is repository research context only. It is not accepted knowledge and does
not add any candidate result.

## Current Context Pack

R1.2 used:

```bash
make context
cosheaf context build issue.hamiltonicity-min-degree-counterexample
```

`make context` still builds the template example issue. The case-study context
pack was built with the direct `cosheaf context build` command above and then
summarized under `examples/context/` because generated `context/TASKS/`
outputs are ignored runtime artifacts.

The generated pack included two draft artifact cards:

- `definition.graph` from the template public seed;
- `claim.example-private` from the template private example.

It included no accepted artifacts, no full artifact YAML, no failure memory,
and no checked counterexample evidence. Context is guidance only, not proof or
review authority.

## Current Attempt

R2.1 records a direct proof attempt:

```text
Use a longest path to force a cycle, then try to extend that cycle to all
vertices.
```

The attempt status is failed/incomplete. The longest-path argument shows that
a cycle exists under the minimum-degree condition, but it does not show that a
cycle can be extended to a Hamiltonian cycle. The attempt records no checker
run, no exhaustive search, and no candidate graph.

## Current Failure Memory

R2.2 records one open failure-log entry:

```text
failure.hamiltonicity-min-degree.longest-path-extension
```

The entry targets the local research issue and records that the cycle-extension
step is unsupported. It recommends a small-graph search next, with checker
evidence required later if a finite candidate graph is recorded.

The failure memory is attached to a private draft `proof_attempt` artifact. It
is research memory only, not proof, refutation, verifier success, gate
success, human review, promotion evidence, or accepted knowledge.

## Current Draft Candidate

R3.1 records one private draft counterexample candidate:

```text
counterexample.hamiltonicity-min-degree.k23
```

The candidate is the complete bipartite graph `K_{2,3}` with part sizes 2 and
3. The draft reasoning is that the graph is connected, simple, finite, and has
minimum degree 2, while any cycle in a bipartite graph alternates parts and
therefore cannot be Hamiltonian on unequal part sizes.

This is not accepted knowledge. Checker evidence has been attached. Human
review has been recorded with decision `keep_draft`, so the artifact remains
a private draft.

## Current Checker Evidence

R3.2 added a local checker:

```bash
python checkers/check_k23_hamiltonicity.py --json
```

The committed output is:

```text
evidence/hamiltonicity-min-degree-k23-check.json
```

The checker enumerates all vertex permutations with a fixed start vertex and
checks whether consecutive vertices, including the wraparound edge, form a
Hamiltonian cycle. Its recorded status is `pass` for the finite `K_{2,3}`
candidate: connected simple graph, minimum degree 2, and zero Hamiltonian
cycles.

The checker does not prove any general theorem, does not perform human review,
does not establish informal/formal semantic alignment, and does not create
accepted status, verifier authority, gate authority, or promotion authority.

## Current Review Handoff

R4.1 prepared the review packet:

```text
reviews/requests/hamiltonicity-min-degree-k23-review.md
```

The packet is informational only. It includes the target artifact, original
issue, statement, dependencies, sources, checker status, failed attempt and
failure-memory links, known risks, and concrete reviewer questions.

At the time it was created, this handoff did not create accepted status,
formal proof, verifier authority, gate authority, public KB movement, or
promotion authority. It was later followed by the R5.1 human review decision
record below.

## Current Human Review Decision

R5.1 recorded the maintainer's review input:

```text
reviews/human/hamiltonicity-min-degree-k23-decision.md
```

The recorded decision is `keep_draft`. The artifact review state is
`human_reviewed`, but the artifact status remains `draft`. No accepted status,
source-metadata upgrade, public-KB write, verifier pass, gate-authority claim,
or promotion is recorded.

## Current Final Report

R6.1 added the final report:

```text
reports/closed-loop-research-report.md
```

The report summarizes the original question, context, attempt, failure memory,
candidate, checker evidence, review handoff, human review outcome, final
lifecycle state, Cosheaf value, and remaining limitations.

R7 public KB contribution is intentionally skipped because the recorded review
decision is `keep_draft`, not `candidate_for_public_kb`.

## Next Step

Longplan C is complete for this case study unless a future maintainer supplies
a new review decision that explicitly authorizes revision or public-KB
proposal work.
