# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

This is the CHANGELOG of the template repo [brayandiazc/project-starter-template-en](https://github.com/brayandiazc/project-starter-template-en).
It is reset when you instantiate: your project inherits the template's
tooling, not its life (see `TEMPLATE-USAGE.md`).

## [Unreleased]

### Added

- **`check-labels.sh` — that the labels in `LABELS.md` actually exist in the
  repository.** `LABELS.md` is the single source and `setup-labels.sh` creates them from
  its tables, but creating them is a **manual** step, once per repository, and nothing
  checked that it had been done. All five repos in this family had only GitHub's default
  labels: not one of the eleven declared ones existed.

  This is not cosmetic. `dependabot.yml` declares `sin-changelog` on its PRs so the
  changelog job lets them through — without the label created, Dependabot cannot apply
  it, the gate takes them down anyway, and **the fix looks done because the file says the
  right thing**. The manual escape hatch did not work either: you cannot put a label that
  does not exist on a PR.

### Fixed

- **`template-update-check.yml` blew up with a cryptic `git clone`** when the origin
  repository no longer resolved. A repo gets renamed and the `repo=` in
  `.template-origin` stays behind: GitHub redirects for a while, but once somebody claims
  the old name it stops resolving. It now warns that it may have been renamed and says
  which file to touch.
- **The PR template cited `docs/conventions/ai-agents.md`**, which does not exist in this
  variant. Everyone opening a PR read it, and `check-links.sh` did not see it because it
  was a `code span`, not a link.
- **Four comments in `run-tests.sh` pointed at `/instantiate` and `/update-template`** to
  explain why a rule exists. There are no skills here: they now cite the step or
  `TEMPLATE-USAGE.md`, which is what is actually there.

## [2.2.0] - 2026-09-07

### Fixed

- **Dependabot could not pass the CHANGELOG gate.** The `changelog` job requires an entry
  from every PR that touches the project; the bot touches the manifest and the lockfile,
  does not write changelogs and cannot learn to. Its PRs died with the build and the scans
  green. The exception was already designed —the `sin-changelog` label— nothing was just
  applying it: now they are born with it.
- **The escape hatch only worked when applied before opening the PR.** `PR_LABELS` comes
  from the event payload, so adding `sin-changelog` by hand triggered nothing and a re-run
  replayed the old payload, without the label — exactly backwards from when you find out
  you need it. `quality.yml` now listens for `labeled` and `unlabeled`. It costs a run per
  label change; an emergency exit unusable in the emergency costs more.

- **Nothing invoked `check-hooks-enabled.sh`.** It existed, had its cases in the test
  bench, and no other line in the repository called it: both calls lived in skills this
  variant does not have. And by design it cannot run in CI —it does not see anybody's
  local config— nor inside `pre-push` —it only runs if the config it verifies is already
  set—, so without an instruction calling it, nobody does. `TEMPLATE-USAGE.md` now invokes
  it instead of handing you the bare `git config`.
- **`TEMPLATE-USAGE.md` pointed at skills that do not exist here** (`/update-template`).
  It now describes the step instead of delegating it to something that is not there.

### Changed

- **Dependabot PRs come grouped**, one with every bump instead of one per package. Merging
  N separate bumps in a chain leaves a lockfile nobody ever built: git does not flag a
  conflict —each bump touches a different spot in the file— and CI does not see it either,
  because each PR is built on its own branch and never on the result of merging them all.
  The price, written next to it in `dependabot.yml`: if one bump in the group breaks, the
  whole group is blocked.

## [2.1.0] - 2026-09-07

### Added

- **`check-git-flow.sh` — that `develop` exists on the remote.** `CONTRIBUTING.md`
  requires every working branch to be born from `develop`; nothing checked it. A `develop` that only exists locally satisfies the rule when you
  branch and breaks it when you open the PR: `gh pr create --base develop` fails with
  "Base ref must be a branch", and the obvious way out of that error — opening it against
  `main` — is exactly what the convention forbids. The failure landed late and its
  apparent fix broke the flow.
- **`check-workflow-identity.sh` — that no workflow claims to be another repository.**
  Template-repo-only workflows are gated with `if: github.repository == 'user/repo'`.
  When one is copied between repositories that condition travels along as is, and then
  the job does not fail: it **skips**. In a PR's checks list a grey "skipping" reads
  almost like a green, so a check can go months without running once. It only has an
  opinion in the template repo: in an instance, the condition names the template on
  purpose.

  The two are the same criterion said twice: **a rule that only lives in prose does not
  hold**, and a check that does not run is worse than one that fails, because the failing
  one tells you. The test bench goes from 149 to 161 cases.

## [2.0.1] - 2026-09-07

### Fixed

- **The parity workflow never ran in this variant.** Its `if` condition and the sibling
  repository still named the AI variants, so the job showed up as "skipping" on every
  PR. A check that does not run is worse than one that fails: the second one tells you.
  It now compares against `project-starter-template-es`.
- **The workflows pointed at skills that do not exist here** (`/instantiate`,
  `/update-template`) and at `AGENTS.md`, which belongs to the AI variants. They now
  point at `TEMPLATE-USAGE.md` and the README's "Usage" block, which is what is here.

## [2.0.0] - 2026-09-07

### Added

- **`design/` — visual identity with semantic tokens**: the palette lives in `:root` as
  standard CSS custom properties, with two themes, AA contrast and the four data states.
  **Framework-agnostic on purpose**: the hook into a specific library lives in a single
  block marked as an adapter, which you replace. The design can be built however you
  like. Along with it comes `docs/architecture/screens.md`, the screen map.
- **Six new checks**, because a rule that only holds if you read it does not hold:
  `check-changelog`, `check-design-tokens`, `check-hooks-enabled`, `check-inheritance`,
  `check-instructions`, `check-project-tests` and `check-release`. The test bench goes
  from 25 to **149 cases**.
- **`.githooks/pre-commit` and `pre-push`**: `pre-commit` formats what is staged and
  never blocks; `pre-push` runs the same checks as CI in ~15 seconds and does block.
  Locally they are free; in Actions, they are minutes.

### Changed

- **`architecture/` answers what the project builds; `conventions/`, how the work is
  done.** The pairs that were always filled in and pruned together got merged.

  **If you are updating a project that already used an earlier version, this table is
  what you have to apply by hand.** A renamed document is not replaced: it is
  **duplicated**. You end up with both — yours with content and the new empty one — both
  are valid markdown, the links resolve and no check catches it.

  | Before                                  | Now                            | What to do with your content                                                                                                        |
  | --------------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
  | `docs/architecture/design.md`           | `docs/architecture/screens.md` | Migrate the screen map and delete the old one                                                                                       |
  | `docs/conventions/design-system.md`     | `docs/conventions/ui.md`       | Merge: `ui.md` gathers design system, branding and layouts                                                                          |
  | `docs/conventions/branding.md`          | `docs/conventions/ui.md`       | Same                                                                                                                                |
  | `docs/conventions/views-and-layouts.md` | `docs/conventions/ui.md`       | Same                                                                                                                                |
  | `docs/conventions/authentication.md`    | `docs/architecture/auth.md`    | Move the cross-cutting rules into the "Rules" section of `auth.md` and delete the old one. The pair was the same table in two files |
  | `docs/glossary.md`                      | —                              | Removed (orphan: nothing referenced it). If yours has content, move it to `docs/product/business-model.md`                          |
  | `.github/labeler.yml`                   | —                              | Removed: an 82-line orphan config; no workflow read it                                                                              |

- **`.github/LABELS.md` is the single source for labels**: `setup-labels.sh` parses its
  tables instead of keeping a second copy. They were duplicated and had already diverged.
- **The Prettier version is pinned in one place** (`format.sh`), which `pre-commit`
  reads. A formatter that changes minor version changes its output: the same file passes
  on one machine and fails in CI.
- **`.env.example` services go by category, not by vendor** (`PAYMENTS_API_KEY`,
  `STORAGE_*`, `ERROR_TRACKING_DSN`…), and `scripts/backup-db.sh` speaks generic S3
  instead of naming a provider.

### Removed

- `.github/FUNDING.yml`, `.github/CODEOWNERS.example` and the `support_question` and
  `documentation_request` issue templates. Bug, feature and task remain.
- `docs/glossary.md` and `.github/labeler.yml` (see the table above).

### Fixed

- **`check-links.sh` and `check-placeholders.sh` failed silently** when a git-tracked
  file was no longer on disk: perl spat out its raw error, the file went unchecked and
  the summary called everything good. Now they are counted and reported.
- **`check-links.sh` did not see untracked files**, which is exactly the state you are in
  when adopting the template in an existing project.
- **`ci.example.yml` actually ran.** GitHub runs any `.yml` under `.github/workflows/`:
  it showed up as a green "CI" workflow testing nothing. It is now `ci.yml.example`, and
  a bench test verifies it.

### Security

## v1.4.0 and earlier

The history up to `v1.4.0` lives in the repository's [release notes](https://github.com/brayandiazc/project-starter-template-en/releases).
It is not reconstructed here: making it up would be worse than not having it.

<!--
Version comparison links:
[Unreleased]: https://github.com/brayandiazc/project-starter-template-en/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/brayandiazc/project-starter-template-en/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/brayandiazc/project-starter-template-en/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/brayandiazc/project-starter-template-en/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/brayandiazc/project-starter-template-en/compare/v1.4.0...v2.0.0
-->
