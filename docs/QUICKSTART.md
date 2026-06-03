# Quickstart

1. Install or make the `cosheaf` CLI available.
2. Inspect the configured workspace:

```bash
cosheaf workspace info
```

3. Validate the loaded public and private KB roots:

```bash
cosheaf validate
```

4. Run the gatekeeper:

```bash
cosheaf gate run
```

5. For a task-specific agent run, create or choose an issue and build a context pack:

```bash
cosheaf context build <issue-id>
```

Keep private research in `kb/private/`. Replace or mount `kb/public/` from the public KB repository for real work.
