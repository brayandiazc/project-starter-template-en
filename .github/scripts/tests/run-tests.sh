#!/usr/bin/env bash
# run-tests.sh — tests for the template's scripts and hooks.
# They run in CI (quality.yml workflow) and locally with:
#   bash .github/scripts/tests/run-tests.sh
#
# Requires: git, perl, python3. Exits 1 if any test fails.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHECK_PLACEHOLDERS="$REPO_ROOT/.github/scripts/check-placeholders.sh"
CHECK_LINKS="$REPO_ROOT/.github/scripts/check-links.sh"
CHECK_CHANGELOG="$REPO_ROOT/.github/scripts/check-changelog.sh"
CHECK_RELEASE="$REPO_ROOT/.github/scripts/check-release.sh"
CHECK_INSTRUCTIONS="$REPO_ROOT/.github/scripts/check-instructions.sh"
CHECK_HOOKS="$REPO_ROOT/.github/scripts/check-hooks-enabled.sh"

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

# ── check-placeholders.sh ─────────────────────────────────────────────────────
echo "check-placeholders.sh:"
make_repo() { # $1 = name; creates a git repo at $TMP/$1
  mkdir -p "$TMP/$1" && git -C "$TMP/$1" init -q -b main
}
commit_all() { git -C "$1" add -A && git -C "$1" -c user.email=t@t -c user.name=t commit -qm t; }

# Template mode: cataloged placeholder → passes.
make_repo tpl-ok
printf '| `[PROJECT_NAME]` | name |\n' >"$TMP/tpl-ok/TEMPLATE-USAGE.md"
printf '# [PROJECT_NAME]\n' >"$TMP/tpl-ok/README.md"
commit_all "$TMP/tpl-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-ok" >/dev/null); check "template: cataloged → passes" 0 $?

# Template mode: uncataloged placeholder → fails.
make_repo tpl-bad
printf '| `[PROJECT_NAME]` | name |\n' >"$TMP/tpl-bad/TEMPLATE-USAGE.md"
printf '# [UNCATALOGED]\n' >"$TMP/tpl-bad/README.md"
commit_all "$TMP/tpl-bad"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-bad" >/dev/null); check "template: uncataloged → fails" 1 $?

# Template mode: the `[COMMAND_*]` wildcard covers COMMAND_TEST → passes.
make_repo tpl-wild
printf '| `[COMMAND_*]` | commands |\n' >"$TMP/tpl-wild/TEMPLATE-USAGE.md"
printf 'Run [COMMAND_TEST]\n' >"$TMP/tpl-wild/README.md"
commit_all "$TMP/tpl-wild"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-wild" >/dev/null); check "template: wildcard covers it → passes" 0 $?

# Instance mode: a placeholder is left → fails.
make_repo inst-bad
printf '# My project\nMissing [TEST_COMMAND]\n' >"$TMP/inst-bad/README.md"
commit_all "$TMP/inst-bad"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-bad" >/dev/null); check "instance: pending placeholder → fails" 1 $?

# Instance mode: clean (markdown links [X](y) do not count) → passes.
make_repo inst-ok
printf '# My project\nSee [MIT](LICENSE).\n' >"$TMP/inst-ok/README.md"
commit_all "$TMP/inst-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-ok" >/dev/null); check "instance: clean → passes" 0 $?

# Instance mode: placeholder MARKED as pending → passes.
# /instantiate says "do not invent data, leave the placeholder"; without this exception
# that rule and this check contradict each other and every project's first PR goes red.
make_repo inst-pend
printf '# My project\nContact: [SUPPORT_EMAIL] <!-- pending: no mailbox yet -->\n' >"$TMP/inst-pend/README.md"
commit_all "$TMP/inst-pend"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-pend" >/dev/null); check "instance: marked pending → passes" 0 $?

# …but it is listed, so it does not become permanent out of inertia.
output="$(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-pend" 2>&1 || true)"
printf '%s' "$output" | grep -q "SUPPORT_EMAIL"
check "instance: the pending one is reported" 0 $?

# The mark is per line: another unmarked placeholder in the same file still fails.
make_repo inst-mix
printf '# My project\nContact: [SUPPORT_EMAIL] <!-- pending -->\nRun [TEST_COMMAND]\n' >"$TMP/inst-mix/README.md"
commit_all "$TMP/inst-mix"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-mix" >/dev/null); check "instance: mark per line, not per file → fails" 1 $?

# The mark also works in bash comment syntax: [COMMAND_*] placeholders live in ```bash
# fences and in .env.example, where an HTML comment would show up literally.
make_repo inst-bash
printf '# My project\n\n```bash\n[TEST_COMMAND]   # pending: scaffolding missing\n```\n' >"$TMP/inst-bash/README.md"
commit_all "$TMP/inst-bash"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-bash" >/dev/null); check "instance: '# pending' mark in bash → passes" 0 $?

# The CHANGELOG is history, not a form: mentioning a placeholder is not having one.
make_repo inst-chlog
printf '# My project\nAll good.\n' >"$TMP/inst-chlog/README.md"
printf '# Changelog\n\n- The block with [DATABASE] and [PROVIDER] is removed.\n' >"$TMP/inst-chlog/CHANGELOG.md"
commit_all "$TMP/inst-chlog"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-chlog" >/dev/null); check "instance: CHANGELOG does not count → passes" 0 $?

# The mark also counts on the FOLLOWING line: Prettier splits lines inside ```html
# fences and leaves the comment below. Demanding the same line meant marking it
# properly and committing broke the check (kickoff test 2, friction 7).
make_repo inst-nextline
printf '# My project\n\n```html\n<meta content="[OG_IMAGE_URL]" />\n<!-- pending: image missing -->\n```\n' >"$TMP/inst-nextline/README.md"
commit_all "$TMP/inst-nextline"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-nextline" >/dev/null); check "instance: mark on the following line → passes" 0 $?

# But only if the comment OPENS the line: otherwise a foreign marker would excuse the
# placeholder above it by simple proximity.
make_repo inst-nextline-no
printf '# My project\n\n[DEV_URL]\ntext [PRODUCTION_URL] <!-- pending: no domain -->\n' >"$TMP/inst-nextline-no/README.md"
commit_all "$TMP/inst-nextline-no"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-nextline-no" >/dev/null); check "instance: a foreign mark does not excuse its neighbor → fails" 1 $?

# A file git tracks but that is no longer on disk (pruned with 'rm' instead of
# 'git rm') cannot be checked — and it used to be skipped silently, with a green
# summary and a raw perl error on stderr (friction 3).
make_repo inst-missing
printf '# My project\nAll good.\n' >"$TMP/inst-missing/README.md"
printf 'With [PROJECT_NAME].\n' >"$TMP/inst-missing/OTHER.md"
commit_all "$TMP/inst-missing"
rm "$TMP/inst-missing/OTHER.md"
output="$(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-missing" 2>&1)"; ec=$?
check "instance: a tracked but missing file does not break it → passes" 0 $ec
# What really changed: the exit was already 0 before, but perl spat its raw error and
# the file went unchecked. The exit code alone does not tell the fix apart.
printf '%s' "$output" | grep -qi "can't open"; check "instance: no raw perl error" 1 $?

# PROJECT-level pending items: data missing everywhere is declared once in `.pending`
# instead of with dozens of comments — which in files published as product pages would
# end up inside the product's terms (kickoff test 2, friction 8).
make_repo inst-globals
printf '# My project\n\nContact: [SUPPORT_EMAIL]\n' >"$TMP/inst-globals/README.md"
printf 'Write to [SUPPORT_EMAIL].\n' >"$TMP/inst-globals/SECURITY.md"
printf 'SUPPORT_EMAIL=the client has not given the mailbox yet\n' >"$TMP/inst-globals/.pending"
commit_all "$TMP/inst-globals"
output="$(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-globals" 2>&1)"; ec=$?
check "instance: pending declared in .pending → passes" 0 $ec
printf '%s' "$output" | grep -q "Project-level pending"; check "instance: globals are listed apart" 0 $?

# Without the file, the same placeholders still fail: declaring is an explicit act.
make_repo inst-globals-no
printf '# My project\n\nContact: [SUPPORT_EMAIL]\n' >"$TMP/inst-globals-no/README.md"
commit_all "$TMP/inst-globals-no"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-globals-no" >/dev/null 2>&1); check "instance: without .pending → fails anyway" 1 $?

# And declaring one does not cover its neighbor on the same line.
make_repo inst-globals-neighbor
printf '# My project\n\n[SUPPORT_EMAIL] and [PRODUCTION_URL]\n' >"$TMP/inst-globals-neighbor/README.md"
printf 'SUPPORT_EMAIL=no mailbox\n' >"$TMP/inst-globals-neighbor/.pending"
commit_all "$TMP/inst-globals-neighbor"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-globals-neighbor" >/dev/null 2>&1); check "instance: a global does not cover its line neighbor" 1 $?

# Files that EXIST but git does not track yet: that is the exact state when adopting
# the template in an existing project — they are copied and not committed yet. They
# used to be invisible and the check answered "none left" (adoption test, friction 3).
make_repo inst-untracked
printf '# My project\nAll good.\n' >"$TMP/inst-untracked/README.md"
commit_all "$TMP/inst-untracked"
printf 'Just copied with [PROJECT_NAME].\n' >"$TMP/inst-untracked/NEW.md"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-untracked" >/dev/null 2>&1); check "instance: an untracked file is checked too → fails" 1 $?

# But what .gitignore ignores stays out: --exclude-standard honors it.
make_repo inst-ignored
printf '# My project\nAll good.\n' >"$TMP/inst-ignored/README.md"
printf 'draft/\n' >"$TMP/inst-ignored/.gitignore"
commit_all "$TMP/inst-ignored"
mkdir -p "$TMP/inst-ignored/draft"
printf 'With [PROJECT_NAME].\n' >"$TMP/inst-ignored/draft/notes.md"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-ignored" >/dev/null 2>&1); check "instance: what .gitignore ignores does not count → passes" 0 $?

# PROSE gaps: they do not follow the [UPPERCASE] convention and so nobody saw them —
# a roadmap left entirely unfilled passed green (cycle test, friction 2).
make_repo inst-prose
printf '# My project\n\n## v0.1 — [NAME / GOAL]\n\n[A paragraph describing the north star.]\n' >"$TMP/inst-prose/README.md"
commit_all "$TMP/inst-prose"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-prose" >/dev/null 2>&1); check "instance: prose gap → fails" 1 $?

# The same pending mark works for them.
make_repo inst-prose-marked
printf '# My project\n\n[A paragraph describing the north star.] <!-- pending: vision not closed -->\n' >"$TMP/inst-prose-marked/README.md"
commit_all "$TMP/inst-prose-marked"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-prose-marked" >/dev/null 2>&1); check "instance: marked prose gap → passes" 0 $?

# The four exclusions, one test each: if any of them fails, the check becomes noise
# nobody looks at, which is worse than not having it.
make_repo inst-prose-false
{
  printf '# My project\n\n'
  printf 'A [normal link](https://example.com) is not a gap.\n\n'
  printf -- '- [ ] a pending task\n- [x] a done task\n\n'
  printf '> [!NOTE]\n> A GitHub admonition.\n\n'
  printf 'The `[data-theme="dark"]` selector goes between backticks.\n\n'
  printf 'The changelog [Unreleased] section is syntax, not a gap.\n'
} >"$TMP/inst-prose-false/README.md"
commit_all "$TMP/inst-prose-false"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-prose-false" >/dev/null 2>&1); check "instance: links, tasks, admonitions, code and changelog do not count" 0 $?

# Fenced code blocks are not prose: Mermaid nodes use brackets by right
# (A["Host"], Start([Entry])) and the template recommends Mermaid in architecture.md,
# database.md and screens.md — without the exclusion the clash was guaranteed in every
# instance (friction 3 of a real start).
make_repo inst-prose-mermaid
{
  printf '# Architecture\n\n'
  printf '```mermaid\nflowchart LR\n'
  printf '  A["Host — Chrome/Edge<br/>React + Vite"] --> B(Worker)\n'
  printf '  Start([Entry]) --> A\n'
  printf '```\n'
} >"$TMP/inst-prose-mermaid/README.md"
commit_all "$TMP/inst-prose-mermaid"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-prose-mermaid" >/dev/null 2>&1); check "instance: Mermaid brackets inside a fence → passes" 0 $?

# But the fence amnesties nothing outside it nor the [UPPERCASE] ones inside: a prose
# gap after the diagram still fails, and a [TEST_COMMAND] in a ```bash block is still
# a value to substitute.
make_repo inst-prose-after-fence
{
  printf '# Architecture\n\n'
  printf '```mermaid\nflowchart LR\n  A["Host"] --> B(Worker)\n```\n\n'
  printf '[A paragraph describing the deployment.]\n'
} >"$TMP/inst-prose-after-fence/README.md"
commit_all "$TMP/inst-prose-after-fence"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-prose-after-fence" >/dev/null 2>&1); check "instance: prose gap after the fence → fails" 1 $?

make_repo inst-fence-uppercase
printf '# Setup\n\n```bash\n[TEST_COMMAND]\n```\n' >"$TMP/inst-fence-uppercase/README.md"
commit_all "$TMP/inst-fence-uppercase"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-fence-uppercase" >/dev/null 2>&1); check "instance: [UPPERCASE] inside a fence → still fails" 1 $?

# In TEMPLATE mode prose gaps are legitimate: the skeleton is made of them.
make_repo tpl-prose
printf '# Template\n\nCatalog: nothing.\n' >"$TMP/tpl-prose/TEMPLATE-USAGE.md"
printf '# My project\n\n[A paragraph describing the north star.]\n' >"$TMP/tpl-prose/README.md"
commit_all "$TMP/tpl-prose"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-prose" >/dev/null 2>&1); check "template: prose gaps are not demanded" 0 $?

# --mark: adopting the check in an existing project would turn 160 gaps red at once.
# It marks them in one pass, saying they are unreviewed.
make_repo inst-mark
printf '# My project\n\n[A paragraph describing the north star.]\n\n[Another unwritten gap.]\n' >"$TMP/inst-mark/README.md"
commit_all "$TMP/inst-mark"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-mark" >/dev/null 2>&1); check "mark: before marking, it fails" 1 $?
bash "$CHECK_PLACEHOLDERS" --mark "$TMP/inst-mark" >/dev/null 2>&1
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-mark" >/dev/null 2>&1); check "mark: after marking, it passes" 0 $?
grep -q "unreviewed" "$TMP/inst-mark/README.md"; check "mark: the mark says it is unreviewed" 0 $?
grep -c "pending:" "$TMP/inst-mark/README.md" | grep -q "^2$"; check "mark: it marks every gap, not just the first" 0 $?

# [UPPERCASE] placeholders are NOT marked in bulk: they are values to substitute, and
# marking them would be hiding them.
make_repo inst-mark-prose-only
printf '# My project\n\nContact: [SUPPORT_EMAIL]\n' >"$TMP/inst-mark-prose-only/README.md"
commit_all "$TMP/inst-mark-prose-only"
bash "$CHECK_PLACEHOLDERS" --mark "$TMP/inst-mark-prose-only" >/dev/null 2>&1
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-mark-prose-only" >/dev/null 2>&1); check "mark: it does not touch [UPPERCASE] placeholders" 1 $?

# .github/ is no longer skipped whole: the [REPOSITORY_URL] in config.yml stayed a
# broken link forever in every instance's GitHub UI.
make_repo inst-github
mkdir -p "$TMP/inst-github/.github/ISSUE_TEMPLATE"
printf '# Project ready\n' >"$TMP/inst-github/README.md"
printf 'contact_links:\n  - url: [REPOSITORY_URL]/discussions\n' \
  >"$TMP/inst-github/.github/ISSUE_TEMPLATE/config.yml"
commit_all "$TMP/inst-github"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-github" >/dev/null 2>&1); check "instance: [REPOSITORY_URL] in config.yml → fails" 1 $?

# …but the title prefixes ([BUG]) and the prose gaps in the issue forms
# ([e.g. iPhone 13]) survive by design: a clean instance = green.
make_repo inst-github-ok
mkdir -p "$TMP/inst-github-ok/.github/ISSUE_TEMPLATE"
printf '# Project ready\n' >"$TMP/inst-github-ok/README.md"
printf -- '---\ntitle: "[BUG] "\n---\n\n- Device: [e.g. iPhone 13, Samsung Galaxy S22]\n' \
  >"$TMP/inst-github-ok/.github/ISSUE_TEMPLATE/bug_report.md"
commit_all "$TMP/inst-github-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-github-ok" >/dev/null 2>&1); check "instance: [BUG] and ISSUE_TEMPLATE prose → passes" 0 $?
# And the summary does not count them as "pending" (a permanent false count).
output_gh="$(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-github-ok" 2>&1 || true)"
printf '%s' "$output_gh" | grep -q "none left"; check "instance: the summary does not list [BUG] as pending" 0 $?

# --fillable-paths: the scope of /instantiate's fill pass. The global pass corrupted
# THIS bench's fixtures and filled in the internal templates under specs/ and docs/,
# which exist to keep their placeholders — the second part got collected weeks later,
# when spec-guardrails accused of "unfilled" the line that WAS filled. The list already
# existed (SKIP); all that was missing was being able to ask for it.
make_repo paths
mkdir -p "$TMP/paths/.github/scripts/tests" "$TMP/paths/.github/workflows" \
  "$TMP/paths/.github/ISSUE_TEMPLATE" "$TMP/paths/docs/decisions" \
  "$TMP/paths/docs/conventions"
printf '# [PROJECT_NAME]\n'            >"$TMP/paths/README.md"
printf 'url: [REPOSITORY_URL]\n'       >"$TMP/paths/.github/ISSUE_TEMPLATE/config.yml"
printf '# touched: [PORT]\n'           >"$TMP/paths/.env.example"
printf '# fixture with [DATE]\n'       >"$TMP/paths/.github/scripts/tests/run-tests.sh"
printf '# comment with [DATE]\n'       >"$TMP/paths/.github/workflows/release.yml"
printf '# ADR [NNNN] — [TITLE]\n'      >"$TMP/paths/docs/decisions/0000-template.md"
printf '# [TOPIC]\n'                   >"$TMP/paths/docs/conventions/_template.md"
printf '## [1.0.0] - 2026-01-01\n'     >"$TMP/paths/CHANGELOG.md"
commit_all "$TMP/paths"
paths="$(bash "$CHECK_PLACEHOLDERS" --fillable-paths "$TMP/paths")"

# What IS substituted. config.yml is included even though it lives in .github/: those
# are the contact links GitHub shows under "New issue", and skipping them left them
# broken forever.
printf '%s\n' "$paths" | grep -qx 'README.md'; check "paths: documentation is included" 0 $?
printf '%s\n' "$paths" | grep -qx '.env.example'; check "paths: .env.example is included" 0 $?
printf '%s\n' "$paths" | grep -qx '.github/ISSUE_TEMPLATE/config.yml'; check "paths: config.yml is included despite living in .github/" 0 $?

# What is NOT: in a script a placeholder is a fixture or explanatory text; in an
# internal template it is the only thing that makes it useful.
for exempt in \
  '.github/scripts/tests/run-tests.sh' \
  '.github/workflows/release.yml' \
  'docs/decisions/0000-template.md' \
  'docs/conventions/_template.md' \
  'CHANGELOG.md'; do
  printf '%s\n' "$paths" | grep -qx "$exempt"
  check "paths: $exempt stays out" 1 $?
done

# The regression that really matters: substituting over the listed paths leaves this
# very test bench's fixtures intact.
printf '%s\n' "$paths" | tr '\n' '\0' | (cd "$TMP/paths" && xargs -0 perl -pi -e 's/\[DATE\]/2026-09-01/g')
grep -q '\[DATE\]' "$TMP/paths/.github/scripts/tests/run-tests.sh"
check "paths: after the pass, the bench fixture is untouched" 0 $?

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

# A document that QUOTES markdown or a regex between backticks links to nothing.
make_repo links-inline
printf 'The regex `(?!\\()` and the example `[text](target.md)` go between backticks.\n' >"$TMP/links-inline/README.md"
commit_all "$TMP/links-inline"
(bash "$CHECK_LINKS" "$TMP/links-inline" >/dev/null 2>&1); check "links: inline code does not count as a link" 0 $?

# Neither does what goes inside a code fence.
make_repo links-fence
printf '# Doc\n\n```perl\n/\\](?!\\()/\n```\n\nSee [for real](README.md).\n' >"$TMP/links-fence/README.md"
commit_all "$TMP/links-fence"
(bash "$CHECK_LINKS" "$TMP/links-fence" >/dev/null 2>&1); check "links: fenced code does not count as a link" 0 $?

make_repo links-untracked
printf 'ok\n' >"$TMP/links-untracked/README.md"
commit_all "$TMP/links-untracked"
printf 'See [guide](docs/does-not-exist.md).\n' >"$TMP/links-untracked/NEW.md"
(bash "$CHECK_LINKS" "$TMP/links-untracked" >/dev/null 2>&1); check "links: an untracked file is checked too → fails" 1 $?

# A tracked file deleted from disk: it is counted and reported, not skipped silently
# while perl spits its error and the summary says all is well.
make_repo links-missing
printf 'See [docs](docs/guide.md).\n' >"$TMP/links-missing/README.md"
mkdir -p "$TMP/links-missing/docs" && printf 'hello\n' >"$TMP/links-missing/docs/guide.md"
printf 'Another file.\n' >"$TMP/links-missing/OTHER.md"
commit_all "$TMP/links-missing"
rm "$TMP/links-missing/OTHER.md"
output="$(bash "$CHECK_LINKS" "$TMP/links-missing" 2>&1)"; ec=$?
check "links: a missing file does not break it → passes" 0 $ec
printf '%s' "$output" | grep -q "not checked"; check "links: the missing one is reported" 0 $?
printf '%s' "$output" | grep -qi "can't open"; check "links: no raw perl error" 1 $?

# ── check-changelog.sh ────────────────────────────────────────────────────────
if [ -f "$CHECK_CHANGELOG" ]; then
  echo "check-changelog.sh:"

  # Repo with a CHANGELOG published on main and a work branch on top.
  changelog_repo() { # $1 = name
    make_repo "$1"
    printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n### Fixed\n\n## [0.1.0] - 2026-01-01\n\n### Added\n\n- First version.\n' \
      >"$TMP/$1/CHANGELOG.md"
    printf 'content\n' >"$TMP/$1/README.md"
    commit_all "$TMP/$1"
    git -C "$TMP/$1" checkout -q -b feat/x
  }
  # Rewrites the CHANGELOG with the given entries under Unreleased.
  set_unreleased() { # $1 = repo, $2 = Unreleased body
    printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n%s\n\n## [0.1.0] - 2026-01-01\n\n### Added\n\n- First version.\n' \
      "$2" >"$TMP/$1/CHANGELOG.md"
  }
  run_changelog() { (bash "$CHECK_CHANGELOG" main "$TMP/$1" >/dev/null 2>&1); }

  # A code change without touching the CHANGELOG.
  changelog_repo cl-missing
  printf 'puts 1\n' >"$TMP/cl-missing/app.rb"
  commit_all "$TMP/cl-missing"
  run_changelog cl-missing; check "code with no entry → fails" 1 $?

  # A code change with its entry under Unreleased.
  changelog_repo cl-ok
  printf 'puts 1\n' >"$TMP/cl-ok/app.rb"
  set_unreleased cl-ok '- You can sign in with Google.'
  commit_all "$TMP/cl-ok"
  run_changelog cl-ok; check "code with an entry → passes" 0 $?

  # CHANGELOG touched but Unreleased still empty (e.g. only a link was moved).
  changelog_repo cl-empty
  printf 'puts 1\n' >"$TMP/cl-empty/app.rb"
  printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n## [0.1.0] - 2026-01-01\n\n### Added\n\n- First version (reworded).\n' \
    >"$TMP/cl-empty/CHANGELOG.md"
  commit_all "$TMP/cl-empty"
  run_changelog cl-empty; check "CHANGELOG touched with an empty Unreleased → fails" 1 $?

  # A PR that only touches the CHANGELOG itself (e.g. rewording an old entry).
  changelog_repo cl-only
  set_unreleased cl-only '- An old entry gets reworded.'
  commit_all "$TMP/cl-only"
  run_changelog cl-only; check "PR only touching the CHANGELOG → passes (exempt)" 0 $?

  # Explicit exception by label.
  changelog_repo cl-label
  printf 'puts 1\n' >"$TMP/cl-label/app.rb"
  commit_all "$TMP/cl-label"
  (PR_LABELS="documentation,no-changelog" bash "$CHECK_CHANGELOG" main "$TMP/cl-label" >/dev/null 2>&1)
  check "no-changelog label → passes" 0 $?

  # Version cut: Unreleased is left empty on purpose.
  changelog_repo cl-release
  printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n## [0.2.0] - 2026-02-01\n\n### Added\n\n- You can sign in with Google.\n\n## [0.1.0] - 2026-01-01\n\n### Added\n\n- First version.\n' \
    >"$TMP/cl-release/CHANGELOG.md"
  printf 'v2\n' >"$TMP/cl-release/VERSION"
  commit_all "$TMP/cl-release"
  run_changelog cl-release; check "version cut → passes" 0 $?

  # Unresolvable base: fails open so a weird ref does not block CI.
  changelog_repo cl-nobase
  printf 'puts 1\n' >"$TMP/cl-nobase/app.rb"
  commit_all "$TMP/cl-nobase"
  (bash "$CHECK_CHANGELOG" does-not-exist "$TMP/cl-nobase" >/dev/null 2>&1)
  check "unresolvable base → allows" 0 $?

  # Repo with no CHANGELOG.md: nothing is imposed.
  make_repo cl-none
  printf 'hello\n' >"$TMP/cl-none/README.md"
  commit_all "$TMP/cl-none"
  git -C "$TMP/cl-none" checkout -q -b feat/x
  printf 'puts 1\n' >"$TMP/cl-none/app.rb"
  commit_all "$TMP/cl-none"
  run_changelog cl-none; check "repo with no CHANGELOG.md → allows" 0 $?
fi

# ── check-release.sh ──────────────────────────────────────────────────────────
if [ -f "$CHECK_RELEASE" ]; then
  echo "check-release.sh:"

  # $1 = name, $2 = CHANGELOG content, $3 = tag to create (or empty)
  release_repo() {
    make_repo "$1"
    printf '%s' "$2" >"$TMP/$1/CHANGELOG.md"
    commit_all "$TMP/$1"
    [ -n "${3:-}" ] && git -C "$TMP/$1" tag "$3"
    return 0
  }
  CUT='# Changelog\n\n## [Unreleased]\n\n### Added\n\n## [0.2.0] - 2026-02-01\n\n### Added\n\n- Login with Google.\n'
  run_release() { (bash "$CHECK_RELEASE" "$TMP/$1" >/dev/null 2>&1); }

  # A cut version with no tag yet: exactly what should be published.
  release_repo rl-ok "$(printf "$CUT")" ""
  run_release rl-ok; check "cut, unpublished version → passes" 0 $?

  # The topmost version already has a tag: this merge would publish nothing.
  release_repo rl-tagged "$(printf "$CUT")" "v0.2.0"
  run_release rl-tagged; check "already published version → fails" 1 $?

  # It was never cut: there is only Unreleased.
  release_repo rl-nocut "$(printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n- Something.\n')" ""
  run_release rl-nocut; check "no dated version → fails" 1 $?

  # Cut, but work was left outside the version.
  release_repo rl-leftover \
    "$(printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n- Left out of the cut.\n\n## [0.2.0] - 2026-02-01\n\n### Added\n\n- Login with Google.\n')" ""
  run_release rl-leftover; check "Unreleased with entries → fails" 1 $?

  # A placeholder with no real date (a freshly instantiated template) is not a version.
  release_repo rl-placeholder \
    "$(printf '# Changelog\n\n## [Unreleased]\n\n### Added\n\n## [0.1.0] - [DATE]\n\n- Start.\n')" ""
  run_release rl-placeholder; check "version with a placeholder date → fails" 1 $?

  # Repo with no CHANGELOG.md: nothing is imposed.
  make_repo rl-none
  printf 'hello\n' >"$TMP/rl-none/README.md"
  commit_all "$TMP/rl-none"
  run_release rl-none; check "repo with no CHANGELOG.md → allows" 0 $?
fi

# ── .githooks/pre-commit ──────────────────────────────────────────────────────
# It needs npx (Prettier). Without Node.js it is skipped: the hook skips itself too.
PRECOMMIT="$REPO_ROOT/.githooks/pre-commit"
if [ -f "$PRECOMMIT" ] && command -v npx > /dev/null 2>&1; then
  echo ".githooks/pre-commit:"

  hook_repo() { # $1 = name; repo with the hook enabled
    mkdir -p "$TMP/$1" && git -C "$TMP/$1" init -q -b main
    git -C "$TMP/$1" config core.hooksPath "$(dirname "$PRECOMMIT")"
  }
  hook_commit() { git -C "$TMP/$1" -c user.email=t@t -c user.name=t commit -qm t > /dev/null 2>&1; }

  # It formats what is staged and re-stages it: the commit lands already formatted.
  hook_repo hk-fmt
  printf '#  Hello   \n\n\n*  one\n' >"$TMP/hk-fmt/doc.md"
  git -C "$TMP/hk-fmt" add doc.md
  hook_commit hk-fmt
  [ "$(git -C "$TMP/hk-fmt" show HEAD:doc.md)" = "$(printf '# Hello\n\n- one')" ]
  check "formats the staged .md and re-stages it" 0 $?

  # A file with unstaged changes is not touched: we would pull into the commit work
  # that was deliberately left out.
  hook_repo hk-partial
  printf '# One\n' >"$TMP/hk-partial/other.md"
  git -C "$TMP/hk-partial" add other.md
  printf '# One\n\nnot  staged\n' >"$TMP/hk-partial/other.md"
  hook_commit hk-partial
  [ "$(git -C "$TMP/hk-partial" show HEAD:other.md)" = "# One" ]
  check "file with unstaged changes → untouched" 0 $?

  # Application code belongs to the stack's linter, not to Prettier.
  hook_repo hk-code
  printf 'puts    1\n' >"$TMP/hk-code/a.rb"
  git -C "$TMP/hk-code" add a.rb
  hook_commit hk-code
  [ "$(git -C "$TMP/hk-code" show HEAD:a.rb)" = "puts    1" ]
  check "stack code → Prettier does not touch it" 0 $?

  # Names with accents: git escapes them by default and the hook would lose them.
  hook_repo hk-accents
  printf '#  Documentación   \n\n\n*  one\n' >"$TMP/hk-accents/documentación.md"
  git -C "$TMP/hk-accents" add "documentación.md"
  hook_commit hk-accents
  [ "$(git -C "$TMP/hk-accents" show "HEAD:documentación.md")" = "$(printf '# Documentación\n\n- one')" ]
  check "name with accents → also formatted" 0 $?

  # It never blocks: not even with a file Prettier cannot parse.
  hook_repo hk-bad
  printf '{broken,,,\n' >"$TMP/hk-bad/bad.json"
  git -C "$TMP/hk-bad" add bad.json
  hook_commit hk-bad; check "invalid file → does not block the commit" 0 $?
fi

# ── check-design-tokens.sh ────────────────────────────────────────────────────
CHECK_DESIGN="$REPO_ROOT/.github/scripts/check-design-tokens.sh"
if [ -f "$CHECK_DESIGN" ]; then
  echo "check-design-tokens.sh:"

  # Scratch repo with a view in a real product folder.
  design_repo() { # $1 = name, $2 = relative view path
    mkdir -p "$TMP/$1/$(dirname "$2")"
  }
  run_design() { (bash "$CHECK_DESIGN" "$TMP/$1" > /dev/null 2>&1); }

  design_repo dz-ok app/views/v.html
  printf '<div class="bg-primary text-base-content">ok</div>\n' >"$TMP/dz-ok/app/views/v.html"
  run_design dz-ok; check "view with semantic tokens → passes" 0 $?

  design_repo dz-palette app/views/v.html
  printf '<div class="bg-blue-500">x</div>\n' >"$TMP/dz-palette/app/views/v.html"
  run_design dz-palette; check "raw palette utility (Tailwind) → fails" 1 $?

  # The check is framework-agnostic: the same rule, written the way Sass/Bootstrap
  # writes it. Without this, a project that does not use Tailwind passed green without
  # a single one of its violations being looked at.
  design_repo dz-sass src/styles.scss
  printf '.card { background: $gray-700; }\n' >"$TMP/dz-sass/src/styles.scss"
  run_design dz-sass; check "raw palette variable in Sass → fails" 1 $?

  design_repo dz-cp src/styles.css
  printf '.btn { color: var(--ui-red); }\n' >"$TMP/dz-cp/src/styles.css"
  run_design dz-cp; check "custom property with a color name → fails" 1 $?

  design_repo dz-cp-num src/styles.css
  printf '.btn { color: var(--gray-700); }\n' >"$TMP/dz-cp-num/src/styles.css"
  run_design dz-cp-num; check "numbered palette custom property → fails" 1 $?

  # …and the system tokens pass, even though `neutral` is also a color name: here it
  # is a ROLE. Without this test, the pattern above swallowed them and the check failed
  # against the very design system it verifies.
  design_repo dz-cp-ok src/styles.css
  printf '.btn { color: var(--neutral); background: var(--neutral-content); }\n' >"$TMP/dz-cp-ok/src/styles.css"
  run_design dz-cp-ok; check "the system's semantic tokens → passes" 0 $?

  design_repo dz-hex app/views/v.html
  printf '<div style="color:#ff0000">x</div>\n' >"$TMP/dz-hex/app/views/v.html"
  run_design dz-hex; check "raw hex color → fails" 1 $?

  design_repo dz-arb app/views/v.html
  printf '<div class="bg-[#0A7A9D]">x</div>\n' >"$TMP/dz-arb/app/views/v.html"
  run_design dz-arb; check "arbitrary value bg-[#…] → fails" 1 $?

  # `bg-neutral` is a semantic token of the system; `bg-neutral-500` is palette.
  design_repo dz-semantic app/views/v.html
  printf '<div class="bg-neutral text-neutral-content">x</div>\n' >"$TMP/dz-semantic/app/views/v.html"
  run_design dz-semantic; check "bg-neutral (semantic) → passes" 0 $?

  # Internal links with # are not colors.
  design_repo dz-anchor app/views/v.html
  printf '<a href="#pricing">x</a><a href="#features">y</a>\n' >"$TMP/dz-anchor/app/views/v.html"
  run_design dz-anchor; check "#… anchors do not count as color → passes" 0 $?

  # Third-party logos: they carry THEIR brand colors; they are marked with data-brand.
  design_repo dz-brand app/views/v.html
  printf '<svg data-brand="google" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5z"/></svg>\n' \
    >"$TMP/dz-brand/app/views/v.html"
  run_design dz-brand; check "logo with data-brand → passes" 0 $?

  # …but the exception is bounded: outside the marked svg, it still fails.
  design_repo dz-brand-outside app/views/v.html
  printf '<svg data-brand="google"><path fill="#EA4335" d="M0 0z"/></svg>\n<div style="color:#ff0000">x</div>\n' \
    >"$TMP/dz-brand-outside/app/views/v.html"
  run_design dz-brand-outside; check "hex outside data-brand → fails anyway" 1 $?

  # Covers the other two conventions: Jinja (templates/) and React (src/).
  design_repo dz-jinja templates/v.j2
  printf '<div class="bg-red-400">x</div>\n' >"$TMP/dz-jinja/templates/v.j2"
  run_design dz-jinja; check "Jinja template with palette → fails" 1 $?

  design_repo dz-react src/App.tsx
  printf 'export default () => <div className="bg-[#123456]" />\n' >"$TMP/dz-react/src/App.tsx"
  run_design dz-react; check "React component with an arbitrary value → fails" 1 $?

  # With no views nothing is imposed (a freshly instantiated repo, or no UI).
  mkdir -p "$TMP/dz-none"
  run_design dz-none; check "repo with no views → allows" 0 $?

  # …but it SAYS SO, and says what it looked for: "nothing to check" was
  # indistinguishable from a real ✅, and read as "does not apply" instead of "I do not
  # know how to look at this".
  output_dz="$(bash "$CHECK_DESIGN" "$TMP/dz-none" 2>&1 || true)"
  printf '%s' "$output_dz" | grep -q 'Extensions:'
  check "repo with no views → says which extensions it looked for" 0 $?

  # ── The big hole: CSS and JS were not looked at ────────────────────────────
  # CSS is where raw colors live in ANY stack, not only in a framework-less one: a
  # Rails app with app/assets/stylesheets/*.css was not checked either. And a project
  # with no framework passed green without a single file being opened.
  design_repo dz-css src/styles.css
  printf '.button { background: #0a7a9d; }\n' >"$TMP/dz-css/src/styles.css"
  run_design dz-css; check "hex in a .css → fails" 1 $?

  design_repo dz-js src/view.js
  printf 'export const tpl = () => `<div style="color:#ff0000">x</div>`;\n' >"$TMP/dz-js/src/view.js"
  run_design dz-js; check "hex in a .js template → fails" 1 $?

  # And the root: in a framework-less project the page lives at ./index.html and no
  # DIRS folder covers it.
  mkdir -p "$TMP/dz-root"
  printf '<div style="color:#ff0000">x</div>\n' >"$TMP/dz-root/index.html"
  run_design dz-root; check "index.html at the root → is checked" 1 $?

  # The file that DEFINES the tokens is the exception: there raw color is the content.
  # Without exempting it, migrating design/tokens.css into src/ turned the check
  # permanently red, which is the fastest way for somebody to delete it.
  mkdir -p "$TMP/dz-tokens/src"
  printf ':root { --color-primary: #0a7a9d; }\n' >"$TMP/dz-tokens/src/tokens.css"
  run_design dz-tokens; check "tokens.css defines the colors → exempt" 0 $?

  # Documenting the rule cannot violate the rule: comments never reach the browser.
  # This was a real false positive — the header of a stylesheet spelling out the
  # forbidden patterns showed up as a finding.
  design_repo dz-comment src/styles.css
  printf '/* Golden rule: never #ff0000 nor rgb(0,0,0). Tokens only. */\n.b { color: var(--color-primary); }\n' \
    >"$TMP/dz-comment/src/styles.css"
  run_design dz-comment; check "hex inside a CSS comment → does not count" 0 $?

  design_repo dz-comment-js src/view.js
  printf '// do not use #ff0000\nexport const c = "var(--color-primary)";\n' \
    >"$TMP/dz-comment-js/src/view.js"
  run_design dz-comment-js; check "hex inside a JS comment → does not count" 0 $?

  # But the `//` exclusion cannot eat the rest of the line after a URL: without the
  # lookbehind, `https://` blanked out the hex that came after it.
  design_repo dz-url src/view.js
  printf 'const doc = "https://example.com"; const c = "#ff0000";\n' >"$TMP/dz-url/src/view.js"
  run_design dz-url; check "https:// does not blank the rest of the line → fails" 1 $?
fi

# ── check-inheritance.sh ─────────────────────────────────────────────────────
CHECK_INHERITANCE="$REPO_ROOT/.github/scripts/check-inheritance.sh"
if [ -f "$CHECK_INHERITANCE" ]; then
  echo "check-inheritance.sh:"

  instance() { # $1 = name, $2 = instantiation date
    mkdir -p "$TMP/$1/docs/decisions"
    printf 'repo=https://github.com/x/y\ncommit=abc\ndate=%s\n' "$2" >"$TMP/$1/.template-origin"
  }
  run_inheritance() { (bash "$CHECK_INHERITANCE" "$TMP/$1" > /dev/null 2>&1); }

  # Without .template-origin it is not an instance: the template itself is untouched.
  mkdir -p "$TMP/hr-template"
  run_inheritance hr-template; check "no .template-origin → allows" 0 $?

  # A freshly instantiated, clean project.
  instance hr-ok 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.1.0] - 2026-08-08\n\n- Start.\n' \
    >"$TMP/hr-ok/CHANGELOG.md"
  run_inheritance hr-ok; check "clean instance → passes" 0 $?

  # A CHANGELOG version predating the instantiation = inheritance.
  instance hr-changelog 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.3.0] - 2026-08-02\n\n- From the template.\n' \
    >"$TMP/hr-changelog/CHANGELOG.md"
  run_inheritance hr-changelog; check "CHANGELOG with a previous version → fails" 1 $?

  # An ADR predating the instantiation = a template decision.
  instance hr-adr 2026-08-07
  printf '# 0004. Guardrails\n\n- **Date**: 2026-08-02\n' \
    >"$TMP/hr-adr/docs/decisions/0004-guardrails.md"
  run_inheritance hr-adr; check "ADR with a previous date → fails" 1 $?

  # …but 0001 is the canonical ADR and IS inherited.
  instance hr-adr-canonical 2026-08-07
  printf '# 0001. Record decisions\n\n- **Date**: 2026-07-01\n' \
    >"$TMP/hr-adr-canonical/docs/decisions/0001-record-architecture-decisions.md"
  run_inheritance hr-adr-canonical; check "canonical ADR 0001 → inherited, passes" 0 $?

  # Files exclusive to the template repo.
  instance hr-parity 2026-08-07
  printf '# guide\n' >"$TMP/hr-parity/TEMPLATE-USAGE.md"
  run_inheritance hr-parity; check "leftover TEMPLATE-USAGE.md → fails" 1 $?

  # Unreadable date: fails open, it does not jam the flow.
  mkdir -p "$TMP/hr-date"
  printf 'repo=x\ndate=yesterday\n' >"$TMP/hr-date/.template-origin"
  run_inheritance hr-date; check "invalid date → allows" 0 $?

  # Same day: the template publishes and the project instantiates on the same date.
  # With a strict `<` this passed and the inheritance slipped through — a real bug:
  # three template versions and one instantiation shared 2026-08-10.
  instance hr-sameday 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.2.1] - 2026-08-07\n\n- From the template.\n' \
    >"$TMP/hr-sameday/CHANGELOG.md"
  run_inheritance hr-sameday; check "CHANGELOG with a same-day version → fails" 1 $?

  # With `versions=` the criterion is exact: a version from the list is inheritance…
  mkdir -p "$TMP/hr-vers/docs/decisions"
  printf 'repo=x\ncommit=abc\ndate=2026-08-07\nversions=0.2.1,0.2.0,0.1.0\n' \
    >"$TMP/hr-vers/.template-origin"
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.2.1] - 2026-08-07\n\n- From the template.\n' \
    >"$TMP/hr-vers/CHANGELOG.md"
  run_inheritance hr-vers; check "versions=: a template version → fails" 1 $?

  # …and an OWN release cut on the same day as the instantiation is NOT accused.
  mkdir -p "$TMP/hr-vers-ok/docs/decisions"
  printf 'repo=x\ncommit=abc\ndate=2026-08-07\nversions=0.2.1,0.2.0\n' \
    >"$TMP/hr-vers-ok/.template-origin"
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.1.0] - 2026-08-07\n\n- First own release.\n' \
    >"$TMP/hr-vers-ok/CHANGELOG.md"
  run_inheritance hr-vers-ok; check "versions=: own same-day release → passes" 0 $?

  # …even when the number MATCHES a template version, which is the normal case and not
  # the rare one: every template had a 0.1.0 and every new project cuts its own.
  # Without the exemption, no start could cut its first version.
  mkdir -p "$TMP/hr-vers-first/docs/decisions"
  printf 'repo=x\ncommit=abc\ndate=2026-08-07\nversions=0.4.0,0.3.0,0.2.0,0.1.0\n' \
    >"$TMP/hr-vers-first/.template-origin"
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.1.0] - 2026-08-07\n\n- Own kickoff.\n' \
    >"$TMP/hr-vers-first/CHANGELOG.md"
  run_inheritance hr-vers-first
  check "versions=: own first with a template number → passes" 0 $?

  # But the exemption does NOT cover a forgotten reset: there what is left on top is
  # the template's NEWEST version, and its others sit below.
  mkdir -p "$TMP/hr-vers-forgot/docs/decisions"
  printf 'repo=x\ncommit=abc\ndate=2026-08-07\nversions=0.4.0,0.3.0\n' \
    >"$TMP/hr-vers-forgot/.template-origin"
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.4.0] - 2026-08-07\n\n- From the template.\n\n## [0.3.0] - 2026-08-01\n\n- From the template.\n' \
    >"$TMP/hr-vers-forgot/CHANGELOG.md"
  run_inheritance hr-vers-forgot
  check "versions=: forgotten reset (newest on top) → fails" 1 $?

  # The project's OWN instantiation ADR (0002) is dated the same day it instantiates:
  # here the strict `<` is deliberate — with `<=` every healthy project would go red.
  # (Asymmetry documented in the script itself.)
  instance hr-adr-sameday 2026-08-07
  printf '# 0002. Instantiation\n\n- **Date**: 2026-08-07\n' \
    >"$TMP/hr-adr-sameday/docs/decisions/0002-instantiation.md"
  run_inheritance hr-adr-sameday; check "own same-day ADR → passes" 0 $?

  # The date is extracted by pattern: text after the date does not break the comparison
  # ("## [1.0.0] - 2026-08-08 (beta)" is LATER than the instantiation → passes).
  instance hr-suffix 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [1.0.0] - 2026-08-08 (beta)\n\n- Own.\n' \
    >"$TMP/hr-suffix/CHANGELOG.md"
  run_inheritance hr-suffix; check "date with a suffix, later → passes" 0 $?

  # ── --publishable-version ──────────────────────────────────────────────────
  # The guard that prevents publishing the TEMPLATE's release. It really happened:
  # /instantiate creates main in Step 0 pointing at the initial commit (inherited
  # CHANGELOG) and pushing main fires release.yml, which published a v1.0.0 with the
  # origin repo's notes. And the expensive part came later: the day the project reaches
  # its own v1.0.0, release.yml would say "it already has a tag" and skip that release
  # silently.
  run_publishable() { (bash "$CHECK_INHERITANCE" --publishable-version "$TMP/$1" >/dev/null 2>&1); }

  # The exact case from the finding: forgotten reset, the template's newest version on
  # top, dated the day of the instantiation.
  run_publishable hr-vers-forgot; check "publishable: forgotten reset → does NOT publish" 1 $?

  # And the one that must never break: the first own version, same day, with a number
  # the template also had.
  run_publishable hr-vers-first; check "publishable: first own version → publishes" 0 $?
  run_publishable hr-vers-ok; check "publishable: own same-day release → publishes" 0 $?

  # The template itself (no .template-origin) publishes its own.
  run_publishable hr-template; check "publishable: no .template-origin → publishes" 0 $?

  # What really closes the delayed failure: when the project reaches its own version
  # with the same number as the template's, BUT later, it publishes. If this failed,
  # the guard would have traded one failure for another.
  mkdir -p "$TMP/hr-pub-own/docs/decisions"
  printf 'repo=x\ncommit=abc\ndate=2026-08-07\nversions=1.0.0,0.5.0\n' \
    >"$TMP/hr-pub-own/.template-origin"
  printf '# Changelog\n\n## [Unreleased]\n\n## [1.0.0] - 2027-03-01\n\n- The real v1.\n' \
    >"$TMP/hr-pub-own/CHANGELOG.md"
  run_publishable hr-pub-own; check "publishable: own v1.0.0 a year later → publishes" 0 $?

  # Without versions= (older instances) the criterion is the strict one: only what is
  # dated BEFORE the install is rejected. When in doubt it publishes, because here a
  # false positive is not noise: it prevents cutting the release.
  instance hr-pub-old 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.9.0] - 2026-08-01\n\n- From the template.\n' \
    >"$TMP/hr-pub-old/CHANGELOG.md"
  run_publishable hr-pub-old; check "publishable: no versions=, earlier date → does NOT publish" 1 $?

  instance hr-pub-old-sameday 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.1.0] - 2026-08-07\n\n- Own.\n' \
    >"$TMP/hr-pub-old-sameday/CHANGELOG.md"
  run_publishable hr-pub-old-sameday; check "publishable: no versions=, same day → publishes" 0 $?

  # A CHANGELOG with no dated version does not block: release.yml already handles that.
  mkdir -p "$TMP/hr-pub-nover"
  printf 'repo=x\ndate=2026-08-07\n' >"$TMP/hr-pub-nover/.template-origin"
  printf '# Changelog\n\n## [Unreleased]\n\n- Nothing cut.\n' >"$TMP/hr-pub-nover/CHANGELOG.md"
  run_publishable hr-pub-nover; check "publishable: no dated version → no opinion" 0 $?
fi

# ── check-project-tests.sh ────────────────────────────────────────────────────
CHECK_PROJECT_TESTS="$REPO_ROOT/.github/scripts/check-project-tests.sh"
if [ -f "$CHECK_PROJECT_TESTS" ]; then
  echo "check-project-tests.sh:"
  agents_md() { # $1 = dir, $2 = test command (empty = not declared)
    mkdir -p "$TMP/$1"
    {
      echo '# Project'
      echo '## Usage'
      echo '```bash'
      [ -n "$2" ] && echo "$2   # test suite"
      echo '```'
    } >"$TMP/$1/README.md"
  }

  mkdir -p "$TMP/pt-none"
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-none" >/dev/null); check "no README.md → passes with a warning" 0 $?
  agents_md pt-gap '[TEST_COMMAND]'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-gap" >/dev/null); check "unfilled command → passes with a warning" 0 $?
  agents_md pt-green 'python3 -c "raise SystemExit(0)"'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-green" >/dev/null 2>&1); check "green suite → passes" 0 $?
  agents_md pt-red 'python3 -c "raise SystemExit(1)"'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-red" >/dev/null 2>&1); check "red suite → fails" 1 $?

  # Allowlist: the command comes from AGENTS.md and in CI it runs on third-party PRs —
  # one outside the list is NOT executed (here: creating a directory).
  agents_md pt-weird 'mkdir dangerous-dir'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-weird" >/dev/null 2>&1); rc=$?
  [ "$rc" -eq 0 ] && [ ! -d "$TMP/pt-weird/dangerous-dir" ]
  check "command outside the allowlist → not executed" 0 $?

  # VAR=value prefixes do not change the classification (RAILS_ENV=test bin/rails test
  # is a normal test command) — they used to fall into "unrecognized" and the ✅ went
  # back to testing nothing.
  agents_md pt-env 'CI=1 python3 -c "raise SystemExit(1)"'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-env" >/dev/null 2>&1); check "VAR=value prefix: the suite runs (and fails) → fails" 1 $?

  # A COMPOUND command is not classified by its prefix: `npm test && <whatever>` used
  # to pass the whole allowlist through to the eval.
  agents_md pt-compound 'python3 -c pass && mkdir chained-dir'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-compound" >/dev/null 2>&1); rc=$?
  [ "$rc" -eq 0 ] && [ ! -d "$TMP/pt-compound/chained-dir" ]
  check "compound command → not executed" 0 $?

  # Between the documentation PR and the scaffolding one, AGENTS.md already declares
  # the chosen stack's command but the project does not exist. A package manager
  # without its manifest is not a red suite: there is no suite yet.
  agents_md pt-no-manifest 'pnpm test'
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-no-manifest" >/dev/null 2>&1)
  check "package manager with no manifest → passes with a warning" 0 $?
  # But with a manifest it does run: the shortcut cannot hide a real red suite.
  agents_md pt-with-manifest 'npm test'
  echo '{"scripts":{"test":"exit 1"}}' >"$TMP/pt-with-manifest/package.json"
  (bash "$CHECK_PROJECT_TESTS" "$TMP/pt-with-manifest" >/dev/null 2>&1)
  check "package manager with a manifest and a red suite → fails" 1 $?
fi

# ── check-instructions.sh ────────────────────────────────────────────────────
# The prune leaves the README telling you to run what no longer exists, and NO check
# flagged it: `cp .env.example .env` is not a placeholder, it is hardcoded text. It
# reads as a correct instruction until somebody runs it.
if [ -f "$CHECK_INSTRUCTIONS" ]; then
  echo "check-instructions.sh:"
  instr() { mkdir -p "$TMP/$1"; }
  run_instr() { (bash "$CHECK_INSTRUCTIONS" "$TMP/$1" >/dev/null 2>&1); }

  # The case from the finding: .env.example deliberately kept but WITH NO variables
  # —only its explanation of why it is empty— and the README telling you to copy it.
  instr in-empty
  printf '# Environment variables\n# None: no server, no build, the key lives in the browser.\n' \
    >"$TMP/in-empty/.env.example"
  printf '# P\n\n```bash\ngit clone x\ncp .env.example .env\n```\n' >"$TMP/in-empty/README.md"
  run_instr in-empty; check "instructions: .env.example with no variables + cp → fails" 1 $?

  # With real variables, the same README is correct.
  instr in-vars
  printf 'APP_ENV=development\nPORT=3000\n' >"$TMP/in-vars/.env.example"
  printf '# P\n\n```bash\ncp .env.example .env\n```\n' >"$TMP/in-vars/README.md"
  run_instr in-vars; check "instructions: with variables → passes" 0 $?

  # Comments are not variables: a file full of `# FOO=bar` is still empty.
  instr in-commented
  printf '# Example of what will exist someday:\n#   DATABASE_URL=postgres://…\n' \
    >"$TMP/in-commented/.env.example"
  printf '# P\n\n```bash\ncp .env.example .env\n```\n' >"$TMP/in-commented/README.md"
  run_instr in-commented; check "instructions: variables only commented out → fails" 1 $?

  # Without the README line there is nothing to complain about, even if the file is
  # empty: keeping .env.example empty WITH its explanation is what /instantiate says.
  instr in-pruned
  printf '# No variables yet.\n' >"$TMP/in-pruned/.env.example"
  printf '# P\n\n```bash\ngit clone x\n```\n' >"$TMP/in-pruned/README.md"
  run_instr in-pruned; check "instructions: empty .env.example but a clean README → passes" 0 $?

  # [MIGRATIONS_COMMAND] in a product with neither a database nor variables.
  instr in-migr
  printf '# No variables.\n' >"$TMP/in-migr/.env.example"
  printf '# P\n\n```bash\n[MIGRATIONS_COMMAND]\n```\n' >"$TMP/in-migr/README.md"
  run_instr in-migr; check "instructions: migrations with no database → fails" 1 $?

  # …but with a migrations folder the step is legitimate.
  instr in-migr-ok
  mkdir -p "$TMP/in-migr-ok/db/migrate"
  printf '# No variables.\n' >"$TMP/in-migr-ok/.env.example"
  printf '# P\n\n```bash\n[MIGRATIONS_COMMAND]\n```\n' >"$TMP/in-migr-ok/README.md"
  run_instr in-migr-ok; check "instructions: migrations with db/migrate → passes" 0 $?

  # In TEMPLATE mode it imposes nothing: the README is still the skeleton to prune, and
  # its .env.example ships every block.
  instr in-template
  printf 'guide\n' >"$TMP/in-template/TEMPLATE-USAGE.md"
  printf '# No variables.\n' >"$TMP/in-template/.env.example"
  printf '# P\n\n```bash\ncp .env.example .env\n```\n' >"$TMP/in-template/README.md"
  run_instr in-template; check "instructions: template mode → no opinion" 0 $?

  # With no README there is nothing to check.
  instr in-no-readme
  run_instr in-no-readme; check "instructions: no README → allows" 0 $?
fi

# ── check-hooks-enabled.sh ────────────────────────────────────────────────────
# core.hooksPath does not travel in the repository: the DEFAULT state of every clone is
# "no local verification". And when GitHub offers no branch protection —private repos
# on the free plan— those hooks are the only defense left.
if [ -f "$CHECK_HOOKS" ]; then
  echo "check-hooks-enabled.sh:"
  hooks_repo() { # $1 = name; repo with executable .githooks/
    mkdir -p "$TMP/$1/.githooks" && git -C "$TMP/$1" init -q -b main
    printf '#!/bin/sh\nexit 0\n' >"$TMP/$1/.githooks/pre-push"
    chmod +x "$TMP/$1/.githooks/pre-push"
  }
  run_hooks() { (bash "$CHECK_HOOKS" "$TMP/$1" >/dev/null 2>&1); }

  hooks_repo hk-off
  run_hooks hk-off; check "hooks: fresh clone with no core.hooksPath → fails" 1 $?

  hooks_repo hk-on
  git -C "$TMP/hk-on" config core.hooksPath .githooks
  run_hooks hk-on; check "hooks: core.hooksPath set → passes" 0 $?

  # Pointing at the right place is not enough: if they are not executable, git ignores
  # them silently.
  hooks_repo hk-noexec
  git -C "$TMP/hk-noexec" config core.hooksPath .githooks
  chmod -x "$TMP/hk-noexec/.githooks/pre-push"
  run_hooks hk-noexec; check "hooks: points right but no execute permission → fails" 1 $?

  # --fix enables them and leaves the repo passing.
  hooks_repo hk-fix
  (bash "$CHECK_HOOKS" --fix "$TMP/hk-fix" >/dev/null 2>&1)
  check "hooks: --fix exits 0" 0 $?
  run_hooks hk-fix; check "hooks: after --fix, it passes" 0 $?
  [ "$(git -C "$TMP/hk-fix" config --get core.hooksPath)" = ".githooks" ]
  check "hooks: --fix leaves core.hooksPath = .githooks" 0 $?

  # …and it also repairs the permission, which is the other way of failing silently.
  hooks_repo hk-fix-exec
  git -C "$TMP/hk-fix-exec" config core.hooksPath .githooks
  chmod -x "$TMP/hk-fix-exec/.githooks/pre-push"
  (bash "$CHECK_HOOKS" --fix "$TMP/hk-fix-exec" >/dev/null 2>&1)
  run_hooks hk-fix-exec; check "hooks: --fix repairs the permission" 0 $?

  # A project that deleted .githooks/ has nothing to enable.
  mkdir -p "$TMP/hk-no-folder" && git -C "$TMP/hk-no-folder" init -q -b main
  run_hooks hk-no-folder; check "hooks: no .githooks folder → no opinion" 0 $?

  # Outside a git repo it has no opinion either.
  mkdir -p "$TMP/hk-no-git/.githooks"
  run_hooks hk-no-git; check "hooks: outside a git repo → no opinion" 0 $?
fi

# ── The Prettier version lives in ONE place ───────────────────────────────────
# It is pinned (not `prettier@3`) because a formatter that changes minor changes its
# output: the same file passes on one machine and fails in CI. And it lives in one
# place because two versions of the same formatter in the same repo fight each other —
# pre-commit would format one way and the CI check would demand another.
echo "Prettier version:"
FMT="$REPO_ROOT/.github/scripts/format.sh"
PRECOMMIT="$REPO_ROOT/.githooks/pre-commit"
if [ -f "$FMT" ]; then
  v_fmt="$(sed -n 's/^PRETTIER="\(.*\)"$/\1/p' "$FMT")"
  printf '%s' "$v_fmt" | grep -Eq '^prettier@[0-9]+\.[0-9]+\.[0-9]+$'
  check "format.sh pins an exact Prettier version" 0 $?

  # Nobody INVOKES a literal version: both scripts pass the variable. It looks for
  # `npx … prettier@…` and not the bare string, because pre-commit's fallback
  # (`PRETTIER="prettier@3"`, which only kicks in if format.sh cannot be read) is a
  # deliberate assignment, not an invocation.
  loose="$(grep -rn 'npx.*prettier@' "$FMT" "$PRECOMMIT" 2>/dev/null || true)"
  [ -z "$loose" ]
  check "no script invokes a literal Prettier version" 0 $?
fi
if [ -f "$PRECOMMIT" ]; then
  # pre-commit does not repeat the number: it reads it from format.sh.
  grep -q 'sed -n .*PRETTIER=.*format\.sh' "$PRECOMMIT"
  check "pre-commit reads the version from format.sh instead of repeating it" 0 $?
  # And it actually reads it right: the value it extracts is the one format.sh declares.
  v_pre="$(cd "$REPO_ROOT" && sed -n 's/^PRETTIER="\(.*\)"$/\1/p' .github/scripts/format.sh)"
  [ "$v_pre" = "$v_fmt" ]
  check "the version pre-commit reads matches format.sh's" 0 $?
fi

# ── LABELS.md as the single source for setup-labels.sh ────────────────────────
SETUP_LABELS="$REPO_ROOT/.github/scripts/setup-labels.sh"
LABELS_MD_REAL="$REPO_ROOT/.github/LABELS.md"
if [ -f "$SETUP_LABELS" ] && [ -f "$LABELS_MD_REAL" ]; then
  echo "setup-labels.sh:"
  rows="$(grep -cE '^\| *`[^`]+` *\| *`#[0-9A-Fa-f]{6}` *\|' "$LABELS_MD_REAL" || true)"
  [ "$rows" -ge 10 ]; check "LABELS.md has parseable rows ($rows)" 0 $?
  # Not one hardcoded label in the script: they were two copies and had already drifted
  # ("Documentation changes" vs "Documentation-only changes").
  ! grep -qE 'create_label "[a-z]' "$SETUP_LABELS"; check "setup-labels.sh with no hardcoded labels" 0 $?
fi

# ── .github/workflows/ structure ──────────────────────────────────────────────
# GitHub runs ANY .yml/.yaml in that folder, without looking at the rest of the name:
# `ci.example.yml` really ran (a "CI" workflow green without testing anything).
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
