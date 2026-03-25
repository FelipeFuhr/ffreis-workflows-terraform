# ffreis-workflows-terraform — contribution guide

This repository is a library of reusable GitHub Actions workflows for Terraform projects.
The `examples/hello/` directory is the canonical test subject used by `self-test.yml`.

---

## Rules for adding or modifying workflows

### 1. Every new workflow must be in `self-test.yml` — unless it requires live AWS

Every file added to `.github/workflows/` (except `self-test.yml` itself) **must** have a
corresponding job in `self-test.yml` that calls it against `examples/hello/`, **unless** it
requires live AWS infrastructure or causes destructive side effects that cannot be safely
invoked in CI.

A workflow that is not in `self-test.yml` and not listed in the exclusion table below is
unverified. It will not be merged.

**Currently excluded from `self-test.yml`** (require live AWS; validated only by downstream
consumer projects that supply real credentials and a configured state backend):

| Workflow | Reason |
|---|---|
| `tf-plan.yml` | Requires `AWS_ROLE_ARN` (OIDC) and a Terraform remote state backend |
| `tf-apply.yml` | Creates real AWS resources — must never auto-trigger on push/PR |
| `tf-destroy.yml` | Destroys real AWS resources — must never auto-trigger on push/PR |
| `tf-drift.yml` | Requires live state and real AWS credentials |
| `tf-cost.yml` | Requires `INFRACOST_API_KEY` and AWS credentials |

Any new workflow that does **not** require live AWS (static analysis, linting, scanning,
docs generation, formatting, etc.) has no exception and must be in `self-test.yml`.

**Handling required secrets** — if a workflow requires a secret (e.g. `SONAR_TOKEN`),
declare it as `required: true` in the workflow. In `self-test.yml`, gate the entire job so
it is explicitly skipped on fork PRs (where secrets are unavailable):

```yaml
sonar:
  if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.fork == false
  uses: ./.github/workflows/tf-sonar.yml
  with:
    working-directory: examples/hello
  secrets:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

This produces an explicit "Skipped" status on fork PRs rather than a silent success.

---

### 2. No silent failures

A step that fails silently is worse than one that fails loudly.

- If a required tool is missing → `exit 1` with a clear install message pointing to docs.
- If a required secret is absent and the workflow cannot meaningfully skip → fail the job.
- Never print a warning and continue when the operation did not run.

`make secrets-scan-staged` and `make setup` in the `Makefile` are the reference
implementation of the correct error pattern.

---

### 3. No shell injection — inputs go through `env:`

Never interpolate `${{ inputs.* }}`, `${{ github.* }}`, or any expression directly inside a
`run:` step. Always route through an `env:` variable. Semgrep runs in CI and will block PRs
that violate this rule (`run-shell-injection`).

```yaml
# BAD — Semgrep blocks this
run: terraform -chdir="${{ inputs.working-directory }}" plan

# GOOD
env:
  WORKING_DIR: ${{ inputs.working-directory }}
run: terraform -chdir="$WORKING_DIR" plan
```

---

### 4. Least-privilege secrets — never `secrets: inherit`

Pass only the secrets a workflow explicitly declares, both in `self-test.yml` and in any
downstream consumer:

```yaml
# BAD
uses: ./.github/workflows/tf-sonar.yml
secrets: inherit

# GOOD
uses: ./.github/workflows/tf-sonar.yml
secrets:
  SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

---

### 5. `secrets.*` is forbidden in `if:` conditions

GitHub Actions forbids `secrets.*` in `if:` expressions within `workflow_call` reusable
workflows. Use job-level `if:` gating in `self-test.yml` instead (see the pattern in rule 1).

---

### 6. Pin third-party actions to a full commit SHA

```yaml
# BAD
uses: actions/checkout@v4

# GOOD
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4
```

When Semgrep flags a SHA as a false-positive secret, suppress it inline:

```yaml
uses: SonarSource/sonarqube-scan-action@<sha> # nosemgrep: generic.secrets.security.detected-sonarqube-docs-api-key.detected-sonarqube-docs-api-key
```

---

## Makefile targets

| Target | Purpose |
|---|---|
| `make setup` | Bootstrap lefthook + verify all required dev tools are installed |
| `make lint` | Validate workflow YAML with actionlint + tflint on `examples/hello` |
| `make check` | Validate workflow YAML syntax with yq |
| `make fmt-check` | Check Terraform formatting |
| `make secrets-scan-staged` | Scan staged files with gitleaks (fails if gitleaks not installed) |
| `make hooks` | Install git hooks via lefthook |
