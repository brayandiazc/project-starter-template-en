<!--
  ┌─────────────────────────────────────────────────────────────────────────┐
  │  This is a TEMPLATE. Before publishing your project:                      │
  │  1. Read TEMPLATE-USAGE.md to learn how to instantiate it.               │
  │  2. Replace every [PLACEHOLDER] (find them with grep, see the guide).     │
  │  3. Delete this comment.                                                  │
  └─────────────────────────────────────────────────────────────────────────┘
-->

# [PROJECT_NAME]

A short, concise description of the project (1-2 lines).

![Quality](https://github.com/[GITHUB_USER]/[REPOSITORY_SLUG]/actions/workflows/quality.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue)

## Description

What problem it solves, for whom, and what changes for that person. The current
version's scope is in [`docs/product/roadmap.md`](docs/product/roadmap.md).

## Prerequisites

- **[RUNTIME]** v[VERSION] or later
- **[PACKAGE_MANAGER]** v[VERSION] or later
- **[DATABASE]** v[VERSION] or later

## Installation

```bash
git clone [REPOSITORY_URL]
cd [REPOSITORY_SLUG]
git config core.hooksPath .githooks   # ← once per clone, it does not travel in the repo
[INSTALL_DEPENDENCIES_COMMAND]
cp .env.example .env                  # fill in the values; never commit it
[MIGRATIONS_COMMAND]
```

> The first line is not optional. Without it the hooks do not run: `pre-commit` does
> not format and `pre-push` does not verify before publishing, so failures get found
> in CI — slower and, on a private repository, on a metered budget.

The variables are documented in [`.env.example`](.env.example). The real values come
from your credential manager, not from the repository — see
[`docs/conventions/secrets.md`](docs/conventions/secrets.md).

## Usage

```bash
[START_DEV_COMMAND]   # http://localhost:[PORT]
[TEST_COMMAND]        # test suite
[LINT_COMMAND]        # lint / format
[BUILD_COMMAND]       # production build
```

## Stack

**[CHOSEN]**. What was chosen for this product is in
[`docs/architecture/stack.md`](docs/architecture/stack.md); the why behind each
decision, in [`docs/decisions/`](docs/decisions/README.md).

## Deployment

| Environment | URL              | Branch    | Deploy    |
| ----------- | ---------------- | --------- | --------- |
| Development | [DEV_URL]        | `develop` | Automatic |
| Production  | [PRODUCTION_URL] | `main`    | Manual    |

The procedure is in [`docs/conventions/deploy.md`](docs/conventions/deploy.md).

## Documentation

The full map —which document answers which question— is in
**[`docs/README.md`](docs/README.md)**. The most used shortcuts:

- [`docs/architecture/stack.md`](docs/architecture/stack.md) — what it is built with
- [`docs/product/roadmap.md`](docs/product/roadmap.md) — what is done and what comes next
- [`docs/conventions/`](docs/conventions/README.md) — how the work is done here
- [`docs/decisions/`](docs/decisions/README.md) — why each thing was decided

## Contributing

Workflow, branching and commit format in [`CONTRIBUTING.md`](CONTRIBUTING.md).
Vulnerability reports in [`SECURITY.md`](SECURITY.md).

## Versioning and license

[Semantic Versioning](https://semver.org/) and [Keep a Changelog](CHANGELOG.md).
Licensed under [MIT](LICENSE).

---

⌨️ with ❤️ by [@[GITHUB_USER]](https://github.com/[GITHUB_USER])
