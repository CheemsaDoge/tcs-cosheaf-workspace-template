.PHONY: install workspace-info workspace validate gate index pr-checklist context demo cli-agent-demo provider-config-check provider-preview-public provider-fake-smoke verifier-evidence-demo

PYTHON ?= python
COSHEAF ?= cosheaf
ifeq ($(OS),Windows_NT)
BASH ?= C:/Progra~1/Git/bin/bash.exe
else
BASH ?= bash
endif

install:
	$(PYTHON) -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.2.2"

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

provider-config-check:
	$(BASH) scripts/provider_fake_smoke.sh config-check

provider-preview-public:
	$(BASH) scripts/provider_preview_public.sh

provider-fake-smoke:
	$(BASH) scripts/provider_fake_smoke.sh

verifier-evidence-demo:
	$(BASH) scripts/demo_verifier_evidence.sh
