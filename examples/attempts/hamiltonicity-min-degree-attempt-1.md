# Hamiltonicity Minimum-Degree Attempt 1

Issue: `issue.hamiltonicity-min-degree-counterexample`

GitHub issue: CheemsaDoge/tcs-cosheaf-workspace-template#106

Attempt id: `attempt.hamiltonicity-min-degree.longest-path-closure`

Date: 2026-06-19

## Attempt Goal

Try to prove the universal statement:

```text
Every finite connected simple graph with minimum degree at least 2 has a
Hamiltonian cycle.
```

This attempt deliberately tries the direct graph-theory route before adding
any candidate counterexample artifact.

## Context Used

- Local issue:
  `issues/open/issue.hamiltonicity-min-degree-counterexample.yaml`
- Context summary:
  `examples/context/hamiltonicity-min-degree-context.md`
- Runtime context command:
  `cosheaf context build issue.hamiltonicity-min-degree-counterexample`

The context pack was cards-only. It included draft cards for
`definition.graph` and `claim.example-private`, but no accepted artifacts, no
full artifact pulls, no failure memory, and no checked counterexample evidence.

## Reasoning Outline

Let `G` be a finite connected simple graph with minimum degree at least 2.
Take a longest path:

```text
v1, v2, ..., vk
```

Because the path is longest, every neighbor of each endpoint `v1` and `vk`
must already lie on the path. Since `deg(v1) >= 2`, the endpoint `v1` has a
neighbor `vi` with `i >= 3`. This gives a cycle:

```text
v1, v2, ..., vi, v1
```

The same style of argument shows that the minimum-degree condition forces at
least one cycle somewhere in the graph.

The attempted next step was to show that such a cycle can always be extended
until it contains every vertex. That step does not follow from the available
assumptions. A vertex outside a current cycle may connect to the cycle in a
way that does not provide two adjacent insertion points, and the condition
`minimum degree >= 2` is global rather than a guarantee of extendability for a
chosen cycle.

## Result Status

Failed/incomplete.

The argument establishes only that a cycle exists. It does not prove that a
spanning cycle exists.

## Evidence Or Lack Of Evidence

- No checker was run for this attempt.
- No exhaustive graph search was run for this attempt.
- No candidate theorem, counterexample, proof, or accepted artifact is added
  here.
- The attempt is reasoning context only and is not proof, verifier success,
  gate success, or human review.

## Next-Step Recommendation

Record this failed extension step as failure memory, then search for a small
connected simple graph with minimum degree at least 2 where every cycle misses
at least one vertex. A later candidate step should attach a reproducible
checker if a finite candidate graph is recorded.
