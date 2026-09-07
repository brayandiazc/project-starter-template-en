# How to use this template

This guide explains how to turn this template into your project's real documentation. Once instantiated, **you can delete this file** (`TEMPLATE-USAGE.md`).

## 1. What it is and what it is not

- **It is** a documentation base ready to start any project: folder structure, governance files and document skeletons with placeholders.
- **It is not** a code boilerplate and it is not tied to a specific stack. It includes no dependencies or language-specific configuration — your project brings that.

## 2. Instantiating the template

**Option A — GitHub (recommended):** press **"Use this template" → Create a new repository**. GitHub copies the content without the commit history.

**Option B — Clone and reset the history:**

```bash
git clone [THIS_TEMPLATE_URL] my-project
cd my-project
rm -rf .git
git init
```

### Adopting it in an existing project

"Use this template" only works for new repositories. To bring this structure into a
project you already started there is **one single rule, and it is not negotiable**:

> **Nothing is ever overwritten.** Only what does not exist gets brought in.

This is not excessive caution. The previous recipe did `cp -R .tpl/docs .`, and tested
against a real project —which had already adopted an earlier version of this template— it
replaced **1,532 lines of written documentation with empty skeletons**: its `api.md` went
from 182 lines of real contract to 96 with five placeholders. It is recoverable with git,
yes, but only if somebody notices, and the diff was 57 new files mixed with 22 clobbered
ones.

```bash
# From your project's root, on a new branch
git checkout -b chore/adopt-doc-template

# Download the template without its history
npx degit brayandiazc/project-starter-template-en-ai .tpl

# Bring in ONLY what you are missing. Yours is not touched.
(cd .tpl && find docs .githooks .github/scripts design -type f 2>/dev/null) \
  | while IFS= read -r f; do
      [ -e "$f" ] || { mkdir -p "$(dirname "$f")"; cp ".tpl/$f" "$f"; }
    done

# The root ones, one by one and only if they do not exist
for f in .editorconfig; do
  [ -e "$f" ] || cp ".tpl/$f" "$f"
done

# And see what exists in BOTH, so you can decide file by file
(cd .tpl && find docs -type f) | while IFS= read -r f; do [ -e "$f" ] && echo "BOTH: $f"; done

rm -rf .tpl
```

That last list is the real work: those are the documents where the template and your
project say things about the same subject. Nobody can merge them for you — but at least
now you know which they are instead of discovering it once they are gone.

**Afterwards**:

- **Compare the file names against the template's `CHANGELOG.md`**: if you adopted an
  earlier version, some document of yours may now be called something else. Bringing in
  the new one without deleting the old one **leaves both**, with different content and
  without any check noticing.
- Enable the git hooks: `bash .github/scripts/check-hooks-enabled.sh --fix`. It does the
  same as `git config core.hooksPath .githooks` and also verifies they are executable.
  This check cannot run in CI —it does not see anybody's local config— nor inside
  `pre-push` —it only runs if the config it verifies is already set—, so if you do not
  call it here, nobody does.
- Write `.template-origin` (repo, commit, date and `versions=` with the template's
  CHANGELOG versions — without them, `check-inheritance.sh` falls back to a date-based
  criterion that may accuse a release of yours cut the same day) so the notification
  workflow works from here on.
- Fill the new `docs/` with what you already know about the project instead of leaving
  placeholders.
- Commit on the branch, open a PR and then delete `TEMPLATE-USAGE.md`.

> If your project **already had** a version of this template, compute the tooling diff
> between your origin commit and the template's HEAD and apply only that.

## 3. Replacing the placeholders

Every placeholder uses the `[BRACKETS_IN_UPPERCASE]` format. **But they are not
substituted across the whole repository**: ask first for the paths where a placeholder is
a value to fill in.

```bash
bash .github/scripts/check-placeholders.sh --fillable-paths   # where to touch
bash .github/scripts/check-placeholders.sh                    # what is missing
```

Left out are `.github/scripts/`, `.github/workflows/`, `CHANGELOG.md` and the two
internal templates (`docs/decisions/0000-template.md`, `docs/conventions/_template.md`).
There a placeholder is **test data, explanatory text or the only thing that makes the
template useful**, and substituting it destroys it: it happened, and it broke this
repository's own test bench.

To inspect by eye, without substituting:

```bash
bash .github/scripts/check-placeholders.sh --fillable-paths \
  | xargs grep -no '\[[A-Z0-9_/]\+\]'
```

### Placeholder catalog

| Placeholder                                                                                                              | Meaning                                                |
| ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| `[PROJECT_NAME]`                                                                                                         | The product's name, as it reads                        |
| `[REPOSITORY_SLUG]`                                                                                                      | The repository's name on GitHub (`my-project`)         |
| `[AUTHOR]`                                                                                                               | Name of the author or main maintainer                  |
| `[GITHUB_USER]`                                                                                                          | GitHub user or organization                            |
| `[REPOSITORY_URL]`                                                                                                       | The repository's URL                                   |
| `[YEAR]`                                                                                                                 | Copyright year in the license                          |
| `[VERSION]`                                                                                                              | A version (of a dependency or of the project)          |
| `[DATE]`                                                                                                                 | A date (`YYYY-MM-DD` format)                           |
| `[SUPPORT_EMAIL]`                                                                                                        | Contact/support email                                  |
| `[SECURITY_EMAIL]`                                                                                                       | Email for reporting vulnerabilities                    |
| `[RUNTIME]`                                                                                                              | Language/runtime (Node.js, Python, Ruby…)              |
| `[PACKAGE_MANAGER]`                                                                                                      | npm, pnpm, bundler, pip…                               |
| `[DATABASE]`                                                                                                             | PostgreSQL, MySQL, MongoDB…                            |
| `[PORT]`                                                                                                                 | Local development port                                 |
| `[*_COMMAND]`                                                                                                            | The project's commands (install, test, build, deploy…) |
| `[*_URL]` (`[DEV_URL]`, `[API_BASE_URL]`…)                                                                               | URLs per environment and web resources                 |
| `[SERVICE/API]`, `[LINK_*]`, `[OTHER_*]`                                                                                 | Resources specific to your project                     |
| `[TOOL]`, `[*_TOOL]`                                                                                                     | Stack tools (build, test, e2e, migrations…)            |
| `[FRAMEWORK_*]`, `[*_FRAMEWORK]`, `[ORM]`, `[LINTER]`, `[FORMATTER]`                                                     | Stack pieces by role                                   |
| `[CACHE]`, `[QUEUE]`, `[CONTAINERS]`, `[CI_CD]`, `[MONITORING]`, `[TTL]`                                                 | Infrastructure and operations                          |
| `[URL]`                                                                                                                  | A source URL, in the tables                            |
| `[SERVER]`, `[SNAPSHOT_ID]`                                                                                              | Host and snapshot names, in the backup commands        |
| `[*_PATH]`                                                                                                               | Folder/file paths in the project                       |
| `[*_LAYOUT]`, `[LOCALE_*]`, `[DEFAULT_LOCALE]`, `[AA/AAA]`                                                               | UI, i18n and target accessibility level                |
| `[ENTITY_*]`, `[COMPONENT_*]`, `[SERVICE_*]`, `[MODULE_*]`, `[ROLE_*]`, `[ACTOR_*]`                                      | Domain model and architecture                          |
| `[SEGMENT_*]`, `[PLAN_*]`, `[PRICE]`, `[PERCENTAGE]`                                                                     | Business model                                         |
| `[CHOSEN]`, `[DISCARDED]`, `[ALTERNATIVE]`, `[DECISION_*]`                                                               | Comparisons in decisions (stack, design)               |
| `[AI_TOOL]`, `[AI_TOOL_EMAIL]`                                                                                           | AI tool and its email (co-authorship trailer)          |
| `[TYPE]`, `[OTHER]`, `[EXAMPLE]`, `[COMMAND]`, `[NAMES]`, `[PROVIDER]`, `[RESOURCE]`, `[RISK]`, `[CODE]`, `[TECHNOLOGY]` | Local descriptors in each document                     |
| `[REASON]`, `[NOTE]`, `[WHAT_FOR]`                                                                                       | Same: the cell explaining a row's why or what-for      |
| `[SNAPSHOT_*_COMMAND]`                                                                                                   | Backup commands of whichever provider you use          |

> Keep this catalog up to date: any new `[PLACEHOLDER]` you introduce should appear here —
> CI verifies it with `.github/scripts/check-placeholders.sh`.

**Global and positional.** A placeholder is **global** if it has one single answer for the
whole repository (`PROJECT_NAME`, `GITHUB_USER`, the `*_COMMAND` ones): it can be
substituted in bulk. It is **positional** if it means something different in each
occurrence — the last four rows of the table are almost entirely positional: `VERSION` is
the version of a different piece each time, and `CHOSEN`/`DISCARDED` are the two sides of
a comparison per table. Positional ones **are filled in one by one, reading their
context**; substituting them in bulk leaves tidy, false documents, which is worse than
leaving them empty. If the same placeholder appears twice in the same file, it is
positional.

**The name and the slug are not the same.** `PROJECT_NAME` is the product's name as it
reads ("Shift Register"); `REPOSITORY_SLUG` is the repository's name (`shifts-app`). They
only coincide when the repository is named like the product, and the moment a code name is
used they diverge. Both are global, so the rule above does not separate them: what
separates them is **where they go**.

> A product name **never** appears in a URL, a path or a command. There the slug always
> goes: badges, `cd`, `git clone`, `gh api`, `REPOSITORY_URL`.

It is not cosmetic. A broken badge is visible; `cd Shift Register` and
`gh api repos/my-user/Shift Register/...` read as correct instructions until somebody
runs them.

### Pending: what cannot be filled in yet

When instantiating there is data that legitimately cannot be inferred. The rule is "do
not invent data", so it is left — but marked:

- **A datum missing on one line** is marked on that same line:
  `[SECURITY_EMAIL] <!-- pending: no mailbox yet -->`. In prose with no placeholder, a
  short sentence and the same mark (do not invent placeholders outside the catalog).
- **A datum missing across the whole repository** (the client's mailbox, a domain not yet
  bought) is declared ONCE in a `.pending` file at the root:
  `SUPPORT_EMAIL=the client has not given the mailbox yet`.
- Marked ones do not fail the check, but they **are listed on every run** — resolving them
  should be mildly annoying, not forgettable.

> **When quoting a placeholder in prose, write its name without brackets** —
> `PROJECT_NAME`, not between `[` `]`. A document that talks _about_ the placeholders (a
> log, a spec, this very file) has them just as literal as an unfilled one, and the check
> does not read intent. The files that exist to explain them are in
> `check-placeholders.sh`'s `SKIP` list; the rest, no brackets.

## 4. Recommended filling order

1. `README.md` — the project's front page.
2. `docs/architecture/stack.md` — record the stack you chose and where it comes from.
3. `docs/architecture/architecture.md` — the high-level view.
4. `docs/architecture/database.md` — the data model.
5. `docs/architecture/auth.md` — authentication and authorization.
6. `docs/architecture/api.md` — the API contract.
7. `docs/architecture/screens.md` — the screen map and critical journey.
8. `docs/product/business-model.md` — why the product exists and how it is paid for.
9. `docs/product/roadmap.md` — the roadmap.
10. `docs/decisions/` — create an ADR every time you take a relevant decision.

### What starts empty (the template's history)

A new project inherits the template's **tools**, not its **life**. On instantiating, these
are reset:

| File              | How it is left                                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CHANGELOG.md`    | Header + `## [Unreleased]` **with one kickoff bullet** — never empty: `check-changelog.sh` would block your first PR. That bullet becomes your `v0.1.0` |
| `docs/decisions/` | Only `0000-template.md` and `0001-record-architecture-decisions.md`                                                                                     |
| `docs/product/*`  | Skeletons with placeholders                                                                                                                             |

ADRs `0002` onward are decisions the template took, not your project's: what was inherited
is summarized in the instantiation ADR, with a link to the origin repository.

The `inheritance` job in `quality.yml` verifies it deterministically: `.template-origin`
stores the instantiation date and the template's versions (`versions=`), and nothing can
come from before that date or repeat those versions.

### What to delete if it does not apply

Every capability the product does **not** have takes its convention with it: no i18n →
`docs/conventions/i18n.md`; no database → `conventions/database.md` and
`architecture/database.md`; no SEO/public web → `conventions/seo.md`; no interface →
`conventions/ui.md`, `architecture/screens.md` and the `design/` folder. And also:

- The example workflows in `.github/workflows/` if you do not use GitHub Actions. The
  **active** workflows (`quality.yml`, `secret-scan.yml`) work on any stack — keep them if
  you use GitHub Actions.
- **Always** delete what is exclusive to the template repo: this very file, the
  `.github/workflows/template-parity.yml` workflow and the
  `.github/scripts/check-parity.sh` script (they only serve to maintain the family of
  variants).

## 5. Keeping the documentation alive

- Update the **"Last updated: [DATE]"** line when you edit a document.
- Every relevant architectural decision gets recorded as an **ADR** in `docs/decisions/` (see its [README](docs/decisions/README.md)).
- Keep `CHANGELOG.md` up to date following [Keep a Changelog](https://keepachangelog.com/).
- Additional conventions (payments, webhooks, multi-tenancy, PWA, etc.) can be added using [`docs/conventions/_template.md`](docs/conventions/_template.md).
- CI watches over the docs' health (the [`quality.yml`](.github/workflows/quality.yml) workflow):
  Markdown formatting, internal links and pending placeholders.

### Receiving template improvements

The template keeps evolving after you instantiate it. So you can bring those improvements
(new scripts, hooks or workflows) into your project:

- On instantiating, leave a `.template-origin` file at the root with the origin
  template's repo and commit.
- When you want to sync, compute the tooling diff between your origin commit and the
  template's current HEAD (`.github/`, `.githooks/`, `docs/conventions/_template.md`)
  and apply it — without touching your already-filled documentation.
- Follow the template repository's releases/tags to know what changed.
