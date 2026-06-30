# SEO conventions

> SEO metadata and best practices in [NOMBRE_DEL_PROYECTO].
> **Last updated**: [FECHA]

## What the shared head emits

Every page must provide, through the shared layout/head:

- A unique and descriptive `<title>`.
- `<meta name="description">`.
- Open Graph: `og:title`, `og:description`, `og:image`, `og:url`, `og:type`.
- Twitter Card: `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`.
- `<link rel="canonical">`.
- `<meta name="robots">` depending on the page.

## Indexing rules

| Page type                      | robots          |
| ------------------------------ | --------------- |
| Public (landing, blog)         | `index, follow` |
| Authentication (login/sign-up) | `noindex`       |
| Private areas (dashboard)      | `noindex`       |

## Rules

- A single canonical tag per page.
- OG image with recommended dimensions (1200×630).
- Readable and stable URLs; avoid unnecessary parameters.
- `sitemap.xml` and `robots.txt` kept up to date.

## Examples

```html
<meta name="description" content="[Descripción de la página]" />
<meta property="og:image" content="[URL_IMAGEN_OG]" />
```

## References

- [Your framework's SEO documentation].
