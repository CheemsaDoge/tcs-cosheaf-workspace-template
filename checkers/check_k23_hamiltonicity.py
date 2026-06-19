import argparse
import itertools
import json
import platform
import sys
from collections import deque


TARGET_ARTIFACT = "counterexample.hamiltonicity-min-degree.k23"


def build_k23() -> tuple[list[str], list[tuple[str, str]]]:
    vertices = ["a1", "a2", "b1", "b2", "b3"]
    edges = [
        ("a1", "b1"),
        ("a1", "b2"),
        ("a1", "b3"),
        ("a2", "b1"),
        ("a2", "b2"),
        ("a2", "b3"),
    ]
    return vertices, edges


def _edge_set(edges: list[tuple[str, str]]) -> set[frozenset[str]]:
    return {frozenset(edge) for edge in edges}


def _is_simple(vertices: list[str], edges: list[tuple[str, str]]) -> bool:
    if len(vertices) != len(set(vertices)):
        return False
    seen: set[frozenset[str]] = set()
    vertex_set = set(vertices)
    for u, v in edges:
        if u == v or u not in vertex_set or v not in vertex_set:
            return False
        edge = frozenset((u, v))
        if edge in seen:
            return False
        seen.add(edge)
    return True


def _degrees(vertices: list[str], edges: list[tuple[str, str]]) -> dict[str, int]:
    degrees = {vertex: 0 for vertex in vertices}
    for u, v in edges:
        degrees[u] += 1
        degrees[v] += 1
    return degrees


def _is_connected(vertices: list[str], edges: list[tuple[str, str]]) -> bool:
    if not vertices:
        return True
    adjacency = {vertex: set() for vertex in vertices}
    for u, v in edges:
        adjacency[u].add(v)
        adjacency[v].add(u)
    seen = {vertices[0]}
    queue: deque[str] = deque([vertices[0]])
    while queue:
        current = queue.popleft()
        for neighbor in adjacency[current]:
            if neighbor not in seen:
                seen.add(neighbor)
                queue.append(neighbor)
    return len(seen) == len(vertices)


def _hamiltonian_cycles(
    vertices: list[str], edges: list[tuple[str, str]]
) -> list[list[str]]:
    if len(vertices) < 3:
        return []
    edge_set = _edge_set(edges)
    start = vertices[0]
    cycles: list[list[str]] = []
    for order in itertools.permutations(vertices[1:]):
        cycle = [start, *order]
        if all(
            frozenset((cycle[index], cycle[(index + 1) % len(cycle)])) in edge_set
            for index in range(len(cycle))
        ):
            reverse = [start, *reversed(order)]
            if reverse not in cycles:
                cycles.append(cycle)
    return cycles


def run_check() -> dict[str, object]:
    vertices, edges = build_k23()
    degrees = _degrees(vertices, edges)
    cycles = _hamiltonian_cycles(vertices, edges)
    connected = _is_connected(vertices, edges)
    simple = _is_simple(vertices, edges)
    min_degree = min(degrees.values())
    has_hamiltonian_cycle = bool(cycles)
    passed = simple and connected and min_degree >= 2 and not has_hamiltonian_cycle

    return {
        "schema_version": 1,
        "checker_id": "checker.hamiltonicity-min-degree.k23",
        "target_artifact": TARGET_ARTIFACT,
        "status": "pass" if passed else "fail",
        "checked_claim": (
            "K2,3 is a finite connected simple graph with minimum degree at "
            "least 2 and no Hamiltonian cycle."
        ),
        "graph": {
            "vertices": vertices,
            "edges": [list(edge) for edge in edges],
            "simple": simple,
            "connected": connected,
            "degrees": degrees,
            "min_degree": min_degree,
        },
        "hamiltonian_cycle_count": len(cycles),
        "has_hamiltonian_cycle": has_hamiltonian_cycle,
        "hamiltonian_cycles": cycles,
        "algorithm": (
            "Enumerates all vertex permutations with a fixed start vertex and "
            "checks whether consecutive vertices, including the wraparound "
            "edge, form a Hamiltonian cycle."
        ),
        "reproducibility": {
            "command": "python checkers/check_k23_hamiltonicity.py --json",
            "python_version": sys.version.split()[0],
            "platform": platform.platform(),
        },
        "limitations": (
            "This is finite graph enumeration evidence for the stated K2,3 "
            "candidate only. It is not human review, accepted knowledge, "
            "formal proof, semantic alignment, gate authority, or promotion "
            "authority."
        ),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "artifact_path",
        nargs="?",
        help="Optional artifact path passed by the Cosheaf python_checker gate.",
    )
    parser.add_argument("--json", action="store_true", help="Emit JSON output.")
    args = parser.parse_args()
    result = run_check()
    if args.artifact_path:
        result["artifact_path"] = args.artifact_path
    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(f"{result['status']}: {result['checked_claim']}")
    raise SystemExit(0 if result["status"] == "pass" else 1)


if __name__ == "__main__":
    main()
