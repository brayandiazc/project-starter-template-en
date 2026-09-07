#!/usr/bin/env bash
# check-links.sh — verifies that relative links between files in the repo point
# to files that exist. It does not check external URLs (http/https/mailto) or
# targets containing `[LIKE_THIS]` placeholders — only the internal link web.
#
# Usage:
#   bash .github/scripts/check-links.sh [repo-root]
#
# Requires: git, perl. Exits 1 if there are broken links.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

broken=0
scanned=0
missing=0

while IFS= read -r f; do
  # It lists what is tracked AND what exists untracked (`--others`), because both
  # cases really happen: pruning leaves tracked files that no longer exist, and
  # adopting the template in an existing project leaves files that exist and are not
  # tracked yet. Plain `git ls-files` only saw the first kind.
  #
  # Hence this guard: a tracked file deleted with `rm` still shows up in the list.
  # Without it, perl failed to open it, spat its raw error to stderr and the loop
  # carried on — the file went unchecked and the final summary said all was well.
  # A silent failure inside the guardrail itself.
  if [ ! -f "$f" ]; then
    missing=$((missing + 1))
    continue
  fi
  scanned=$((scanned + 1))
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
  # It skips code —inline and fenced— before searching: a document that QUOTES a
  # regular expression or a markdown fragment is not linking to anything. It really
  # happened: a log quoting `](?!\()` left the check red.
  done < <(perl -CSD -ne '
      if (/^\s*```/) { $fence = !$fence; next }
      next if $fence;
      s/`[^`]*`//g;
      while (/\]\(([^)\s]+)\)/g) { print "$1\n" }
    ' "$f")
done < <(git ls-files --cached --others --exclude-standard '*.md' | sort -u)

if [ "$missing" -gt 0 ]; then
  echo "ℹ️  $missing file(s) tracked by git are no longer on disk: not checked."
  echo "   That is normal mid-prune; confirm with 'git status' before committing."
fi

if [ "$broken" -ne 0 ]; then
  echo "→ Fix the paths or remove the links to deleted documents."
  exit 1
fi
# The number is not cosmetic: a "✅ all" never warns about anything, but a count that
# drops from 87 to 71 for no reason does get noticed.
echo "✅ Internal links: $scanned file(s) checked, every target exists."
