#!/usr/bin/env bash
# check-labels.sh — do the labels in LABELS.md actually exist in the repository?
#
# `.github/LABELS.md` is the single source and `setup-labels.sh` creates them from
# its tables. But creating the labels is a MANUAL step, done once per repository,
# and nothing checked that it had been done.
#
# Why it matters more than it looks: some mechanisms depend on the label
# existing, not on it being written down. `dependabot.yml` declares
# `sin-changelog` on its PRs so the changelog job lets them through — if the
# label was never created, Dependabot cannot apply it, the gate takes them down
# anyway, and the fix looks done because the file says the right thing. The
# manual escape hatch does not work either: you cannot put a label that is not
# there on a PR.
#
# Usage:
#   bash .github/scripts/check-labels.sh [repo-root]
#
# Fails OPEN: without `gh`, without authentication, without a remote or without
# LABELS.md, it has no opinion. Exits 1 only when it can list the labels and one
# is missing.
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT" || exit 0

LABELS_MD=".github/LABELS.md"

[ -f "$LABELS_MD" ] || {
  echo "ℹ️  There is no $LABELS_MD; nothing to check."
  exit 0
}

command -v gh >/dev/null 2>&1 || {
  echo "ℹ️  'gh' is not installed; skipping the label check."
  exit 0
}

# The repository: on Actions it is given; locally it is derived from the remote.
SLUG="${GITHUB_REPOSITORY:-}"
if [ -z "$SLUG" ]; then
  url="$(git remote get-url origin 2>/dev/null || true)"
  SLUG="$(printf '%s' "$url" | perl -ne 's/\.git$//; print "$1/$2\n" if m{[:/]([^/:]+)/([^/]+)$}')"
fi

[ -n "$SLUG" ] || {
  echo "ℹ️  Could not determine the repository; skipping."
  exit 0
}

if ! existing="$(gh label list -R "$SLUG" --limit 200 --json name -q '.[].name' 2>/dev/null)"; then
  echo "ℹ️  Could not list the labels (no authentication or no network); skipping."
  exit 0
fi

# The tables in LABELS.md: | `name` | `#RRGGBB` | description |
declared="$(perl -ne 'print "$1\n" if /^\|\s*`([^`]+)`\s*\|\s*`#[0-9A-Fa-f]{6}`\s*\|/' "$LABELS_MD")"

[ -n "$declared" ] || {
  echo "ℹ️  $LABELS_MD declares no parseable label; nothing to check."
  exit 0
}

missing=""
total=0
while IFS= read -r l; do
  [ -n "$l" ] || continue
  total=$((total + 1))
  printf '%s\n' "$existing" | grep -qxF "$l" || missing="$missing $l"
done <<EOF
$declared
EOF

if [ -n "$missing" ]; then
  echo "❌ These labels are in $LABELS_MD but do not exist in $SLUG:"
  for l in $missing; do echo "   · $l"; done
  echo "→ Declaring them does not create them. And some mechanisms depend on them"
  echo "  existing: 'dependabot.yml' puts 'sin-changelog' on its PRs to pass the"
  echo "  changelog gate — without the label created, the gate takes them down"
  echo "  anyway and the fix looks done because the file says the right thing."
  echo
  echo "   bash .github/scripts/setup-labels.sh"
  exit 1
fi

echo "✅ Labels: all $total from $LABELS_MD exist in $SLUG."
exit 0
