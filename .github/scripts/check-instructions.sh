#!/usr/bin/env bash
# check-instructions.sh — the README does not tell you to run what does not exist.
#
# The prune when instantiating deletes whole blocks of `.env.example` depending on the
# capabilities the product does NOT have. When ALL of them get pruned —a product
# with no server, no build, with the key living in the user's browser— the README
# is left with two lines telling you to do things that no longer exist:
#
#     cp .env.example .env      # ← there is not a single variable to fill in
#     [MIGRATIONS_COMMAND]      # ← there is no database
#
# And **no check flagged them**, because they are not placeholders: they are
# hardcoded text. They read as correct instructions until somebody runs them. Same
# family as this template's expensive findings: whatever stays plausible and false
# passes green.
#
# Usage:
#   bash .github/scripts/check-instructions.sh [repo-root]
#
# In TEMPLATE mode (TEMPLATE-USAGE.md exists) it imposes nothing: the template's
# .env.example ships every block and the README is the skeleton that gets pruned.
# Exits 1 if the README prescribes a step the project does not have.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

[ -f README.md ] || { echo "ℹ️  No README.md; nothing to check."; exit 0; }

if [ -f TEMPLATE-USAGE.md ]; then
  echo "ℹ️  Template mode: the README is still the skeleton. Nothing to check."
  exit 0
fi

fail=0

# ── 1. `cp .env.example .env` with not a single variable to fill in ──────────
# "Has variables" = at least one line shaped NAME=value outside the comments. An
# .env.example deliberately kept but empty —with only its explanation of why there
# are none, which is what the guide prescribes— counts as zero.
if [ -f .env.example ]; then
  n_vars="$(grep -cE '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=' .env.example || true)"
else
  n_vars=0
fi

if [ "${n_vars:-0}" -eq 0 ] && grep -qE '^[[:space:]]*cp[[:space:]]+\.env\.example[[:space:]]+\.env' README.md; then
  echo "❌ The README says 'cp .env.example .env', but .env.example declares"
  echo "   no variables$([ -f .env.example ] || echo ' (it does not even exist)')."
  echo "→ This product has no environment variables: drop that line from the install"
  echo "  block. Keep .env.example with the explanation of why it is empty —a plain"
  echo "  empty file reads as an oversight— but do not tell people to copy it."
  fail=1
fi

# ── 2. Command placeholders that survived the prune ──────────────────────────
# `[MIGRATIONS_COMMAND]` in the install block of a product with no database is the
# same mistake under another name. check-placeholders.sh does see it, so here we
# only warn about what that one cannot know: that the step does not apply.
if grep -qE '^\[MIGRATIONS_COMMAND\]' README.md && [ ! -f db/schema.rb ] \
   && [ ! -d migrations ] && [ ! -d db/migrate ] && [ ! -d alembic ] \
   && [ "${n_vars:-0}" -eq 0 ]; then
  echo "❌ The README says to run [MIGRATIONS_COMMAND], but there is neither a"
  echo "   migrations folder nor a single environment variable: this product has no"
  echo "   database."
  echo "→ Drop that line from the install block (TEMPLATE-USAGE.md §4)."
  fail=1
fi

[ "$fail" -ne 0 ] && exit 1
echo "✅ Instructions: the README does not prescribe steps the project lacks."
