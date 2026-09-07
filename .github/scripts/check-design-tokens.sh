#!/usr/bin/env bash
# check-design-tokens.sh — the design system is enforced, not remembered.
#
# The product's views do NOT use raw color: no hex, no inline rgb()/hsl()/oklch(),
# no utilities or variables whose name says the COLOR instead of the ROLE
# (bg-blue-500, $gray-700, --ui-red), and no arbitrary values (bg-[#0A7A9D]).
# Semantic tokens only — that is what lets a product change its brand by touching a
# single block of design/tokens.css.
#
# IT IS FRAMEWORK-AGNOSTIC: the rule it verifies is about the tokens, not about any
# library. It looks in the usual view and style folders. If the repository has no
# views yet —a freshly instantiated template, or a project with no UI— it imposes
# nothing.
#
# Usage:
#   bash .github/scripts/check-design-tokens.sh [repo-root]
#
# Requires: python3. Exits 1 if it finds problems.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

# Usual view folders, covering the most common conventions:
# app/views and app/components, templates, src, components, pages, layouts.
DIRS="app/views app/components templates src components pages layouts"
# `css`, `js` and `ts` were not there, and that was the big hole: **CSS is where raw
# colors live in ANY stack**. A project with app/assets/stylesheets/*.css was not
# checked either, and one with no framework —views as text templates in .js, styles in
# .css— passed the check green without a single file being opened. The system's golden
# rule ("never a hex, only tokens") went unverified in exactly the file where it breaks.
EXT='html erb astro jsx tsx vue j2 jinja css scss sass less js ts mjs'

# The file that DEFINES the tokens is the obvious exception: there, raw colors are the
# content, not the violation. It is exempted by name, not by folder, because when
# design/ migrates inside the application it ends up in different places per stack.
EXEMPT='tokens.css'

find_files() { # $1 = folder, $2 = depth ('' = recursive)
  for e in $EXT; do
    find "$1" ${2:+-maxdepth "$2"} -type f -name "*.$e" \
      -not -path '*/node_modules/*' -not -path '*/vendor/*' \
      -not -path '*/dist/*' -not -path '*/build/*' 2>/dev/null || true
  done
}

files=""
for d in $DIRS; do
  [ -d "$d" ] || continue
  found="$(find_files "$d" '')"
  [ -n "$found" ] && files="$files$found"$'\n'
done

# The root, one level deep: in a project with no framework the page lives at
# ./index.html and the styles at ./styles.css, and no folder in DIRS covers them.
root_files="$(find_files . 1)"
[ -n "$root_files" ] && files="$files$root_files"$'\n'

# Drop exempt files (by basename) and blank lines.
for x in $EXEMPT; do
  files="$(printf '%s\n' "$files" | grep -v "/$x\$" | grep -v "^$x\$" || true)"
done
files="$(printf '%s\n' "$files" | sed '/^[[:space:]]*$/d' || true)"

if [ -z "$files" ]; then
  # "Nothing to check" was indistinguishable from a real ✅: it read as "does not
  # apply" instead of "I do not know how to look at this". Now it says WHERE and WHAT
  # it looked for, so it is a reviewable claim and not a silence.
  echo "ℹ️  Design system: found no views or styles to check."
  echo "   Folders: $DIRS (and the root, one level)."
  echo "   Extensions: $EXT."
  echo "   If your project has UI somewhere else, add it to DIRS in this script."
  exit 0
fi

fail=0

# ── 1. Raw colors in the views ───────────────────────────────────────────────
# Color names, in the three notations they get written in (hyphenated utility,
# preprocessor variable, custom property). It detects the NOTATION, not a specific
# framework: the violation is that the name says the COLOR and not the ROLE.
# `bg-neutral` is fine; `bg-neutral-500`, `$gray-700` and `--ui-red` are not.
PALETTE='slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose'

raw=""
while IFS= read -r f; do
  [ -n "$f" ] && [ -f "$f" ] || continue
  hits="$(PALETTE="$PALETTE" python3 - "$f" <<'PY' || true
import os, re, sys

path = sys.argv[1]
src = open(path).read()

# Comments are not sent to the browser, so they violate nothing — and without this
# exclusion, DOCUMENTING the rule violated it: a stylesheet header spelling out the
# forbidden patterns ("never #hex, never rgb()") showed up as a finding. That
# discourages exactly the comment that explains the system.
def strip_comments(text, path):
    ext = path.rsplit(".", 1)[-1].lower()
    patterns = [r"/\*.*?\*/", r"<!--.*?-->"]
    # `//` only in languages that use it, and never after `:` — otherwise `https://…`
    # would eat the rest of the line.
    if ext in ("js", "ts", "mjs", "jsx", "tsx", "vue", "astro", "css", "scss", "sass", "less"):
        patterns.append(r"(?<!:)//[^\n]*")
    for p in patterns:
        text = re.sub(p, blank, text, flags=re.S)
    return text

# Exception: third-party logos. A brand logo carries ITS colors —Google, GitHub,
# Stripe— and re-tinting it with our tokens violates their brand guidelines
# (design/README.md → "Third-party brand logos"). The element is marked with
# `data-brand="<brand>"` and its content is left out of the analysis. That is the only
# way in: a loose hex anywhere else still fails.
def blank(m):
    # Keep newlines so line numbers do not shift.
    return re.sub(r"[^\n]", " ", m.group(0))


def strip_brands(text):
    return re.sub(r"<svg\b[^>]*\bdata-brand=[^>]*>.*?</svg>", blank, text, flags=re.S)

palette = os.environ["PALETTE"]
patterns = [
    (rf"(?:bg|text|border|from|via|to|ring|fill|stroke|decoration|outline|shadow|accent)-(?:{palette})-\d{{2,3}}\b",
     "raw palette utility"),
    # Two forms, and neither can swallow the system's own tokens: `--neutral` is a
    # valid ROLE here. Hence requiring either a prefix (`--ui-red`) or a number
    # (`--gray-700`) — which is exactly what turns the name into a color.
    (rf"--[a-z]{{1,8}}-(?:{palette})\b", "raw palette variable"),
    (rf"--(?:{palette})-\d{{2,3}}\b", "raw palette variable"),
    (rf"\$(?:{palette})-\d{{2,3}}\b", "raw palette variable"),
    (r"(?:bg|text|border|fill|stroke)-\[[^\]]+\]", "arbitrary value"),
    (r"#[0-9a-fA-F]{3}(?![0-9a-zA-Z_-])|#[0-9a-fA-F]{6}(?![0-9a-zA-Z_-])", "hex color"),
    (r"\b(?:rgba?|hsla?|oklch)\(", "inline color"),
]

for n, line in enumerate(strip_comments(strip_brands(src), path).split("\n"), 1):
    for pattern, label in patterns:
        for m in re.finditer(pattern, line):
            print(f"{path}:{n}: {label}: {m.group(0)}")
PY
)"
  [ -n "$hits" ] && raw="$raw$hits"$'\n'
done <<< "$files"

if [ -n "${raw// /}" ]; then
  echo "❌ Raw colors in the views (semantic tokens only):"
  printf '%s' "$raw" | sed '/^$/d' | sed 's/^/   · /'
  echo "→ Use the system tokens (primary, base-100, base-content…). See design/README.md"
  echo "  → 'Golden rule'. If you really need a new color, it goes in tokens.css."
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "✅ Design system: the views use only semantic tokens."
