# Campaign Demo

This demo exercises the V16 campaign handoff and campaign eval path from the
workspace template.

Run:

```bash
make campaign-demo
```

The script uses a sibling framework checkout when available:

```bash
COSHEAF_FRAMEWORK_ROOT=../tcs-cosheaf bash scripts/demo_campaign.sh
```

Until `v0.11.0` is published, keep a local V16-capable framework checkout or
set an explicit ref:

```bash
COSHEAF_FRAMEWORK_REF=<v0.11-capable-ref> bash scripts/demo_campaign.sh
```

The demo:

1. runs workspace info, validation, and gate checks;
2. starts a campaign for `issue.example-private-claim`;
3. previews and exports one bounded `operator_task_v2` packet;
4. appends one deterministic safe campaign attempt;
5. exports `campaign_handoff.json`;
6. runs `cosheaf eval campaign --json`; and
7. reruns validation and gate checks.

Runtime output stays under ignored `.cosheaf/` paths:

```text
.cosheaf/campaign-demo/
.cosheaf/campaigns/campaign.workspace.demo/
```

The demo does not call hosted providers, run shell-backed campaign loops, write
public KB content, create accepted artifacts, fabricate source metadata, create
verifier/gate authority, promote artifacts, or create human review. Campaign
handoffs and eval reports are review context only.
