#!/usr/bin/env bash
# check-changelog.sh — makes the "nothing undocumented" rule verifiable: every PR
# that changes something in the project must bring its entry in CHANGELOG.md under
# `## [Unreleased]` (docs/conventions/workflow.md, rule 5).
#
# What counts as enough:
#   - the PR modifies CHANGELOG.md, AND
#   - the `## [Unreleased]` section has at least one bullet,
#   - or the PR is a version cut (it adds `## [X.Y.Z] - YYYY-MM-DD`), which leaves
#     Unreleased empty on purpose.
#
# Exemptions:
#   - PRs that only touch CHANGELOG.md itself.
#   - PRs with the `no-changelog` label (pass it in PR_LABELS, comma-separated).
#
# Usage:
#   bash .github/scripts/check-changelog.sh [base-ref] [repo-root]
#   PR_LABELS="no-changelog,docs" bash .github/scripts/check-changelog.sh main
#
# Requires: git. Exits 1 if the entry is missing. On an unresolvable base-ref it
# fails OPEN (exit 0): CI is not the place to guess the diff.
set -euo pipefail

BASE_REF="${1:-}"
ROOT="${2:-.}"
cd "$ROOT"

CHANGELOG="CHANGELOG.md"
SKIP_LABEL="no-changelog"

# Paths whose change, ON ITS OWN, does not demand a changelog entry.
EXEMPT='^(CHANGELOG\.md$)'

# ── Early exits ──────────────────────────────────────────────────────────────
if [ ! -f "$CHANGELOG" ]; then
  echo "ℹ️  No $CHANGELOG in the repo; nothing to check."
  exit 0
fi

case ",${PR_LABELS:-}," in
  *",$SKIP_LABEL,"*)
    echo "ℹ️  Label '$SKIP_LABEL' present: skipping the changelog check."
    exit 0
    ;;
esac

# Comparison base: the one passed in, or the first base branch that resolves.
if [ -z "$BASE_REF" ]; then
  for candidate in origin/develop develop origin/main main; do
    if git rev-parse --verify -q "$candidate" >/dev/null; then
      BASE_REF="$candidate"
      break
    fi
  done
fi

if [ -z "$BASE_REF" ] || ! git rev-parse --verify -q "$BASE_REF" >/dev/null; then
  echo "ℹ️  Could not resolve the base branch ('${BASE_REF:-none}'); skipping the check."
  exit 0
fi

# ── What changed against the base? ───────────────────────────────────────────
# Three dots: only what this branch adds since it forked off the base.
changed="$(git diff --name-only "$BASE_REF...HEAD" 2>/dev/null || true)"

if [ -z "$changed" ]; then
  echo "✅ Changelog: no changes against $BASE_REF."
  exit 0
fi

notable="$(printf '%s\n' "$changed" | grep -Ev "$EXEMPT" || true)"
if [ -z "$notable" ]; then
  echo "✅ Changelog: the PR only touches the $CHANGELOG itself — exempt."
  exit 0
fi

# ── The rule ─────────────────────────────────────────────────────────────────
if ! printf '%s\n' "$changed" | grep -qx "$CHANGELOG"; then
  echo "❌ This PR changes the project but does not touch $CHANGELOG."
  echo "   Files that demand it (first 10):"
  printf '%s\n' "$notable" | head -10 | sed 's/^/     · /'
  echo "→ Add the entry under '## [Unreleased]' (/changelog skill). If there really is"
  echo "  nothing to tell, put the '$SKIP_LABEL' label on the PR and explain why."
  exit 1
fi

# Version cut: moving Unreleased into `## [X.Y.Z] - date` leaves it empty on purpose.
if git diff "$BASE_REF...HEAD" -- "$CHANGELOG" \
  | grep -qE '^\+## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}'; then
  echo "✅ Changelog: version cut detected."
  exit 0
fi

# Current content of the Unreleased section (up to the next `## [` heading).
unreleased="$(awk '/^## \[Unreleased\]/ {f=1; next} /^## \[/ {f=0} f' "$CHANGELOG")"

if ! printf '%s\n' "$unreleased" | grep -qE '^[-*] '; then
  echo "❌ $CHANGELOG changed, but the '## [Unreleased]' section has no entries."
  echo "→ Write what changed for whoever uses the project, under the matching category"
  echo "  (Added / Changed / Deprecated / Removed / Fixed / Security)."
  exit 1
fi

echo "✅ Changelog: there is an entry under '## [Unreleased]'."
