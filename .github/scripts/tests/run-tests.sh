#!/usr/bin/env bash
# run-tests.sh — tests for the template's scripts and git hooks.
# They run in CI (quality.yml workflow) and locally with:
#   bash .github/scripts/tests/run-tests.sh
#
# Requires: git, perl. Exits with 1 if any test fails.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PRE_COMMIT="$REPO_ROOT/.githooks/pre-commit"
PRE_PUSH="$REPO_ROOT/.githooks/pre-push"
CHECK_PLACEHOLDERS="$REPO_ROOT/.github/scripts/check-placeholders.sh"
CHECK_LINKS="$REPO_ROOT/.github/scripts/check-links.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

# check <description> <expected-exit> <actual-exit>
check() {
  if [ "$2" -eq "$3" ]; then
    echo "  ✅ $1"
    pass=$((pass + 1))
  else
    echo "  ❌ $1 (expected exit=$2, got exit=$3)"
    fail=$((fail + 1))
  fi
}

# Scratch git repos: one on main, one on a feature branch.
git -C "$TMP" init -q -b main repo-main
git -C "$TMP" init -q -b feat/x repo-feat

# ── .githooks/pre-commit (protected branches) ─────────────────────────────────
if [ -f "$PRE_COMMIT" ]; then
  echo "pre-commit (protected branches):"
  run_pre_commit() { (cd "$1" && bash "$PRE_COMMIT" 2>/dev/null); }

  run_pre_commit "$TMP/repo-main"; check "commit on main → blocks" 1 $?
  run_pre_commit "$TMP/repo-feat"; check "commit on feat branch → allows" 0 $?
fi

# ── .githooks/pre-commit (staged secrets) ─────────────────────────────────────
if [ -f "$PRE_COMMIT" ] && grep -q 'diff --cached' "$PRE_COMMIT"; then
  echo "pre-commit (staged secrets):"
  # Stages a file in the feature repo, runs the hook, then unstages it.
  stage_and_run() {
    local rc
    (cd "$TMP/repo-feat" \
      && mkdir -p "$(dirname "$1")" && printf 'x\n' >"$1" && git add -f "$1" \
      && bash "$PRE_COMMIT" 2>/dev/null)
    rc=$?
    (cd "$TMP/repo-feat" && git rm -q --cached -f "$1" >/dev/null 2>&1; rm -f "$1")
    return "$rc"
  }

  stage_and_run ".env"; check "staged .env → blocks" 1 $?
  stage_and_run ".env.local"; check "staged .env.local → blocks" 1 $?
  stage_and_run ".env.example"; check "staged .env.example → allows" 0 $?
  stage_and_run "certs/server.pem"; check "staged *.pem → blocks" 1 $?
  stage_and_run "keys/deploy.key"; check "staged *.key → blocks" 1 $?
  stage_and_run "id_rsa"; check "staged id_rsa → blocks" 1 $?
  stage_and_run "README.md"; check "staged README.md → allows" 0 $?
fi

# ── .githooks/pre-push ────────────────────────────────────────────────────────
if [ -f "$PRE_PUSH" ]; then
  echo "pre-push:"
  # stdin contract: <local ref> <local sha> <remote ref> <remote sha>
  run_pre_push() { printf '%s\n' "$1" | bash "$PRE_PUSH" origin git@example:x.git 2>/dev/null; }

  run_pre_push "refs/heads/main aaa refs/heads/main bbb"; check "push to main → blocks" 1 $?
  run_pre_push "refs/heads/develop aaa refs/heads/develop bbb"; check "push to develop → blocks" 1 $?
  run_pre_push "refs/heads/feat/x aaa refs/heads/feat/x bbb"; check "push to feat branch → allows" 0 $?
  printf '' | bash "$PRE_PUSH" origin git@example:x.git 2>/dev/null; check "empty push → allows" 0 $?
fi

# ── check-placeholders.sh ─────────────────────────────────────────────────────
echo "check-placeholders.sh:"
make_repo() { # $1 = name; creates a git repo at $TMP/$1
  mkdir -p "$TMP/$1" && git -C "$TMP/$1" init -q -b main
}
commit_all() { git -C "$1" add -A && git -C "$1" -c user.email=t@t -c user.name=t commit -qm t; }

# Template mode: catalogued placeholder → passes.
make_repo tpl-ok
printf '| `[PROJECT_NAME]` | name |\n' >"$TMP/tpl-ok/TEMPLATE-USAGE.md"
printf '# [PROJECT_NAME]\n' >"$TMP/tpl-ok/README.md"
commit_all "$TMP/tpl-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-ok" >/dev/null); check "template: catalogued → passes" 0 $?

# Template mode: uncatalogued placeholder → fails.
make_repo tpl-bad
printf '| `[PROJECT_NAME]` | name |\n' >"$TMP/tpl-bad/TEMPLATE-USAGE.md"
printf '# [NOT_CATALOGUED]\n' >"$TMP/tpl-bad/README.md"
commit_all "$TMP/tpl-bad"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-bad" >/dev/null); check "template: uncatalogued → fails" 1 $?

# Template mode: suffix wildcard `[*_COMMAND]` covers TEST_COMMAND → passes.
make_repo tpl-wild
printf '| `[*_COMMAND]` | commands |\n' >"$TMP/tpl-wild/TEMPLATE-USAGE.md"
printf 'Run [TEST_COMMAND]\n' >"$TMP/tpl-wild/README.md"
commit_all "$TMP/tpl-wild"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-wild" >/dev/null); check "template: suffix wildcard covers → passes" 0 $?

# Template mode: prefix wildcard `[LINK_*]` covers LINK_DOCS → passes.
make_repo tpl-wild2
printf '| `[LINK_*]` | links |\n' >"$TMP/tpl-wild2/TEMPLATE-USAGE.md"
printf 'See [LINK_DOCS]\n' >"$TMP/tpl-wild2/README.md"
commit_all "$TMP/tpl-wild2"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-wild2" >/dev/null); check "template: prefix wildcard covers → passes" 0 $?

# Instance mode: a placeholder remains → fails.
make_repo inst-bad
printf '# My project\nMissing [TEST_COMMAND]\n' >"$TMP/inst-bad/README.md"
commit_all "$TMP/inst-bad"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-bad" >/dev/null); check "instance: leftover placeholder → fails" 1 $?

# Instance mode: clean (markdown links [X](y) don't count) → passes.
make_repo inst-ok
printf '# My project\nSee [MIT](LICENSE).\n' >"$TMP/inst-ok/README.md"
commit_all "$TMP/inst-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-ok" >/dev/null); check "instance: clean → passes" 0 $?

# ── check-links.sh ────────────────────────────────────────────────────────────
echo "check-links.sh:"
make_repo links-ok
printf 'See [docs](docs/guide.md) and [web](https://example.com) and [anchor](#usage).\n' >"$TMP/links-ok/README.md"
mkdir -p "$TMP/links-ok/docs" && printf 'hello\n' >"$TMP/links-ok/docs/guide.md"
commit_all "$TMP/links-ok"
(bash "$CHECK_LINKS" "$TMP/links-ok" >/dev/null); check "valid links → passes" 0 $?

make_repo links-bad
printf 'See [docs](docs/does-not-exist.md).\n' >"$TMP/links-bad/README.md"
commit_all "$TMP/links-bad"
(bash "$CHECK_LINKS" "$TMP/links-bad" >/dev/null); check "broken link → fails" 1 $?

# ── .github/workflows/ structure ──────────────────────────────────────────────
# GitHub runs ANY .yml/.yaml in that folder, regardless of the rest of the name:
# a `ci.example.yml` actually runs, and passes green without testing anything.
# Whatever must not run cannot end in .yml/.yaml.
WORKFLOWS="$REPO_ROOT/.github/workflows"
if [ -d "$WORKFLOWS" ]; then
  echo ".github/workflows structure:"
  runnable_examples="$(ls "$WORKFLOWS" | grep -Ei '(example|sample|template)\.ya?ml$' || true)"
  [ -z "$runnable_examples" ]
  check "no example workflow ends in .yml/.yaml" 0 $?
  [ -n "$runnable_examples" ] && printf '     · %s\n' $runnable_examples
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "Result: $pass OK, $fail failed."
[ "$fail" -eq 0 ] || exit 1
