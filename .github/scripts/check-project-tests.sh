#!/usr/bin/env bash
# check-project-tests.sh — runs the PROJECT's tests, not the template's.
#
# WHY IT EXISTS:
#   `.github/scripts/tests/run-tests.sh` tests this template's hooks and scripts.
#   Those tests survive instantiation and keep passing forever, no matter what the
#   product does. Measured on a real start: with the main algorithm broken —it
#   recommended the most expensive provider— and two project tests red, `pre-push`
#   said "✅ Test suite · all green".
#
#   A ✅ that does not test the product is worse than having no check: it gives false
#   confidence at exactly the moment you decide to open the PR.
#
# HOW IT KNOWS WHAT TO RUN:
#   The test command is declared in the README.md "Usage" block. It is read from there
#   so there is no second copy to drift out of sync.
#
# Usage:
#   bash .github/scripts/check-project-tests.sh [repo-root]
#
# Exits 1 if the project tests fail. If the project has no tests yet it warns and
# passes — but it SAYS SO, which is the difference between "nothing to test" and
# "everything passes".
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT"

if [ ! -f README.md ]; then
  echo "ℹ️  No README.md: I do not know the test command. Nothing to run."
  exit 0
fi

# The README's "Usage" block has one line per command, with its comment:
#   bin/rails test                 # test suite
cmd="$(perl -ne 'print "$1\n" if /^\s*(\S.*?)\s+#\s*test suite/' README.md | head -1)"

if [ -z "$cmd" ]; then
  echo "ℹ️  The README does not declare a test command yet."
  echo "   When the project has a suite, write it in the «Usage» block."
  exit 0
fi

# Unfilled: the start has not chosen a stack yet. Not a failure, but not a ✅ either.
case "$cmd" in
  *'['*']'*)
    echo "ℹ️  The test command is still unfilled in the README ($cmd)."
    echo "   Nothing to run yet — but this does NOT mean the project passes."
    exit 0
    ;;
esac

# The command comes from a file in the repo and in CI it runs on PR events. This
# allowlist is a SPEED BUMP, not a barrier: it reduces obvious abuse and accidents,
# but a legitimate runner also executes repo code (npm test runs whatever
# package.json says). The real containment is the `pull_request` token: read-only
# and without secrets. Rules:
#   - `VAR=value` prefixes are ignored for classification (RAILS_ENV=test bin/rails
#     test is a normal test command) but they run with the command.
#   - A COMPOUND command (;, &&, ||, |, `, $( ) is not classified: it is skipped
#     with a warning — the allowed prefix says nothing about the rest of the line.
#   - An unknown runner does not fail the check, but it says so (explicit fail-open).
no_env="$cmd"
while [[ "$no_env" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]* ]]; do
  no_env="${no_env#"${BASH_REMATCH[0]}"}"
  no_env="${no_env#"${no_env%%[![:space:]]*}"}"
done

case "$cmd" in
  *';'*|*'&&'*|*'||'*|*'|'*|*'`'*|*'$('*)
    echo "⚠️  The README test command is compound: «${cmd}»."
    echo "   For safety only a simple runner is executed (this command runs in CI on"
    echo "   third-party PRs). Declare the single suite command; everything else"
    echo "   (lint, build) has its own step."
    exit 0 ;;
esac

case "$no_env" in
  npm\ *|pnpm\ *|yarn\ *|bun\ *|npx\ *|node\ *|deno\ *|\
  bundle\ *|bin/rails\ *|rails\ *|rake|rake\ *|\
  pytest|pytest\ *|python\ *|python3\ *|uv\ *|\
  go\ *|cargo\ *|make|make\ *|mix\ *|dotnet\ *|\
  flutter\ *|dart\ *|gradle\ *|./gradlew\ *|mvn\ *|composer\ *|php\ *|swift\ *)
    : ;;
  *)
    # ${cmd} with braces: macOS bash 3.2 mis-parses «$cmd» (it eats the first byte
    # of the «»» as if it were part of the variable name).
    echo "⚠️  Unrecognized test command: «${cmd}»."
    echo "   Only known runners are executed (npm, pytest, go test, make…): this"
    echo "   command comes from the README and in CI it runs on third-party PRs. If it"
    echo "   is legitimate, add its prefix to this script's allowlist."
    exit 0 ;;
esac

# The command is already chosen but the project has not been generated yet: between
# the documentation PR and the scaffolding one, the README declares commands nobody can
# run yet. That is not a red suite, it is a suite that does not exist — and confusing
# the two blocks the first PR of any start.
# Only commands that CANNOT work without their manifest count: a package manager
# looking for a declared script. A direct interpreter (`python3 -c …`, `node …`) does
# run without a project, so it is not included here — if it fails, it really fails.
missing_manifest=""
case "$no_env" in
  npm\ *|pnpm\ *|yarn\ *|bun\ *)
    [ -f package.json ] || missing_manifest="package.json" ;;
  bundle\ *|bin/rails\ *|rails\ *|rake|rake\ *)
    [ -f Gemfile ] || missing_manifest="Gemfile" ;;
  go\ *) [ -f go.mod ] || missing_manifest="go.mod" ;;
  cargo\ *) [ -f Cargo.toml ] || missing_manifest="Cargo.toml" ;;
  mix\ *) [ -f mix.exs ] || missing_manifest="mix.exs" ;;
esac

if [ -n "$missing_manifest" ]; then
  echo "ℹ️  The test command is already chosen («${cmd}») but there is no ${missing_manifest}:"
  echo "   the project has not been generated yet. Nothing to run — but this does NOT"
  echo "   mean the project passes."
  exit 0
fi

echo "▶ Project tests: $cmd"
if eval "$cmd"; then
  echo "✅ Project tests: passing."
  exit 0
fi
echo "❌ The project tests fail."
echo "→ Fix them before opening the PR. This check is the only one that looks at your"
echo "  code: the other suite tests the template and would stay green regardless."
exit 1
