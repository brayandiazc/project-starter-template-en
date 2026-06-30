# Views and layouts conventions

> How we organize views, layouts and shared UI in [NOMBRE_DEL_PROYECTO].
> **Last updated**: [FECHA]

## Layouts

| Layout           | Use                                    |
| ---------------- | -------------------------------------- |
| [LAYOUT_PUBLICO] | Public pages (landing, marketing)      |
| [LAYOUT_AUTH]    | Authentication screens (login/sign-up) |
| [LAYOUT_APP]     | Authenticated product (dashboard)      |

## Shared elements

- **Shared head**: metadata and SEO (see [`seo.md`](seo.md)).
- **Flash messages**: single pattern for success/error notifications.
- **Navigation**: reusable header/menu.

## Rules

- Reuse partials/components; do not duplicate markup.
- Each view accounts for its states: loading, empty, error and success.
- The UI follows the [design system](design-system.md).
- Separate structure (layout) from content (view) from behavior.

## Structure

```text
[RUTA_VISTAS]/
├── layouts/
├── shared/        # reusable partials
└── [recurso]/     # views per resource
```

## References

- [`design-system.md`](design-system.md)
- [`seo.md`](seo.md)
