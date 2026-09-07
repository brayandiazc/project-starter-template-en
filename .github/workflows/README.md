# CI/CD workflows

This repository's [GitHub Actions](https://docs.github.com/actions) workflows.

## Active (stack-agnostic)

They work as-is, whatever the project's language — do not delete them when instantiating:

- [`quality.yml`](quality.yml) — documentation and tooling health: Markdown formatting
  (Prettier), internal links, placeholders, README instructions, raw colors in
  the views, template inheritance, the [`../scripts/`](../scripts) test suite and, on
  every PR, the `CHANGELOG.md` entry under `## [Unreleased]` — the `no-changelog` label
  is the explicit exception. On PRs toward `main` it adds the release step: nothing
  reaches production without a cut version.
- [`secret-scan.yml`](secret-scan.yml) — history scanning with
  [gitleaks](https://github.com/gitleaks/gitleaks).
- [`release.yml`](release.yml) — on merging into `main`, it creates the `vX.Y.Z` tag and
  the GitHub release with that changelog section's notes. **It does not publish a version
  inherited from the template** (it consults `check-inheritance.sh --publishable-version`):
  a `main` published before resetting the CHANGELOG created a foreign tag that later made
  the project's own release disappear silently.
- [`template-update-check.yml`](template-update-check.yml) — **it only acts on
  instantiated projects** (it needs `.template-origin`). Weekly it compares the tooling
  with the origin template's and opens an issue if there are improvements.

## Included skeleton

- [`ci.yml.example`](ci.yml.example) — a neutral pipeline (lint → test → build). The
  `.example` extension goes **last on purpose**: GitHub runs any `.yml`/`.yaml` file
  living in this folder, no matter what else the name carries. Rename it to `ci.yml` and
  replace the `[*_COMMAND]` placeholders with your stack's. Until then, the repository
  runs no code tests — only the documentation checks.

## Rules of this folder

**If a file must not run, it cannot end in `.yml` or `.yaml`.** GitHub runs any file
that lives here, no matter what else the name carries. The test suite verifies it.

**One job per workflow unless there is a measured reason to split it.** GitHub bills each
job rounding up to the minute, so nine two-second jobs cost nine minutes. `quality.yml`
used to run that way and is now a single job with `!cancelled()` on every step —you still
see every failure at once— plus `concurrency` with `cancel-in-progress`. Splitting only
makes sense when a step really takes time and blocks the others.

**One run per change, not two.** `quality.yml` triggers **only on `pull_request`**:
GitHub runs those events against the _simulated merge commit_, so the run that fired on
merging checked the same tree again. It was half the repository's runs. `secret-scan.yml`
does keep `push` on `main`, because without branch protection nothing technically stops a
direct push to production and there the history scan is a real backstop.

**The first filter is local.** The `.githooks/pre-push` hook runs these same checks in
~15 seconds before publishing, so CI is the safety net and not the verification loop (see
`docs/conventions/quality-tooling.md`).

> **The cost of this, plainly:** a commit that reaches `develop` **without going through
> a PR** is verified by nobody on the server. Only `pre-push` prevents it, and only if
> that clone has `core.hooksPath` set. If one day there is branch protection —it requires
> a public repo or a Pro plan— that is the barrier that really closes the gap.

## Secrets

Define them under **Settings → Secrets and variables → Actions**. The values come from
your credential manager — see [`../../docs/conventions/secrets.md`](../../docs/conventions/secrets.md).
