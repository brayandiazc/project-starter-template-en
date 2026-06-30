# Design system conventions

> UI tokens, components and rules for [NOMBRE_DEL_PROYECTO].
> For the product's technical/UX design see
> [`../architecture/design.md`](../architecture/design.md).
> **Last updated**: [FECHA]

## Stack

- **Component library**: [LIBRERÍA].
- **Styling solution**: [SOLUCIÓN].
- **Live reference page** (if applicable): `[URL_DESIGN_SYSTEM]`.

## Tokens

| Token           | Use                          |
| --------------- | ---------------------------- |
| Colors          | [primary, secondary, states] |
| Typography      | [families, scales]           |
| Spacing         | [spacing scale]              |
| Borders/shadows | [radii, elevations]          |

> Use **semantic tokens** (e.g. `color-primario`), not raw values, in components.

## Allowed components

- Use the library's components; avoid creating ad-hoc variants.
- Each component must account for its **states**: normal, hover, focus, disabled, loading, error.

## Accessibility (baseline)

- Minimum contrast target: WCAG [AA/AAA].
- Visible focus and keyboard navigation.
- ARIA roles/attributes where appropriate.

## Anti-patterns

- Hardcoded color/spacing values outside the tokens.
- Duplicated components that reimplement something existing.

## References

- [Component library documentation].
