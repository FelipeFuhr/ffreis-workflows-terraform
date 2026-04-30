# ffreis-platform-workflows-terraform

Reusable GitHub Actions workflows for Terraform repositories.


All workflows use `on: workflow_call:` and should be consumed from other repos by pinning to a specific commit SHA for reproducibility and security. Example:

```yaml
uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/<file>.yml@<sha> # latest
```

Replace `<sha>` with the latest commit SHA from the target workflow repository. Avoid using @main or @vX tags for production workflows.

---

## Workflows

| Workflow | File | Purpose | Key Inputs |
|---|---|---|---|
| Terraform Format Check | `tf-fmt.yml` | `terraform fmt -check -recursive` | `terraform-version`, `working-directory` |
| Terraform Validate | `tf-validate.yml` | `terraform init -backend=false` + `terraform validate` | `terraform-version`, `chdir`, `validate-all-modules`, `modules-dir` |
| Terraform Lint | `tf-lint.yml` | tflint with recursive scan | `tflint-version`, `lint-path`, `tflint-config` |
| Terraform Security Scan | `tf-security.yml` | Trivy config scan | `scan-ref`, `severity`, `exit-code` |
| Terraform Plan | `tf-plan.yml` | Plan with AWS OIDC + PR comment | `environment` (required), `terraform-version`, `chdir`, `aws-region`, `plan-args` |
| Terraform Apply | `tf-apply.yml` | Apply with AWS OIDC | `environment` (required), `terraform-version`, `chdir`, `aws-region`, `auto-approve` |
| Terraform Destroy | `tf-destroy.yml` | Destroy with AWS OIDC (caller must gate via `workflow_dispatch`) | `environment` (required), `chdir`, `target` |
| Terratest Tidy | `tf-test-tidy.yml` | Verify go.mod/go.sum are tidy + compile test package | `go-version`, `test-dir` |
| Terraform Docs | `tf-docs.yml` | terraform-docs drift check | `terraform-docs-version`, `working-directory`, `output-file`, `output-mode` |
| Cost Estimation | `tf-cost.yml` | Infracost breakdown + PR comment | `path`, `aws-region` (secrets: `INFRACOST_API_KEY`) |
| Drift Detection | `tf-drift.yml` | `terraform plan -detailed-exitcode` — fails on drift | `environment` (required), `chdir`, `aws-region` |
| Compliance Scan | `tf-checkov.yml` | Checkov scan (complements Trivy) | `scan-directory`, `framework`, `soft-fail`, `skip-check` |

---

## Usage Examples

### tf-fmt.yml





### tf-fmt.yml

```yaml
jobs:
  fmt:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-fmt.yml@<sha> # latest
    with:
      working-directory: infra/
```

### tf-validate.yml — single stack

```yaml
jobs:
  validate:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-validate.yml@<sha> # latest
    with:
      chdir: infra/stack
```

### tf-validate.yml — all modules

```yaml
jobs:
  validate:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-validate.yml@<sha> # latest
    with:
      validate-all-modules: true
      modules-dir: modules
```

### tf-lint.yml

```yaml
jobs:
  lint:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-lint.yml@<sha> # latest
    with:
      lint-path: infra/
      tflint-config: .tflint.hcl
```

### tf-security.yml

```yaml
jobs:
  security:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-security.yml@<sha> # latest
    with:
      scan-ref: infra/
      severity: HIGH,CRITICAL
```

### tf-plan.yml

```yaml
jobs:
  plan:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-plan.yml@<sha> # latest
    with:
      environment: dev
      chdir: infra/stack
    secrets:
      AWS_ROLE_ARN: ${{ secrets.TERRAFORM_PLAN_ROLE_ARN }}
```

### tf-apply.yml

```yaml
jobs:
  apply:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-apply.yml@<sha> # latest
    with:
      environment: prod
      chdir: infra/stack
    secrets:
      AWS_ROLE_ARN: ${{ secrets.TERRAFORM_APPLY_ROLE_ARN }}
```

### tf-destroy.yml

```yaml
# Caller gates execution via workflow_dispatch
on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, staging, prod]
        required: true

- `aws-actions/configure-aws-credentials@a7b4b2e8e2e2e8e2e2e8e2e8e2e8e2e8e2e8e2e8 # v4`
  destroy:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-destroy.yml@<sha> # latest
    with:
      environment: ${{ inputs.environment }}
    secrets:
      AWS_ROLE_ARN: ${{ secrets.TERRAFORM_APPLY_ROLE_ARN }}
```

### tf-test-tidy.yml

```yaml
jobs:
  test-tidy:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-test-tidy.yml@<sha> # latest
    with:
      test-dir: test
```

### tf-docs.yml

```yaml
jobs:
  docs:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-docs.yml@<sha> # latest
    with:
      working-directory: modules
```

### tf-cost.yml

```yaml
jobs:
  cost:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-cost.yml@<sha> # latest
    with:
      path: infra/stack
    secrets:
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
      AWS_ROLE_ARN: ${{ secrets.TERRAFORM_PLAN_ROLE_ARN }}
```

### tf-drift.yml

# Typically called from a scheduled workflow in the consumer repo
on:
  schedule:
    - cron: "0 6 * * 1-5"

- `permissions: contents: read` at workflow level; `id-token: write` and `pull-requests: write` only where needed
  drift:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-drift.yml@<sha> # latest
    with:
      environment: prod
      chdir: infra/stack
    secrets:
      AWS_ROLE_ARN: ${{ secrets.TERRAFORM_PLAN_ROLE_ARN }}
```

### tf-checkov.yml

```yaml
jobs:
  checkov:
    uses: ffreis/ffreis-platform-workflows-terraform/.github/workflows/tf-checkov.yml@<sha> # latest
    with:
      scan-directory: infra/
      skip-check: CKV_AWS_144,CKV_AWS_145
```
- `set -euo pipefail` in all multi-line `run` steps
- No `concurrency` blocks in reusable workflows (callers control concurrency)
- AWS credentials via OIDC only — no static keys

## Local checks

```sh
make lint   # actionlint all workflow files
make check  # yq YAML syntax check
```
