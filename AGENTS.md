# Agent Context

**This repo:** `ffreis-workflows-terraform` — reusable GitHub Actions workflow library
for Terraform. Covers fmt, validate, tflint, Trivy, Checkov, plan/apply/destroy
(AWS OIDC), terraform-docs drift, Infracost, and drift detection.

## Non-obvious rules (read before changing anything)

1. **Live-infra workflows are exempt from `self-test.yml`** — cannot be meaningfully
   tested without real AWS credentials and state backend:
   `tf-plan`, `tf-apply`, `tf-destroy`, `tf-drift`, `tf-cost`
   These are validated only by downstream consumer projects.

2. **Static-analysis workflows MUST be in `self-test.yml`:**
   `tf-fmt`, `tf-validate`, `tf-lint`, `tf-security`, `tf-test-tidy`, `tf-docs`, `tf-checkov`.

3. **AWS OIDC only — never static keys.** All plan/apply/destroy workflows expect
   `AWS_ROLE_ARN` secret. Do not add static credential inputs.

4. **`tf-destroy` must only be triggered via `workflow_dispatch`** with an explicit
   environment input. Callers gate it; this workflow does not gate itself.

5. **`concurrency:` is intentionally absent from all reusable workflows.** Callers
   control their own concurrency model. Do not add it.

6. **`terraform-docs` drift check** — docs are regenerated and diffed. Callers must
   keep generated docs committed.

## Structure

```
.github/workflows/
  tf-*.yml        ← reusable library
  devops-*.yml    ← repo-maintenance
  ci.yml, release.yml
examples/hello/   ← minimal Terraform config
```

## Build/test

```bash
make setup              # lefthook + gitleaks
make lint               # actionlint + tflint on examples/hello
make fmt-check          # terraform fmt -check
make secrets-scan-staged
```

## Cross-repo role

Consumed by all Terraform stacks (platform-org, shared-infra, flemming-infra,
platform-github-oidc, platform-atlantis). They pin to a full commit SHA.

## Keeping this file current

- **If you discover a fact not reflected here:** add it before finishing your task.
- **If something here is wrong or outdated:** correct it in the same commit as the code change.
- **If you rename a file, command, or concept referenced here:** update the reference.
