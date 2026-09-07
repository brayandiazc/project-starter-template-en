#!/usr/bin/env bash
# check-release.sh — nothing reaches production without a version.
#
# It runs on PRs toward `main` (the merge that publishes). It verifies two things
# release.yml takes for granted and cannot enforce by itself — by the time it runs,
# the merge already happened:
#
#   1. The topmost version in the CHANGELOG is UNPUBLISHED (it has no tag).
#      If it already has a tag, this merge would publish nothing: release.yml would
#      consider it done and the change would reach production without a version,
#      silently.
#   2. `## [Unreleased]` is empty. If it has entries, there is work that would land
#      on main outside of any version. The cut happens last, right before merging.
#
# Usage:
#   bash .github/scripts/check-release.sh [repo-root]
#
# Requires: git (with tags available: checkout with fetch-depth 0).
# Exits 1 if the version still needs cutting. With no CHANGELOG.md it imposes nothing.
set -euo pipefail

# The script path is resolved BEFORE the cd: afterwards, $0 points somewhere else.
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ROOT="${1:-.}"
cd "$ROOT"

CHANGELOG="CHANGELOG.md"

if [ ! -f "$CHANGELOG" ]; then
  echo "ℹ️  No $CHANGELOG in the repo; nothing to check."
  exit 0
fi

# ── 1. Is there a cut, unpublished version? ──────────────────────────────────
# Only versions with a real date count (it ignores templates like "[DATE]"), the
# same way release.yml does.
line="$(grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}' "$CHANGELOG" || true)"

if [ -z "$line" ]; then
  echo "❌ The $CHANGELOG has no dated version."
  echo "→ Cut the version with /release (move '## [Unreleased]' to '## [X.Y.Z] - $(date +%F)')"
  echo "  before merging into main. Without that, release.yml publishes nothing."
  exit 1
fi

version="$(sed -E 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/' <<<"$line")"

# And is it a version of THIS project? A CHANGELOG that was never reset leaves the
# template's last version on top, and merging that into main would publish it as
# your own. The criterion is not repeated here: check-inheritance.sh decides it.
if ! bash "$SCRIPTS/check-inheritance.sh" --publishable-version .; then
  echo "→ This merge would publish the template's release, not yours."
  exit 1
fi

if git rev-parse -q --verify "refs/tags/v$version" >/dev/null; then
  echo "❌ The topmost version in the $CHANGELOG (v$version) is already published."
  echo "→ This merge would reach production without a version of its own: release.yml"
  echo "  would see v$version, consider it published and create no release."
  echo "  Cut a new version with /release before merging."
  exit 1
fi

# ── 2. Is there work left outside the version? ───────────────────────────────
unreleased="$(awk '/^## \[Unreleased\]/ {f=1; next} /^## \[/ {f=0} f' "$CHANGELOG")"

if printf '%s\n' "$unreleased" | grep -qE '^[-*] '; then
  echo "❌ v$version is cut, but '## [Unreleased]' still has entries:"
  printf '%s\n' "$unreleased" | grep -E '^[-*] ' | sed -n '1,5s|^|   · |p'
  echo "→ That work would land on main outside any version. Include it in the cut"
  echo "  (run /release again) or leave it on develop for the next one."
  exit 1
fi

echo "✅ Release: v$version is cut, unpublished, and no loose work in Unreleased."
