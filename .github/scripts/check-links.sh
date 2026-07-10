#!/usr/bin/env bash
# check-links.sh — verifies that relative links between files in the repo
# point to files that exist. It does not check external URLs (http/https/mailto)
# or targets containing `[PLACEHOLDERS]` — only the internal link network.
#
# Usage:
#   bash .github/scripts/check-links.sh [repo-root]
#
# Requires: git, perl. Exits with 1 if there are broken links.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

broken=0

while IFS= read -r f; do
  dir="$(dirname "$f")"
  while IFS= read -r target; do
    case "$target" in
      http://*|https://*|mailto:*) continue ;;   # external: out of scope
      *'['*) continue ;;                          # contains a placeholder
      '') continue ;;
    esac
    # Strip the #anchor fragment if present.
    path="${target%%#*}"
    [ -z "$path" ] && continue
    if [ ! -e "$dir/$path" ] && [ ! -e "$path" ]; then
      echo "❌ $f: broken link → $target"
      broken=1
    fi
  done < <(perl -CSD -ne 'while (/\]\(([^)\s]+)\)/g) { print "$1\n" }' "$f")
done < <(git ls-files '*.md')

if [ "$broken" -ne 0 ]; then
  echo "→ Fix the paths or remove the links to deleted documents."
  exit 1
fi
echo "✅ Internal links: all point to existing files."
