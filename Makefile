.DEFAULT_GOAL := help

##@ General

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Validation

.PHONY: lint
lint: ## Lint workflow YAML with actionlint + tflint on examples
	@command -v actionlint > /dev/null 2>&1 || { \
		echo "actionlint not found. Install it from https://github.com/rhysd/actionlint"; \
		exit 1; \
	}
	actionlint .github/workflows/*.yml
	@if command -v tflint >/dev/null 2>&1; then \
		cd examples/hello/stack && tflint --init && tflint; \
	else \
		echo "tflint not found; skipping example lint"; \
	fi

.PHONY: check
check: ## Validate workflow YAML syntax with yq (requires yq on PATH)
	@command -v yq > /dev/null 2>&1 || { \
		echo "yq not found. Install it from https://github.com/mikefarah/yq"; \
		exit 1; \
	}
	@for f in .github/workflows/*.yml; do \
		echo "Checking $$f ..."; \
		yq eval '.' "$$f" > /dev/null || exit 1; \
	done
	@echo "All workflow files are valid YAML."

.PHONY: fmt-check
fmt-check: ## Check Terraform example formatting
	terraform -chdir=examples/hello/stack fmt -check -recursive

##@ Hooks

.PHONY: secrets-scan-staged
secrets-scan-staged: ## Scan staged files for secrets
	gitleaks protect --staged --redact

.PHONY: lefthook-bootstrap
lefthook-bootstrap: ## Download lefthook binary to .bin/
	LEFTHOOK_VERSION="1.7.10" BIN_DIR=".bin" bash ./scripts/bootstrap_lefthook.sh

.PHONY: lefthook-install
lefthook-install: ## Install git hooks via lefthook
	lefthook install

.PHONY: hooks
hooks: lefthook-bootstrap lefthook-install ## Bootstrap and install all git hooks
