# CI/CD Workflows

This folder contains the project's [GitHub Actions](https://docs.github.com/actions)
workflows.

## Active workflows (stack-agnostic)

They work as is, regardless of the project's language — don't delete them when
instantiating:

- [`quality.yml`](quality.yml) — documentation quality: Markdown format
  (Prettier), internal links, placeholders, and the test suite for the repo's
  scripts (see [`../scripts/`](../scripts)).
- [`secret-scan.yml`](secret-scan.yml) — secret scanning with
  [gitleaks](https://github.com/gitleaks/gitleaks) over the history.

## Template-repo only

- [`template-parity.yml`](template-parity.yml) — compares the structure with the
  sibling variant in the other language. It has a repository-name guard so it
  doesn't run in instantiated projects; delete it anyway when you instantiate
  the template.

## Included Skeleton

- [`ci.yml.example`](ci.yml.example) — a neutral CI pipeline (lint → test → build).
  The `.example` extension comes **last on purpose**: GitHub runs any `.yml`/`.yaml`
  file living in this folder, no matter what else the name contains. When you adapt it
  to your stack, rename it to `ci.yml`.

> Rule for this folder: if a file must not run, it **cannot end in `.yml` or
> `.yaml`**. The test suite checks this.

## Recommended Workflows

| Workflow                    | Purpose                                       |
| --------------------------- | --------------------------------------------- |
| `ci.yml`                    | Lint, tests, and build on every push/PR.      |
| `labeler.yml`               | Auto-labeling of PRs (uses `../labeler.yml`). |
| `dependabot-auto-merge.yml` | Auto-merge Dependabot PRs (patches).          |
| `deploy.yml`                | Deployment (depends on your infrastructure).  |

## Secrets

Define the secrets your workflows need (deploy keys, tokens, etc.) in
**Settings → Secrets and variables → Actions**. See
[`../../docs/conventions/secrets.md`](../../docs/conventions/secrets.md).
