#!/usr/bin/env bash
# check-git-flow.sh — does `develop` exist on the remote?
#
# CONTRIBUTING.md requires every working branch to be born from `develop`, and
# AGENTS.md repeats it word for word: "if develop does not exist, create it from
# main and publish it". Nothing checked it.
#
# Why it matters: a `develop` that only exists locally satisfies the rule when
# you branch and breaks it when you open the PR. `gh pr create --base develop`
# fails with "Base ref must be a branch", and the obvious way out of that error
# is to open the PR against `main` — exactly what the convention forbids. The
# failure lands late, with the work already done, and its apparent fix is the
# one that breaks the flow.
#
# Usage:
#   bash .github/scripts/check-git-flow.sh [repo-root]
#
# Fails OPEN: outside a git repo, without a remote, without network, or in a
# project that does not use Git Flow, it has no opinion. It exits 1 only when
# the remote exists and `develop` does not.
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT" || exit 0

git rev-parse --git-dir >/dev/null 2>&1 || {
  echo "ℹ️  This is not a git repository; nothing to check."
  exit 0
}

# A project may have rewritten its CONTRIBUTING to work on `main` alone. If
# `develop` is not named there, there is no Git Flow to enforce.
if [ -f CONTRIBUTING.md ] && ! grep -q 'develop' CONTRIBUTING.md; then
  echo "ℹ️  CONTRIBUTING.md does not mention 'develop'; this project does not use Git Flow."
  exit 0
fi

git remote get-url origin >/dev/null 2>&1 || {
  echo "ℹ️  There is no 'origin' remote; nothing to check."
  exit 0
}

# `ls-remote` is the only reliable source: a local `refs/remotes/origin/develop`
# can be the memory of a branch already deleted on the server.
if ! output="$(git ls-remote --heads origin develop 2>/dev/null)"; then
  echo "ℹ️  Could not reach the remote (no network or no credentials); skipping."
  exit 0
fi

if [ -n "$output" ]; then
  echo "✅ Git Flow: 'develop' exists on the remote."
  exit 0
fi

echo "❌ 'develop' does not exist on the remote, but CONTRIBUTING.md takes it for granted."
echo "→ Every working branch is born from 'develop'. Without it published, the PR"
echo "  has no base: 'gh pr create --base develop' fails with \"Base ref must be a"
echo "  branch\", and opening it against 'main' — the obvious way out — is what the"
echo "  convention forbids."
echo
echo "   git push origin develop:refs/heads/develop"
echo
echo "  (if you do not have it locally either: 'git branch develop origin/main' first)"
exit 1
