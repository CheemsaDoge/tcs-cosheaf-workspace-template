# Strategy Planner Workflow

This demo shows the `v0.4.0` strategy-planner workflow from a user workspace.
The framework CLI remains the agent interface. The workspace does not embed a
hosted model runtime and does not require MCP.

The demo installs the published `v0.4.0` tag by default. For framework
development, run the demo against a local checkout:

```bash
COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/demo_strategy_planner.sh
```

The script uses `../tcs-cosheaf` automatically when that checkout exists. To
force the pinned release tag, point `COSHEAF_FRAMEWORK_ROOT` at a nonexistent
path or run from a workspace without a sibling framework checkout:

```bash
COSHEAF_FRAMEWORK_ROOT=.cosheaf/no-local-framework \
COSHEAF_FRAMEWORK_REF=v0.4.0 \
bash scripts/demo_strategy_planner.sh
```

If you already have a desired `cosheaf` command on `PATH`, skip installation:

```bash
COSHEAF_SKIP_INSTALL=1 COSHEAF_CMD="python -m cosheaf.cli" bash scripts/demo_strategy_planner.sh
```

## Make Target

```bash
make strategy-demo
```

On Windows with Git Bash outside `PATH`:

```bash
mingw32-make strategy-demo BASH="C:/Program Files/Git/bin/bash.exe"
```

## Flow

The demo:

1. Starts a research run for `issue.example-private-claim`.
2. Builds a context pack and stages the strategy-planner input under
   `.cosheaf/strategy-demo/context/`.
3. Creates a strategy plan from that staged context pack.
4. Shows ranked next steps.
5. Records validation and gate commands in the research run.
6. Finalizes the research run.
7. Updates the strategy plan from the run provenance.
8. Previews strategy review export with `--dry-run`.
9. Runs final `validate` and `gate`.

Runtime outputs are written under ignored `.cosheaf/strategy-demo/`,
`.cosheaf/runs/`, and `.cosheaf/strategy/` paths. The framework context builder
uses `context/TASKS/<issue>` internally; when the demo creates that directory,
it copies the context pack into `.cosheaf/strategy-demo/context/<issue>/` and
removes the generated `context/TASKS/<issue>` directory after staging. Existing
user-created context directories are left in place.

The default demo does not write `reviews/strategy/`. To explicitly write the
non-authoritative review export, set:

```bash
COSHEAF_STRATEGY_DEMO_EXPORT_REVIEW=1 bash scripts/demo_strategy_planner.sh
```

## Boundaries

The strategy plan is guidance only. It is not proof, checked evidence, verifier
pass, gate pass, human review, accepted status, accepted refutation, or
promotion authority.

The demo does not:

- call hosted providers;
- require API keys;
- require MCP;
- write accepted knowledge;
- promote artifacts;
- create human review;
- claim automatic theorem proving or Lean semantic alignment.
