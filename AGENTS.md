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

Consumed by all managed Terraform stacks (both public and private — do not
enumerate private stack names in PR descriptions). They pin to a full commit SHA.

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
- **`tf-tfsec.yml` is non-blocking as of 2026-08-06.** `aquasecurity/tfsec-action`'s
  own install step (`entrypoint.sh` → `install_release`) has hit a 403 when
  fetching the release from this workspace's self-hosted runner IP. The
  "Aqua-side org IP allow list" diagnosis recorded here is **unverified** — it was
  never reproduced deliberately, and the same theory turned out to be wrong for
  Trivy (see § "Trivy install token"); GitHub's own anonymous-API rate limit on a
  shared egress IP fits the symptom at least as well. On a GitHub-hosted runner
  the anonymous fetch succeeds (self-test, 2026-08-17). Re-diagnose before acting
  on this. The install failure
  exits the script *before* `soft_fail` is ever read, so the `soft-fail`
  input's default (now `true`) is paired with `continue-on-error: true` on the
  "Run tfsec" step — the default alone cannot keep the job green. Revert both
  once Aqua grants an IP allow-list exemption, or drop the job entirely if
  tfsec is ever replaced by Trivy's overlapping config-scan coverage in
  `tf-security.yml` (the enforced, blocking gate for Terraform misconfigs in
  the meantime).

## Trivy install token (`tf-security.yml`) — settled 2026-08-17

**Never set `token-setup-trivy` on `aquasecurity/trivy-action`.** Leave it unset
so the action's own `default: ${{ github.token }}` applies.

- The action forwards it **unconditionally** to `aquasecurity/setup-trivy` as
  `token:`, which hands it to `actions/checkout` to fetch the *public*
  `aquasecurity/trivy` install script.
- An explicit `""` is **not** an anonymous fetch. `actions/checkout` treats an
  explicitly-empty token as supplied-but-invalid and fails the step with
  `##[error]Input required and not supplied: token`. Only *omitting* the input
  yields the default.
- **The authenticated fetch works.** Verified on both runner classes:
  - GitHub-hosted — this repo's Self Test, 2026-08-01, cache MISS on
    `trivy-binary-v0.70.0-Linux-X64`, `Checkout install script` → `outcome=success`.
  - Self-hosted homelab — a private consumer, 2026-08-17T00:41Z on a
    `["self-hosted","local"]` runner, cache MISS, `Syncing repository:
    aquasecurity/trivy` → `outcome=success`, binary installed and cached.
  Anonymous **and** token-authenticated reads of `aquasecurity/trivy` also both
  return 200 from the homelab egress IP. There is no Aqua IP-allow-list block on
  this path — an earlier comment here and in `tf-security.yml` claimed otherwise
  and was wrong.

**Why it hid for 11 days.** `setup-trivy` only reaches its `actions/checkout` on
a binary-cache **MISS** (`trivy-binary-<version>-<os>-<arch>`). The bad `""` landed
2026-08-06 while the `v0.70.0` cache kept hitting, so the step was skipped every
run. Pinning `v0.71.0` changed the cache key → first real miss → instant failure.

Two guards now exist; keep both:
1. `scripts/checks/check_action_token_inputs.sh` (via `make lint`, and the
   `workflow-invariants` job in `ci.yml` + `self-test.yml`) fails on any workflow
   passing an empty `*token*` input to an action.
2. `ci.yml` and `self-test.yml` call `tf-security.yml` with `cache: false`, so the
   install path is exercised on **every** run instead of being masked by a cache hit.
   Consumers keep the `cache: true` default.

> The separate `tf-tfsec.yml` 403 note below is a **different action** with a
> different install mechanism (its own `entrypoint.sh`, not `setup-trivy`). The
> evidence above says nothing about it; do not generalize between the two.

## Public repo — private-repo hygiene

This is a **public** GitHub repository. When writing commit messages, PR titles,
PR descriptions, or any other user-visible text, **never name private repos** —
website content, inventory, infra, Lambda, or data repos that are not publicly
listed. Use generic terms instead: "the fleet inventory", "a private consumer",
"internal infra", "private data repo", etc.

## Keeping this file current

- **If you discover a fact not reflected here:** add it before finishing your task.
- **If something here is wrong or outdated:** correct it in the same commit as the code change.
- **If you rename a file, command, or concept referenced here:** update the reference.
