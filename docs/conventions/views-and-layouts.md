# Views and layouts conventions

> How we organize views, layouts and shared UI in [PROJECT_NAME].
> **Last updated**: [DATE]

## Layouts

| Layout          | Use                                    |
| --------------- | -------------------------------------- |
| [PUBLIC_LAYOUT] | Public pages (landing, marketing)      |
| [AUTH_LAYOUT]   | Authentication screens (login/sign-up) |
| [APP_LAYOUT]    | Authenticated product (dashboard)      |

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
[VIEWS_PATH]/
├── layouts/
├── shared/        # reusable partials
└── [resource]/    # views per resource
```

## References

- [`design-system.md`](design-system.md)
- [`seo.md`](seo.md)
