# Branding conventions

> Visual identity and brand asset management for [NOMBRE_DEL_PROYECTO].
> For UI tokens and components see [`design-system.md`](design-system.md).
> **Last updated**: [FECHA]

## Logos

| Asset              | Source file        | Use                      |
| ------------------ | ------------------ | ------------------------ |
| Isotype (symbol)   | `[RUTA_LOGO_MARK]` | Favicon, app icon        |
| Logotype (text)    | `[RUTA_LOGO]`      | Header, materials        |
| Monochrome version | `[RUTA_LOGO_MONO]` | Single-color backgrounds |

- Keep the sources in vector format (SVG) and generate the rasterized ones from there.

## Palette and typography

- Defined as tokens in the [design system](design-system.md).
- **Brand colors**: [primary], [secondary], [accent].
- **Typefaces**: [headings family], [body family].

## Usage rules

- Respect the clear space (protected area) around the logo.
- Do not distort, recolor or apply unauthorized effects to the logo.
- Use the appropriate variant depending on the background (light/dark/color).

## Assets

```text
[RUTA_ASSETS_MARCA]/
├── logo.svg
├── logo-mark.svg
└── og-image.png   # 1200×630 for sharing on social media
```

## References

- [`design-system.md`](design-system.md)
- [Full brand guide, if it exists].
