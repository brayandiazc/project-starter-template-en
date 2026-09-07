#!/usr/bin/env bash
# check-inheritance.sh — an instantiated project does not drag the template's life.
#
# Everything product-related (roadmap, business model) reaches the user empty, but
# the CHANGELOG and the ADRs slipped through full of the origin repository's history.
# This check prevents that, and uses a deterministic criterion instead of text
# heuristics:
#
#   `.template-origin` stores the instantiation DATE. A project created on day X
#   cannot have versions published or decisions taken before day X. Anything dated
#   earlier is inheritance and does not belong.
#
# It verifies three things:
#   1. CHANGELOG.md with no versions predating instantiation.
#   2. docs/decisions/ with no ADRs predating instantiation (except 0001, which is
#      the canonical ADR on why decisions are recorded: that one is inherited).
#   3. None of the files exclusive to the template repo.
#
# Usage:
#   bash .github/scripts/check-inheritance.sh [repo-root]
#   bash .github/scripts/check-inheritance.sh --publishable-version [repo-root]
#
# In the template itself there is no `.template-origin`, so it imposes nothing: it
# only acts on already instantiated projects. Exits 1 if it finds inheritance.
set -euo pipefail

PUBLISHABLE=0
# --publishable-version: is the topmost CHANGELOG version one of THIS project?
# Exits 1 if it belongs to the template. It is consulted by release.yml (before
# creating the tag) and check-release.sh (before merging into main).
#
# It exists because publishing `main` before resetting the CHANGELOG publishes the
# TEMPLATE's release, and nothing caught it: `main` gets published pointing at the
# initial commit —with the inherited CHANGELOG— and the push fires
# release.yml, which sees the topmost version, checks it has no tag, and publishes
# it with another repository's notes. The prune says `git tag -d`, but the tag does
# not exist yet when that runs: the push creates it, two steps later.
#
# And the expensive part comes later: the day the project reaches its own 1.0.0,
# release.yml will say "it already has a tag" and skip that release SILENTLY.
# A failure planted today that gets collected a year from now.
if [ "${1:-}" = "--publishable-version" ]; then
  PUBLISHABLE=1
  shift
fi

ROOT="${1:-.}"
cd "$ROOT"

ORIGIN=".template-origin"

if [ ! -f "$ORIGIN" ]; then
  [ "$PUBLISHABLE" -eq 1 ] && exit 0   # the template itself: it publishes its own
  echo "ℹ️  No $ORIGIN: this is not an instantiated project. Nothing to check."
  exit 0
fi

date_str="$(grep -m1 '^date=' "$ORIGIN" | cut -d= -f2- | tr -d '[:space:]' || true)"

if ! printf '%s' "$date_str" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  [ "$PUBLISHABLE" -eq 1 ] && exit 0
  echo "ℹ️  $ORIGIN carries no valid date ('${date_str:-empty}'); skipping the check."
  exit 0
fi

# ── --publishable-version mode ───────────────────────────────────────────────
# Same criterion as block 1, applied to ONE version: the topmost in the CHANGELOG,
# which is the one release.yml would publish.
#
#   With `versions=` (the normal case, written when instantiating): it is inheritance
#   if the number is on the list and the date is not later than the instantiation —
#   except for the first-own-version exception, identical to block 1's: every
#   instance cuts its 0.1.0 on the same day it is installed, and the template also
#   had a 0.1.0. It is exempted if it is dated that day AND its number is NOT the
#   template's newest version, because that is exactly the one left on top when
#   somebody skips the reset.
#
#   Without `versions=` (older instances): only what is dated STRICTLY before the
#   install is rejected. Here a false positive is not noise —it blocks publishing—
#   so when in doubt it publishes.
if [ "$PUBLISHABLE" -eq 1 ]; then
  [ -f CHANGELOG.md ] || exit 0
  line="$(grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}' CHANGELOG.md || true)"
  [ -z "$line" ] && exit 0
  v="$(sed -E 's/^## \[([0-9]+\.[0-9]+\.[0-9]+)\].*/\1/' <<<"$line")"
  d="$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' <<<"$line" | tail -1)"
  versions="$(grep -m1 '^versions=' "$ORIGIN" | cut -d= -f2- | tr -d '[:space:]' || true)"
  newest="${versions%%,*}"

  inherited=0
  if [ -n "$versions" ]; then
    case ",$versions," in
      *",$v,"*)
        if [ "$d" \> "$date_str" ]; then inherited=0
        elif [ "$d" = "$date_str" ] && [ "$v" != "$newest" ]; then inherited=0
        else inherited=1
        fi
        ;;
    esac
  elif [ "$d" \< "$date_str" ]; then
    inherited=1
  fi

  if [ "$inherited" -eq 1 ]; then
    echo "⛔ v$v ($d) is a version OF THE TEMPLATE, not of this project."
    echo "   Instantiated on $date_str${versions:+; inherited versions: $versions}."
    echo "→ Publishing it would create a tag and a release with another repository's notes."
    echo "  Worse: the day this project reaches its own v$v, release.yml would say"
    echo "  'it already has a tag' and skip that release silently."
    echo "  Reset the CHANGELOG when instantiating and cut your own version."
    exit 1
  fi
  exit 0
fi

fail=0

# ── 1. Inherited versions in the CHANGELOG ───────────────────────────────────
# Main criterion: `.template-origin` may carry `versions=` with the exact list of
# versions the template had at instantiation time. A
# CHANGELOG entry with one of those versions AND a date no later than the
# instantiation is inheritance, unambiguously.
# Fallback (older instances without `versions=`): by date, with `<=` — the strict
# `<` let inheritance through when template and instance shared a day, which is the
# normal case of "I install the freshly published template". The cost of `<=` is
# flagging an own release cut on the same day as the instantiation: rare, and the
# message explains it.
if [ -f CHANGELOG.md ]; then
  versions="$(grep -m1 '^versions=' "$ORIGIN" | cut -d= -f2- | tr -d '[:space:]' || true)"
  # The date is extracted by pattern, not with $NF: a heading with text after the
  # date ("## [1.0.0] - 2026-01-01 (code name)") left something else in $NF and the
  # string comparison produced a false positive.
  # First-own-version exemption: every new project cuts its `0.1.0` on the same day it
  # instantiates, and the template also had a `0.1.0` — so `versions=` counted it as
  # inherited even when the reset had been done properly, and no start could cut its
  # release. The very top entry is exempted if it is dated that day AND its number is
  # NOT the template's newest version (the first element of `versions=`), because
  # **that is exactly the one left on top when somebody skips the reset**. And it is a
  # single entry: whatever sits below is still flagged.
  newest="${versions%%,*}"
  inherited="$(grep -E '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}' CHANGELOG.md \
    | awk -v f="$date_str" -v vs=",$versions," -v vn="$newest" '{
        v = $2; gsub(/[][]/, "", v)
        if (!match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) next
        d = substr($0, RSTART, RLENGTH)
        n++
        if (vs != ",,") {
          if (n == 1 && d == f && v != vn) next
          if (index(vs, "," v ",") && d <= f) print "   · " $0
        }
        else if (d <= f) print "   · " $0
      }' || true)"
  if [ -n "$inherited" ]; then
    echo "❌ The CHANGELOG drags versions predating the instantiation ($date_str):"
    printf '%s\n' "$inherited"
    echo "→ They belong to the template, not to your project. Leave the CHANGELOG with"
    echo "  your own first version; the template's history lives in its repository."
    echo "  (Is it a release of YOURS cut on the same day you instantiated? Add"
    echo "  'versions=' with the template's versions to .template-origin so the"
    echo "  criterion is exact.)"
    fail=1
  fi
fi

# ── 2. Inherited ADRs ────────────────────────────────────────────────────────
# 0001 is excepted: it is the canonical ADR on why decisions are recorded, and its
# place is any project that uses ADRs.
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
    # Here the strict `<` is DELIBERATE, unlike in the CHANGELOG: the project's own
    # instantiation ADR (0002) is dated the same day it instantiates, so `<=` would
    # turn every healthy project red. The residue (a template ADR dated exactly that
    # day that the prune did not delete) is accepted and documented.
    if [ "$d" \< "$date_str" ]; then
      adrs="$adrs   · $f (date: $d)"$'\n'
    fi
  done
  if [ -n "$adrs" ]; then
    echo "❌ There are ADRs predating the instantiation ($date_str):"
    printf '%s' "$adrs"
    echo "→ They are the template's decisions, not yours. Remove them: the"
    echo "  instantiation ADR already documents what was inherited and links to the"
    echo "  origin repository."
    fail=1
  fi
fi

# ── 3. Files exclusive to the template repo ──────────────────────────────────
declare -a leftovers=()
for path in \
  "TEMPLATE-USAGE.md"; do
  [ -e "$path" ] && leftovers+=("$path")
done

if [ "${#leftovers[@]}" -gt 0 ]; then
  echo "❌ Files that only make sense in the template repo are still here:"
  printf '   · %s\n' "${leftovers[@]}"
  echo "→ Delete it (TEMPLATE-USAGE.md §4 prune rule): it is the template's guide,"
  echo "  already fulfilled. Also, while TEMPLATE-USAGE.md exists,"
  echo "  check-placeholders.sh believes this repo is still the template."
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "✅ Inheritance: the project drags no template history or files."
