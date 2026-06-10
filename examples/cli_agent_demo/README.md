# CLI Agent Demo Fixtures

These fixtures support `scripts/demo_cli_agent.sh`.

They are examples only. The script uses them with `--dry-run` so it does not
write accepted knowledge, does not promote artifacts, does not mark human
review complete, and does not require hosted API or MCP access.

Files:

- `draft_artifact_request.json`: draft-only proposal input for
  `cosheaf draft write-artifact`.
- `worker_bundle.json`: worker bundle v2 manifest for review submission.
- `bundle_submit_request.json`: bundle submission request pointing at the
  worker bundle fixture.
