#!/usr/bin/env bash
# check-parity.sh — compares this template's file structure with that of its
# sibling variant (en ↔ es) to detect divergence between variants.
#
# TEMPLATE-REPO ONLY: this script (and the template-parity.yml workflow that
# runs it) make no sense in an instantiated project — delete them when you
# instantiate the template.
#
# Usage:
#   bash .github/scripts/check-parity.sh <path-to-sibling-repo>
#
# Compares tracked files only (git ls-files), applying the map of known
# renames between languages.
set -euo pipefail

SIBLING="${1:?usage: check-parity.sh <path-to-sibling-repo>}"

# Map of known renames between the variants (en ↔ es). This pair currently
# has none — the function is a deliberate no-op kept as the single place to
# add `sed` rules if language-specific file names ever appear.
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
  echo "→ Port the pending change to the sibling variant or update this script's rename map."
  exit 1
fi
