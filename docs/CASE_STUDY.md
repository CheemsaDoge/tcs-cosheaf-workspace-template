# Closed-Loop Research Case Study

Status: failure memory recorded

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
draft `proof_attempt` artifact. No candidate theorem, claim, counterexample,
proof, accepted artifact, human review, verifier pass, or promotion is
recorded by this document.

## Planned Workflow

1. Create one local file-based research issue for the question. Done in R1.1.
2. Build a context pack for that issue and record what context was used. Done
   in R1.2.
3. Record a first attempt, including failure or incompleteness if present.
   Done in R2.1.
4. Convert the failure or incomplete direction into durable failure memory.
   Done in R2.2.
5. Add exactly one private draft candidate result.
6. Attach reproducible checker evidence or explain why no checker applies.
7. Export a review handoff packet for a human reviewer.
8. Record a real review decision only if a maintainer supplies one.
9. Write a final report for website/showcase use.

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

## Next Step

R3.1 should add exactly one private draft candidate result, keeping it
non-accepted and linked to the recorded failure memory where relevant.
