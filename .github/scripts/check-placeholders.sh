#!/usr/bin/env bash
# check-placeholders.sh — verifies the template's `[LIKE_THIS]` placeholders.
#
# Two modes, auto-detected:
#   - TEMPLATE mode (TEMPLATE-USAGE.md exists): every placeholder used in the
#     repo must be documented in the TEMPLATE-USAGE.md catalog (§3), either
#     literally or covered by a wildcard such as `[*_COMMAND]` or `[LINK_*]`.
#   - INSTANCE mode (TEMPLATE-USAGE.md has been deleted): no unfilled
#     placeholder may remain, except in the intentional skeletons.
#
# Usage:
#   bash .github/scripts/check-placeholders.sh [repo-root]
#
# Requires: git, perl. Exits with 1 if it finds problems.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

CATALOG="TEMPLATE-USAGE.md"

# Paths skipped in both modes:
#   - skeletons that keep placeholders on purpose (doc templates);
#   - .github/ (its brackets are issue-title prefixes such as "[BUG] …").
SKIP='^(\.github/|docs/conventions/_template\.md|docs/decisions/0000-template\.md)'

# "Meta" mentions about the placeholder system itself (they are not
# placeholders to fill in; they appear in the template's instructions).
META='^(PLACEHOLDER|PLACEHOLDERS|BRACKETS_IN_UPPERCASE)$'

# Extracts [UPPERCASE] placeholders from a file, ignoring markdown links
# `[TEXT](target)` thanks to the negative lookahead.
extract() {
  perl -CSD -ne 'while (/\[([A-ZÁÉÍÓÚÑ0-9_\/]{2,})\](?!\()/g) { print "$ARGV:$.: [$1]\n" }' "$1"
}

files() {
  git ls-files '*.md' '.env.example' | grep -Ev "$SKIP" || true
}

if [ -f "$CATALOG" ]; then
  # ── TEMPLATE mode: catalog consistency ─────────────────────────────────────
  # Wildcards documented in the catalog, in both directions:
  #   `[LINK_*]`    → prefix  LINK_
  #   `[*_COMMAND]` → suffix  _COMMAND
  prefixes="$(perl -CSD -ne 'while (/\[([A-ZÁÉÍÓÚÑ0-9_\/]+_)\*\]/g) { print "$1\n" }' "$CATALOG" | sort -u)"
  suffixes="$(perl -CSD -ne 'while (/\[\*(_[A-ZÁÉÍÓÚÑ0-9_\/]+)\]/g) { print "$1\n" }' "$CATALOG" | sort -u)"

  missing=0
  placeholders="$(
    files | grep -v "^$CATALOG$" | while IFS= read -r f; do extract "$f"; done \
      | sed -E 's/^.*\[([^]]+)\]$/\1/' | sort -u
  )"

  while IFS= read -r p; do
    [ -z "$p" ] && continue
    printf '%s' "$p" | grep -Eq "$META" && continue
    grep -qF "[$p]" "$CATALOG" && continue
    covered=0
    while IFS= read -r w; do
      [ -n "$w" ] && case "$p" in "$w"*) covered=1 ;; esac
    done <<<"$prefixes"
    while IFS= read -r w; do
      [ -n "$w" ] && case "$p" in *"$w") covered=1 ;; esac
    done <<<"$suffixes"
    [ "$covered" -eq 1 ] && continue
    echo "❌ [$p] is used in the repo but is not in the $CATALOG catalog (§3)."
    missing=1
  done <<<"$placeholders"

  if [ "$missing" -ne 0 ]; then
    echo "→ Add the missing placeholders to the $CATALOG catalog."
    exit 1
  fi
  echo "✅ Placeholders: every one in use is documented in the catalog."
else
  # ── INSTANCE mode: no unfilled placeholders may remain ─────────────────────
  leftovers="$(files | while IFS= read -r f; do extract "$f"; done || true)"
  # Meta mentions don't count as pending here either.
  leftovers="$(printf '%s' "$leftovers" | grep -Ev '\[(PLACEHOLDER|PLACEHOLDERS|BRACKETS_IN_UPPERCASE)\]' || true)"

  if [ -n "$leftovers" ]; then
    echo "❌ Unfilled placeholders remain:"
    printf '%s\n' "$leftovers"
    echo "→ Fill them in or delete the document if it doesn't apply (the original template ships the guide in TEMPLATE-USAGE.md)."
    exit 1
  fi
  echo "✅ Placeholders: none left unfilled."
fi
