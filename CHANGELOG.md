# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

## [0.1.0] - [DATE]

### Added

- Initial release.

<!--
Version comparison links (adjust to your repository):
[Unreleased]: [REPOSITORY_URL]/compare/v0.1.0...HEAD
[0.1.0]: [REPOSITORY_URL]/releases/tag/v0.1.0
-->
