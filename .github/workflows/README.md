# CI/CD Workflows

This folder contains the project's [GitHub Actions](https://docs.github.com/actions)
workflows.

Because the template is stack-agnostic, it **does not include ready-to-run
workflows**: only an example skeleton. Adapt it (or create your own) according to
your language and tooling.

## Included Skeleton

- [`ci.example.yml`](ci.example.yml) — a neutral CI pipeline (lint → test → build).
  It has the `.example` extension **on purpose** so that GitHub doesn't run it.
  When you adapt it to your stack, rename it to `ci.yml`.

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
