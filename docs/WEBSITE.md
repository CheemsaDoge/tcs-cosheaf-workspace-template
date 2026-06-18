# Website Demo Export

This workspace template includes a committed static website demo fixture under:

```text
examples/site-data/
```

The fixture is generated from the canonical workspace-template demo issue and
demo artifacts:

```bash
make site-demo-export
```

The target runs:

```bash
cosheaf site export --demo --out examples/site-data
```

`scripts/export_site_demo.sh` prefers a local sibling framework checkout at
`../tcs-cosheaf` when present. This is intentional: the published `v1.0.0`
framework pin remains the clean-clone baseline, while the website export
surface is introduced after that tag. To use an explicit framework command:

```bash
COSHEAF_CMD="python -m cosheaf.cli" \
PYTHONPATH=../tcs-cosheaf \
bash scripts/export_site_demo.sh
```

The fixture is demo-only display data. It is not source of truth, accepted
knowledge, human review, verifier pass, gate pass, or promotion authority. It
does not include full private artifact statements, API keys, tokens, provider
prompts, or hidden reviewer identity.

The demo export may include private records only when they are explicitly
marked as demo fixtures by the framework exporter policy. In this template,
`claim.example-private` and `issue.example-private-claim` are public-repo demo
fixtures for the website walkthrough. Real user private research data must not
be committed under `examples/site-data/`.
