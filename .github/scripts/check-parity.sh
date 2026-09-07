#!/usr/bin/env bash
# check-parity.sh — compares this template's file structure with its sibling
# variant (en ↔ es) to detect divergences between variants.
#
# TEMPLATE-REPO ONLY: this script (and the template-parity.yml workflow that
# runs it) makes no sense in an instantiated project — the /instantiate skill
# removes them.
#
# Usage:
#   bash .github/scripts/check-parity.sh <path-to-sibling-repo>
#
# Compares only versioned files (git ls-files), applying the map of known
# renames between languages.
set -euo pipefail

SIBLING="${1:?usage: check-parity.sh <path-to-sibling-repo>}"

# Map of known renames between variants (es ↔ en). Both sides are normalized
# toward the English name, so the script works in both directions.
# Today this pair has no files renamed across languages, so the normalization is the
# identity; if a file ever changes name between variants, add the matching `sed` here.
normalize() {
  cat
}

mine="$(git ls-files | normalize | sort)"
theirs="$(git -C "$SIBLING" ls-files | normalize | sort)"

if diff <(printf '%s\n' "$mine") <(printf '%s\n' "$theirs") >/tmp/parity-diff.$$ 2>&1; then
  echo "✅ Structural parity OK with the sibling variant."
  rm -f "/tmp/parity-diff.$$"
else
  echo "❌ Structural divergence from the sibling variant:"
  echo "   (\"<\" only exists here · \">\" only exists in the sibling)"
  cat "/tmp/parity-diff.$$"
  rm -f "/tmp/parity-diff.$$"
  echo "→ Port the pending change (/port-change skill) or update this script's rename map."
  exit 1
fi
