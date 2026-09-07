#!/usr/bin/env bash
# check-hooks-enabled.sh — are this clone's git hooks actually running?
#
# `core.hooksPath` does NOT travel in the repository: it is local config, manual,
# once per clone. So the DEFAULT state of any fresh clone is "no local verification
# at all": `pre-commit` does not format and `pre-push` does not run the checks
# before publishing.
#
# Why this matters more than it looks: on a private repository on the free plan
# **GitHub offers no branch protection**, so the rules CONTRIBUTING.md declares
# —PR required, no direct pushes to main/develop— are enforced by nobody. In
# that setup these hooks are the ONLY defense left, and they are the one people
# forget.
#
# This check does not live in CI nor inside `pre-push`, and not by oversight: CI
# cannot see anyone's local config, and putting it in `pre-push` would be circular
# —that hook only runs if the config we want to verify is already set. Run it by hand
# when cloning, which is the moment it gets decided.
#
# Usage:
#   bash .github/scripts/check-hooks-enabled.sh [repo-root]
#   bash .github/scripts/check-hooks-enabled.sh --fix [repo-root]
#
# Exits 1 if the hooks are not active. Outside a git repo, it has no opinion.
set -euo pipefail

FIX=0
if [ "${1:-}" = "--fix" ]; then
  FIX=1
  shift
fi

ROOT="${1:-.}"
cd "$ROOT"

git rev-parse --git-dir >/dev/null 2>&1 || {
  echo "ℹ️  This is not a git repository; nothing to check."
  exit 0
}

# Without the folder there is nothing to enable: a project may have deleted it.
[ -d .githooks ] || {
  echo "ℹ️  No .githooks/ folder in this repo; nothing to enable."
  exit 0
}

current="$(git config --get core.hooksPath || true)"

if [ "$current" = ".githooks" ]; then
  # Pointing at the right place is not enough: the hooks have to be runnable.
  not_executable=""
  for h in .githooks/*; do
    [ -f "$h" ] || continue
    [ -x "$h" ] || not_executable="$not_executable $(basename "$h")"
  done
  if [ -n "$not_executable" ]; then
    echo "❌ core.hooksPath points at .githooks, but these are not executable:$not_executable"
    if [ "$FIX" -eq 1 ]; then
      chmod +x .githooks/* && echo "✅ Permissions fixed."
      exit 0
    fi
    echo "→ chmod +x .githooks/*"
    exit 1
  fi
  echo "✅ Git hooks active: core.hooksPath = .githooks"
  exit 0
fi

if [ "$FIX" -eq 1 ]; then
  git config core.hooksPath .githooks
  chmod +x .githooks/* 2>/dev/null || true
  echo "✅ Git hooks enabled: core.hooksPath = .githooks"
  exit 0
fi

echo "❌ The git hooks are NOT active in this clone."
echo "   core.hooksPath: ${current:-(unset)}"
echo "→ Without them, 'pre-commit' does not format and 'pre-push' does not verify"
echo "  before publishing: failures get found in CI, which is slower and —on a"
echo "  private repository— on a metered budget."
echo
echo "   git config core.hooksPath .githooks"
echo
echo "  (or 'bash .github/scripts/check-hooks-enabled.sh --fix')"
echo "  If this repository has no branch protection —GitHub does not offer it on"
echo "  private repos on the free plan— this is the ONLY defense left."
exit 1
