<!--
  ┌─────────────────────────────────────────────────────────────────────────┐
  │  This is a TEMPLATE. Before publishing your project:                       │
  │  1. Read TEMPLATE-USAGE.md to learn how to instantiate it.                 │
  │  2. Replace every [PLACEHOLDER] (find them with grep, see the guide).      │
  │  3. Delete the documents that don't apply to your project.                 │
  │  4. Remove this comment.                                                   │
  └─────────────────────────────────────────────────────────────────────────┘
-->

# [NOMBRE_DEL_PROYECTO]

Short, concise description of the project (1-2 lines).

![Build](https://img.shields.io/badge/build-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-0%25-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Available Scripts](#available-scripts)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)
- [Documentation](#documentation)
- [Support](#support)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)
- [Support Us](#support-us)
- [Acknowledgments](#acknowledgments)

## Description

Detailed description of the project, its purpose and the problem it solves. Explain the context and how this project adds value.

### How It Works

```mermaid
graph LR
    A[User] -->|Request| B[Authentication]
    B -->|Token| C[API Layer]
    C -->|Validation| D{Authorized?}
    D -->|Yes| E[Business Logic]
    D -->|No| F[401 Error]
    E -->|Query| G[(Database)]
    G -->|Response| E
    E -->|Result| C
    C -->|Response| A
```

## Features

- ✅ Main feature 1
- ✅ Main feature 2
- ✅ Main feature 3
- 🚧 Feature in progress
- 📋 Planned feature

## Prerequisites

Before you begin, make sure you have installed:

- **[RUNTIME]**: v[VERSION] or higher
- **[GESTOR_DE_PAQUETES]**: v[VERSION] or higher
- **[BASE_DE_DATOS]**: v[VERSION] or higher
- **[OTRA_HERRAMIENTA]**: v[VERSION] or higher

### Required Access

- Access to the repository
- Credentials for [SERVICIO/API]
- [OTROS_ACCESOS] (if applicable)

## Installation

### 1. Clone the repository

```bash
git clone [URL_REPOSITORIO]
cd [NOMBRE_DEL_PROYECTO]
```

### 2. Install dependencies

```bash
[COMANDO_INSTALAR_DEPENDENCIAS]
```

### 3. Configure environment variables

```bash
cp .env.example .env
# Edit .env with your credentials
```

### 4. Initialize the database (if applicable)

```bash
[COMANDO_MIGRACIONES]
[COMANDO_SEEDS]
```

## Configuration

Environment variables are documented in [`.env.example`](.env.example). Copy it to `.env` and fill in the values for your environment.

> Never commit your `.env` file with real values to the repository. See [SECURITY.md](SECURITY.md) and [`docs/conventions/secrets.md`](docs/conventions/secrets.md).

## Usage

### Local development

```bash
[COMANDO_INICIAR_DESARROLLO]
# The app will be available at http://localhost:[PUERTO]
```

### Usage examples

```bash
# Example command or representative call
[EJEMPLO]
```

For the full API contract, see [`docs/architecture/api.md`](docs/architecture/api.md).

## Architecture

Summary of how the system is built. Full detail in [`docs/architecture/architecture.md`](docs/architecture/architecture.md).

## Tech Stack

Summary of the main technologies. Full inventory (with versions and rationale) in [`docs/architecture/stack.md`](docs/architecture/stack.md).

## Available Scripts

```bash
[COMANDO_DESARROLLO]   # Start in development mode
[COMANDO_BUILD]        # Build for production
[COMANDO_TEST]         # Run tests
[COMANDO_LINT]         # Linting / formatting
```

## Testing

```bash
[COMANDO_TEST]            # All tests
[COMANDO_TEST_COBERTURA]  # With coverage report
```

Testing conventions in [`docs/conventions/testing.md`](docs/conventions/testing.md).

## Deployment

| Environment | URL              | Branch    | Deploy    |
| ----------- | ---------------- | --------- | --------- |
| Development | [URL_DEV]        | `develop` | Automatic |
| Staging     | [URL_STAGING]    | `staging` | Automatic |
| Production  | [URL_PRODUCCION] | `main`    | Manual    |

Detailed procedure in [`docs/conventions/deploy.md`](docs/conventions/deploy.md).

## Contributing

Read the [Contributing Guide](CONTRIBUTING.md) to learn about the workflow (Git Flow), code standards, commit format (Conventional Commits) and the Pull Request process.

## Troubleshooting

#### Error: "[MENSAJE_DE_ERROR_COMÚN]"

```bash
# Steps to diagnose and fix
[COMANDO]
```

### Getting help

1. Check the [documentation](docs/README.md).
2. Search the [existing issues]([URL_REPOSITORIO]/issues).
3. Open a new issue or contact [EMAIL_SOPORTE].

## Roadmap

Vision and next steps in [`docs/product/roadmap.md`](docs/product/roadmap.md).

## Documentation

All documentation lives under [`docs/`](docs/README.md):

| Document                                                                 | Answers                                       |
| ------------------------------------------------------------------------ | --------------------------------------------- |
| [`docs/architecture/architecture.md`](docs/architecture/architecture.md) | How is it built?                              |
| [`docs/architecture/stack.md`](docs/architecture/stack.md)               | With which technologies?                      |
| [`docs/architecture/database.md`](docs/architecture/database.md)         | What entities and relationships?              |
| [`docs/architecture/api.md`](docs/architecture/api.md)                   | What endpoints does it expose?                |
| [`docs/architecture/auth.md`](docs/architecture/auth.md)                 | How does authentication & authorization work? |
| [`docs/architecture/design.md`](docs/architecture/design.md)             | How is it designed and why?                   |
| [`docs/product/business-model.md`](docs/product/business-model.md)       | Why does it exist / how does it create value? |
| [`docs/product/roadmap.md`](docs/product/roadmap.md)                     | Where is it headed?                           |
| [`docs/decisions/`](docs/decisions/README.md)                            | Why did we make each decision?                |
| [`docs/conventions/`](docs/conventions/README.md)                        | How do we work in this repo?                  |

## Support

Problems or suggestions? Open an issue in [the repository]([URL_REPOSITORIO]/issues) or write to [EMAIL_SOPORTE].

## Versioning

We use [Git](https://git-scm.com) for version control and follow [Semantic Versioning](https://semver.org/). Check the [tags]([URL_REPOSITORIO]/tags) for available versions and the [CHANGELOG](CHANGELOG.md).

## Authors

- **[AUTOR]** — _Initial work_ — [@[USUARIO_GITHUB]](https://github.com/[USUARIO_GITHUB])

See also the list of [contributors]([URL_REPOSITORIO]/contributors).

## License

This project is licensed under the [MIT](LICENSE) license.

## Support Us

If you find this project useful and want to support its development:

- [GitHub Sponsors](https://github.com/sponsors/[USUARIO_GITHUB])
- [Ko-fi](https://ko-fi.com/[USUARIO_GITHUB])
- [Patreon](https://patreon.com/[USUARIO_GITHUB])

## Acknowledgments

Thanks to everyone who contributes to this project. If you find value in it, you can:

- Share the project 📤
- Buy a coffee ☕
- Open an issue or PR 🙌
- Leave your thanks with a comment 💬

---

⌨️ with ❤️ by [@[USUARIO_GITHUB]](https://github.com/[USUARIO_GITHUB])
