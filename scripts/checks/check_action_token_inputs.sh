#!/usr/bin/env bash
#
# Guard: no workflow may pass an EMPTY value to an action input named "*token*".
#
# Why this exists
# ---------------
# An explicitly-empty token is not "fetch anonymously" — it is a
# supplied-but-invalid value. actions/checkout rejects it outright:
#
#     ##[error]Input required and not supplied: token
#
# Omitting the input entirely is what lets the action apply its own
# `default: ${{ github.token }}`.
#
# tf-security.yml carried `token-setup-trivy: ""` from 2026-08-06 to
# 2026-08-17 and the break stayed invisible for 11 days, because
# aquasecurity/setup-trivy only reaches its `actions/checkout` step on a
# binary-cache MISS. The cache kept hitting until a Trivy version bump
# changed the cache key, and only then did the job fail.
#
# Scope
# -----
# Only keys inside a step's `with:` block are examined, so `secrets:` /
# `inputs:` declarations (e.g. a bare `SONAR_TOKEN:` with a nested block) and
# `permissions:` entries (`id-token: write`) are never flagged. Block scalars
# (`key: |`) inside a `with:` block are skipped so their body text cannot be
# mistaken for a mapping.
#
# Usage: check_action_token_inputs.sh [workflow-dir]   (default .github/workflows)

set -euo pipefail
IFS=$'\n\t'

workflow_dir="${1:-.github/workflows}"

if [[ ! -d "$workflow_dir" ]]; then
  echo "ERROR: workflow directory not found: ${workflow_dir}" >&2
  exit 1
fi

shopt -s nullglob
files=("${workflow_dir}"/*.yml "${workflow_dir}"/*.yaml)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
  echo "ERROR: no workflow files found under ${workflow_dir}" >&2
  exit 1
fi

findings="$(
  awk '
    BEGIN { sq = sprintf("%c", 39); dq = sprintf("%c", 34) }

    function indent_of(line) { match(line, /^ */); return RLENGTH }

    {
      ind = indent_of($0)

      # Still inside an open block scalar?
      if (in_block && ind > block_indent && $0 ~ /[^ ]/) next
      if (in_block) in_block = 0

      # Left the with: block?
      if (in_with && ind <= with_indent && $0 ~ /[^ ]/) in_with = 0

      if ($0 ~ /^ *#/) next
      if ($0 !~ /[^ ]/) next

      if ($0 ~ /^ *with: *$/) { in_with = 1; with_indent = ind; next }
      if (!in_with) next

      line = $0
      sub(/[ \t]+#.*$/, "", line)

      # Entering a block scalar (key: | or key: >)?
      if (line ~ /: *[|>][-+0-9]* *$/) { in_block = 1; block_indent = ind; next }

      if (line !~ /^ *[A-Za-z0-9_.-]*[Tt][Oo][Kk][Ee][Nn][A-Za-z0-9_.-]* *:/) next

      key = line; sub(/^ */, "", key); sub(/ *:.*$/, "", key)
      val = line; sub(/^[^:]*: */, "", val); sub(/[ \t\r]+$/, "", val)

      if (val == "" || val == dq dq || val == sq sq) {
        printf "%s:%d: input %s is set to an empty value\n", FILENAME, FNR, key
      }
    }
  ' "${files[@]}"
)"

if [[ -n "$findings" ]]; then
  echo "Empty token input(s) found in workflow files:" >&2
  # scan-fix(shellcheck:SC2001): indent via read loop, not sed — no subshell pipe
  while IFS= read -r finding; do
    printf '  %s\n' "$finding" >&2
  done <<<"$findings"
  cat >&2 <<'EOF'

An empty token is NOT an anonymous fetch — actions/checkout treats it as
"supplied but invalid" and fails with:

    ##[error]Input required and not supplied: token

Remove the line entirely so the action's own `default: ${{ github.token }}`
applies. If anonymous access is genuinely required, use the action's dedicated
knob for it (e.g. `skip-setup-trivy: true` plus an explicit install step) —
never an empty token.
EOF
  exit 1
fi

echo "OK: no empty token inputs in ${#files[@]} workflow file(s) under ${workflow_dir}"
