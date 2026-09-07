# Conventions

This folder documents **how we work** in [PROJECT_NAME]: cross-cutting rules and
standards that apply day to day, independent of any specific feature.

> Difference from `docs/architecture/`: the **rules** go here ("how we model data"); in
> `architecture/` goes **this** project specifically ("what our data model is").

## Included conventions

| Convention                                         | Topic                             |
| -------------------------------------------------- | --------------------------------- |
| [database.md](database.md)                         | Data modeling and migrations      |
| [definition-of-done.md](definition-of-done.md)     | What "done" means                 |
| [deploy.md](deploy.md)                             | Deployment and operations         |
| [i18n.md](i18n.md)                                 | Internationalization              |
| [quality-tooling.md](quality-tooling.md)           | Linters, formatting and git hooks |
| [secrets.md](secrets.md)                           | Handling secrets and credentials  |
| [seo.md](seo.md)                                   | SEO and metadata                  |
| [testing.md](testing.md)                           | Testing strategy and standards    |
| [ui.md](ui.md)                                     | Views, layouts and brand assets   |
| [transactional-emails.md](transactional-emails.md) | Transactional emails              |

## Adding a convention

Copy [`_template.md`](_template.md), rename it in `kebab-case` and document the new
topic. Add it to the table above.

## Optional extra conventions

They are not included by default; create them with `_template.md` if your project needs
them.

- **Generic / SaaS**: payments, webhooks, multi-tenancy, PWA, administration, legal
  acceptance, observability.
- **Mobile**: store releases (versioning, signing/code-signing, screenshots and ASO),
  device permissions, push notifications, offline mode.
- **Desktop**: packaging and installers per OS, code signing and notarization,
  auto-update, telemetry / crash reporting.

> **What does not go here**: the concrete stack (recorded by
> [`../architecture/stack.md`](../architecture/stack.md)) and the design system (it lives
> in [`design/`](../../design/README.md), with the tokens next to their guide).
> A convention that repeats one of those facts drifts out of sync without anyone noticing.
