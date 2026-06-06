.PHONY: install workspace validate gate pr-checklist context demo

PYTHON ?= python
COSHEAF ?= cosheaf
BASH ?= bash

install:
	$(PYTHON) -m pip install "git+https://github.com/CheemsaDoge/tcs-cosheaf.git@v0.1.1"

workspace:
	$(COSHEAF) workspace info

validate:
	$(COSHEAF) validate

gate:
	$(COSHEAF) gate run

pr-checklist:
	$(COSHEAF) gate run --pr-checklist .github/pull_request_template.md

context:
	$(COSHEAF) context build issue.example-private-claim

demo:
	$(BASH) scripts/demo_workspace.sh
