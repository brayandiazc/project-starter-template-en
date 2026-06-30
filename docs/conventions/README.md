# Conventions

This folder documents **how we work** in [NOMBRE_DEL_PROYECTO]: cross-cutting
rules and standards that apply to day-to-day work, independent of any specific
feature.

> Difference with `docs/architecture/`: here go the **rules** ("how we model
> data"); in `architecture/` goes **this** project in particular ("what our
> data model is").

## Included conventions

| Convention                                         | Topic                              |
| -------------------------------------------------- | ---------------------------------- |
| [authentication.md](authentication.md)             | Authentication and authorization   |
| [branding.md](branding.md)                         | Brand identity and assets          |
| [database.md](database.md)                         | Data modeling and migrations       |
| [deploy.md](deploy.md)                             | Deployment and operations          |
| [design-system.md](design-system.md)               | Design system and components       |
| [i18n.md](i18n.md)                                 | Internationalization               |
| [quality-tooling.md](quality-tooling.md)           | Linters, formatting and git hooks  |
| [secrets.md](secrets.md)                           | Secrets and credentials management |
| [seo.md](seo.md)                                   | SEO and metadata                   |
| [testing.md](testing.md)                           | Testing strategy and standards     |
| [transactional-emails.md](transactional-emails.md) | Transactional emails               |
| [views-and-layouts.md](views-and-layouts.md)       | Views, layouts and shared UI       |

## Adding a convention

Copy [`_template.md`](_template.md), rename it in `kebab-case` and document the
new topic. Add it to the table above.

## Optional additional conventions

Not included by default; create them with `_template.md` if your project needs them.

- **Generic / SaaS**: payments, webhooks, multi-tenancy, PWA, administration,
  legal acceptance, observability.
- **Mobile**: store release (versioning, signing/code-signing, screenshots and ASO),
  device permissions, push notifications, offline mode.
- **Desktop**: packaging and installers per OS, code signing and notarization,
  auto-update, telemetry / crash reporting.

> See [`TEMPLATE-USAGE.md`](../../TEMPLATE-USAGE.md) § "Adapt by project type"
> for what to delete and what to refocus depending on whether it's web, mobile or desktop.
