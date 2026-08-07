#!/usr/bin/env bash
# check-inheritance.sh — an instantiated project does not carry the template's life.
#
# Everything product-related (specs/, roadmap, product definition) reaches the user
# empty, but the CHANGELOG and the ADRs can slip through full of the origin
# repository's history. This check prevents that, using a deterministic criterion
# instead of text heuristics:
#
#   `.template-origin` records the instantiation DATE. A project created on day X
#   cannot have versions published nor decisions taken before day X. Anything dated
#   earlier is inherited and does not belong.
#
# It checks three things:
#   1. CHANGELOG.md with no versions older than the instantiation.
#   2. docs/decisions/ with no ADRs older than the instantiation (except 0001, the
#      canonical ADR on why decisions are recorded: that one is inherited).
#   3. No files that only make sense in the template repository.
#
# Usage:
#   bash .github/scripts/check-inheritance.sh [repo-root]
#
# The template itself has no `.template-origin`, so nothing is enforced there: it
# only acts on already instantiated projects. Exits 1 if it finds inheritance.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

ORIGIN=".template-origin"

if [ ! -f "$ORIGIN" ]; then
  echo "ℹ️  No $ORIGIN: this is not an instantiated project. Nothing to check."
  exit 0
fi

date_value="$(grep -m1 '^fecha=' "$ORIGIN" | cut -d= -f2- | tr -d '[:space:]' || true)"
[ -z "$date_value" ] && date_value="$(grep -m1 '^date=' "$ORIGIN" | cut -d= -f2- | tr -d '[:space:]' || true)"

if ! printf '%s' "$date_value" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  echo "ℹ️  $ORIGIN has no valid date ('${date_value:-empty}'); skipping the check."
  exit 0
fi

fail=0

# ── 1. Inherited versions in the CHANGELOG ───────────────────────────────────
if [ -f CHANGELOG.md ]; then
  inherited="$(grep -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}' CHANGELOG.md \
    | awk -v d="$date_value" '{ if ($NF < d) print "   · " $0 }' || true)"
  if [ -n "$inherited" ]; then
    echo "❌ The CHANGELOG carries versions older than the instantiation ($date_value):"
    printf '%s\n' "$inherited"
    echo "→ They belong to the template, not to your project. Leave the CHANGELOG with"
    echo "  your own first version; the template's history lives in its repository."
    fail=1
  fi
fi

# ── 2. Inherited ADRs ────────────────────────────────────────────────────────
# 0001 is exempt: it is the canonical ADR on why decisions are recorded, and it
# belongs in any project that uses ADRs.
if [ -d docs/decisions ]; then
  adrs=""
  for f in docs/decisions/*.md; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in
      0000-template.md | 0001-record-architecture-decisions.md | README.md) continue ;;
    esac
    d="$(grep -m1 -oE '\*\*Date\*\*:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" \
      | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
    [ -z "$d" ] && continue
    if [ "$d" \< "$date_value" ]; then
      adrs="$adrs   · $f (date: $d)"$'\n'
    fi
  done
  if [ -n "$adrs" ]; then
    echo "❌ There are ADRs older than the instantiation ($date_value):"
    printf '%s' "$adrs"
    echo "→ They are the template's decisions, not yours. Remove them: the"
    echo "  instantiation ADR already records what was inherited and links to the origin."
    fail=1
  fi
fi

# ── 3. Files exclusive to the template repository ────────────────────────────
declare -a leftovers=()
for path in \
  ".github/workflows/template-parity.yml" \
  ".github/scripts/check-parity.sh"; do
  [ -e "$path" ] && leftovers+=("$path")
done

if [ "${#leftovers[@]}" -gt 0 ]; then
  echo "❌ Files that only make sense in the template repository are still here:"
  printf '   · %s\n' "${leftovers[@]}"
  echo "→ Delete them: they keep parity between the template variants, something"
  echo "  your project does not need."
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "✅ Inheritance: the project carries no template history or files."
