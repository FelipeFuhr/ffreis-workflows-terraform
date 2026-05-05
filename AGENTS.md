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

## lefthook / platform-standards

- `lefthook.yml` uses a `remotes:` block pointing to
  `https://github.com/FelipeFuhr/ffreis-platform-standards`.
- The `ref:` must be a **full commit SHA** — never `ref: main`. Renovate manages
  this pin. When updating manually, fetch the latest SHA with:
  `gh api repos/FelipeFuhr/ffreis-platform-standards/commits/main --jq '.sha'`
- Local overrides in `lefthook.yml` (fmt-check glob, secret-scan, actionlint,
  commit-msg) augment the remote base; they are not duplicated by the remote.

## Action SHA management

- All third-party action SHAs are managed by Renovate (not Dependabot).
- `tf-fmt`, `tf-lint`, `tf-validate`, `tf-cost` include a
  `step-security/harden-runner` step (egress-policy: audit) from StepSecurity.
- `ci.yml` caller jobs need `issues: write` + `pull-requests: write` + `actions: read`
  + `security-events: write` in addition to `contents: read` when calling reusable
  workflows that post PR comments or upload SARIF.
- `self-test.yml` dry-run jobs (drift, apply, destroy, cost) need `id-token: write`
  even in dry-run mode so the workflow wiring is validated.

## Keeping this file current

- **If you discover a fact not reflected here:** add it before finishing your task.
- **If something here is wrong or outdated:** correct it in the same commit as the code change.
- **If you rename a file, command, or concept referenced here:** update the reference.
