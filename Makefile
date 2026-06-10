.PHONY: install workspace-info workspace validate gate index pr-checklist context demo cli-agent-demo

PYTHON ?= python
COSHEAF ?= cosheaf
BASH ?= bash

install:
	$(PYTHON) -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.2.0"

workspace-info:
	$(COSHEAF) workspace info

workspace: workspace-info

validate:
	$(COSHEAF) validate

gate:
	$(COSHEAF) gate run

index:
	$(COSHEAF) index rebuild

pr-checklist:
	$(COSHEAF) gate run --pr-checklist .github/pull_request_template.md

context:
	$(COSHEAF) context build issue.example-private-claim

demo:
	$(BASH) scripts/demo_workspace.sh

cli-agent-demo:
	$(BASH) scripts/demo_cli_agent.sh
