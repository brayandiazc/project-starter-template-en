#!/usr/bin/env bash
# check-workflow-identity.sh — a workflow claiming to be another repository never runs.
#
# Template-repo-only workflows are gated with
# `if: github.repository == 'user/repo'` so they do not run in instantiated
# projects. When one is copied between repositories, that condition travels
# along as is: the job checks a repository that is not its own and **skips**.
#
# And that is the problem: it does not fail, it skips. In a PR's checks list a
# grey "skipping" reads almost like a green, so a check can go months without
# running once and nobody notices. A check that does not run is worse than one
# that fails, because the failing one tells you.
#
# It only has an opinion in the TEMPLATE REPO, which is where those conditions
# are written by hand; it recognises it by TEMPLATE-USAGE.md. In an
# instantiated project the condition names the template ON PURPOSE: that is
# what keeps the workflow from running there, and flagging it would be exactly
# backwards.
#
# Usage:
#   bash .github/scripts/check-workflow-identity.sh [repo-root]
#
# Fails OPEN: outside the template repo, or when this repository's name cannot
# be determined, it has no opinion. Exits 1 if a condition names another one.
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT" || exit 0

[ -f TEMPLATE-USAGE.md ] || {
  echo "ℹ️  No TEMPLATE-USAGE.md: this is not the template repo; nothing to check."
  exit 0
}

[ -d .github/workflows ] || {
  echo "ℹ️  There is no .github/workflows/; nothing to check."
  exit 0
}

# On Actions the name is given; locally it is derived from the remote.
SLUG="${GITHUB_REPOSITORY:-}"
if [ -z "$SLUG" ]; then
  url="$(git remote get-url origin 2>/dev/null || true)"
  # Both forms work: git@host:user/repo.git and https://host/user/repo
  SLUG="$(printf '%s' "$url" | perl -ne 's/\.git$//; print "$1/$2\n" if m{[:/]([^/:]+)/([^/]+)$}')"
fi

if [ -z "$SLUG" ]; then
  echo "ℹ️  Could not determine the repository (no remote, no GITHUB_REPOSITORY); skipping."
  exit 0
fi

failures=0
conditions=0

while IFS= read -r file; do
  # Every `github.repository ==` condition with a literal slug, with its line.
  while IFS=: read -r line named; do
    [ -n "$named" ] || continue
    conditions=$((conditions + 1))
    if [ "$named" != "$SLUG" ]; then
      if [ "$failures" -eq 0 ]; then
        echo "❌ Some workflows claim to be another repository:"
      fi
      echo "   · $file:$line → github.repository == '$named'"
      failures=$((failures + 1))
    fi
  done < <(perl -ne 'print "$.:$1\n" if /github\.repository\s*==\s*[\x27"]([^\x27"]+)[\x27"]/' "$file")
done < <(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' -o -name '*.yml.example' \) | sort)

if [ "$failures" -gt 0 ]; then
  echo
  echo "→ This repository is '$SLUG'. A condition naming another one does not fail:"
  echo "  the job SKIPS, and in the checks list a grey \"skipping\" reads almost like"
  echo "  a green. Change it to '$SLUG', or delete the workflow if it has no"
  echo "  business here."
  exit 1
fi

if [ "$conditions" -eq 0 ]; then
  echo "✅ Workflow identity: none of them is gated by repository."
else
  echo "✅ Workflow identity: $conditions condition(s), all claiming to be '$SLUG'."
fi
exit 0
