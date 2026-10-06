.PHONY: help fmt validate lint scan check plan-dev

TF_DIRS := . bootstrap
DEV_VARS := $(firstword $(wildcard envs/dev/terraform.tfvars) envs/dev/terraform.tfvars.example)

help: ## List targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate: ## init (no backend) + validate the root and bootstrap stacks
	@for d in $(TF_DIRS); do \
		echo "==> validate $$d"; \
		terraform -chdir=$$d init -backend=false -input=false >/dev/null && \
		terraform -chdir=$$d validate || exit 1; \
	done

lint: ## tflint across all modules (also checks formatting)
	terraform fmt -check -recursive
	tflint --init
	tflint --recursive

scan: ## checkov security scan (inline skips are justified in the README)
	checkov -d . --framework terraform --compact --quiet

check: fmt validate lint scan ## Everything CI runs

plan-dev: ## Plan the dev environment (needs AWS credentials; never applies)
	terraform init -input=false
	terraform plan -input=false -var-file=$(DEV_VARS)
