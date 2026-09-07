# Default visual identity

> **The structure is inherited; the values are replaced.** Every product is its own
> brand —its name, its site and its palette— so what is reusable here are the semantic
> tokens, the two themes, AA contrast and the four data states.
> The palette that ships in `tokens.css` is a **deliberately neutral starting point**,
> not a mandate: it exists so no product starts with undefined colors, which is what
> produces the generic-template look. Re-branding is normal, not a deviation:
> you touch the values in `tokens.css` and nothing else.
> The per-product assets (logo, social image) are recorded in
> [`../docs/conventions/ui.md`](../docs/conventions/ui.md).

The tokens live in a single place:

- [`tokens.css`](tokens.css) — **the single source of truth.** The palette in `:root` as
  standard CSS custom properties, dark via `prefers-color-scheme` and via
  `[data-theme="dark"]`, and at the end an **adapter** block that exposes them to
  whichever UI framework you use (or none). (There used to be a `tokens.json` "mirror
  for JS": it was a hand-made copy nobody consumed and had already drifted — if a stack
  ever needs the values as JSON, it is **generated** from this CSS and added to the
  `design-md.sh` check, not copied.)
- [`preview.html`](preview.html) — **open it in the browser to decide the palette.** It
  links `tokens.css` directly and only uses `var(--token)`: it does not copy a single
  value, so it cannot drift. It shows the component inventory applied —the palette with
  its AA contrast computed live, typography, buttons with their five states, a form, the
  four data states, surfaces and a "tool" register (toolbar, panel, timeline) for
  products that are not a document SaaS.

> **`preview.html` validates tokens, not layouts.** It answers "does this color work?",
> not "how does my product look?". The product's views are laid out when they are needed
> and are not versioned here: a sample landing page ages and ends up contradicting the
> tokens. The preview does not, because it only shows primitives.

> Selection criterion for everything that follows: **open source only** (MIT/OFL/ISC/BSD)
> — nothing with a restrictive or paid license on the stack's critical path.

## UI framework (web)

**You fill this table in.** The system **does not depend on any technology**: design can
be built however you like —a utility framework, a component one, a preprocessor, plain
CSS, a company system of your own— because what rules are the tokens in `tokens.css` and
not anybody's utilities. What follows are the **questions** to answer and the criterion
for answering them.

| Piece         | Choice               | Criterion for choosing                                                                                         |
| ------------- | -------------------- | -------------------------------------------------------------------------------------------------------------- |
| CSS           | [TOOL]               | That it can read your tokens as variables, without duplicating the values                                      |
| Components    | [TOOL]               | That it brings no aesthetic of its own: the look belongs to the product (see below)                            |
| Primitives    | Native HTML          | `<dialog>`, `<details>`, `popover`: focus, keyboard and Escape already solved                                  |
| Interactivity | [FRONTEND_FRAMEWORK] | Whatever your stack already uses; recorded in [`../docs/architecture/stack.md`](../docs/architecture/stack.md) |

**Golden rule, and this one is not filled in**: semantic tokens (`primary`, `base-100`,
`base-content`), **never** raw colors —not an inline hex, not a framework palette utility
(`bg-blue-500`, `--bs-blue`, `$gray-700`)—. It is what lets you re-brand the product by
touching a single block of `tokens.css`, and CI verifies it.

**The criterion that IS part of the system: zero visual opinion in the component layer.**
A library that brings its own look —any UI kit with factory aesthetics, bought or free—
produces the look shared by thousands of sites, which is exactly the drift to "generic
SaaS template" this document exists to avoid. And, being CSS, it does **not** solve
behavior (focus trap, Escape, ARIA, keyboard), which is where agent-generated code really
fails. You pay for the wrong advantage.

What does work is a **headless** layer: accessibility and behavior solved, zero styles.
The browser's native primitives are the free version of that, and almost every ecosystem
has its headless equivalent — search for that word. The few components of your own that
remain get reviewed by hand.

> **The only exception to the colors: third-party logos.** Google's "G", GitHub's logo or
> Stripe's carry their exact brand colors — re-tinting them with our tokens violates their
> brand guidelines. The `<svg>` is marked with `data-brand="<brand>"` and the CI check
> respects it; the container (button, card) does use our tokens, so it works in both
> themes. The typical case: the "sign in with Google" button. Outside that `<svg>`, a hex
> still fails.

## Palette (the `base` theme)

**The values are not listed here** — another hand-made copy would drift without anything
detecting it. [`tokens.css`](tokens.css) is the single source, and each token's role is
commented inside the file itself.

- **Light and dark mode from day 1**: `tokens.css` ships both palettes; dark responds to
  `prefers-color-scheme` **and** to `data-theme="dark"`, so the UI toggle wins in both
  directions. Every view is reviewed in both modes before being called done.
- **Multilingual by default**: no hardcoded strings in views — every visible text goes
  through i18n (`docs/conventions/i18n.md`).
- Secondary text: `base-content` with opacity (`text-base-content/70`), not a new grey.
- Minimum WCAG AA contrast (4.5:1 normal text, 3:1 large text) — in both themes.
- **Brand derivation**: the product's brand color is fixed; the `primary`/`accent` tokens
  adjust it **by lightness** in each theme, only as much as needed to keep AA. If the
  brand color does not reach the contrast, the token is adjusted and the brand lives in
  the logo, not in the buttons.

## Typography

| Role               | Family               | License | Fallback                 | Note                                                 |
| ------------------ | -------------------- | ------- | ------------------------ | ---------------------------------------------------- |
| Headings / display | **Space Grotesk**    | OFL     | ui-sans-serif, system-ui | Gives identity without being exotic; weights 500–700 |
| UI and body        | **Inter** (variable) | OFL     | ui-sans-serif, system-ui | Maximum legibility at small sizes                    |
| Code               | **JetBrains Mono**   | OFL     | ui-monospace, monospace  | Snippets, `kbd`, data                                |

- Why two families: Inter alone is safe but generic (it is half the internet's default);
  Space Grotesk in headings adds character while keeping the same geometric base. If a
  product wants maximum sobriety, it can keep only Inter — the `--font-display` token
  falls back to `--font-sans`.
- Scale: a fixed, short type scale (your framework's, or define it in `tokens.css`).
  Weights 400/500/600/700 — no more than four.
- Self-hosted loading via [Fontsource](https://fontsource.org) (variable fonts) — no
  Google Fonts at production runtime.

## Iconography

- **A single set: [Lucide](https://lucide.dev)** (ISC license) — 2px stroke, base size
  20/24px. Chosen for cross-platform coverage with official/maintained packages: one
  package per ecosystem (web, component framework, mobile) — the same icon looks the same
  on web and on mobile.
- **Documented alternative: [Phosphor](https://phosphoricons.com)** (MIT) — use it only
  if the product needs weight variants (thin/regular/bold/fill/duotone) as part of the
  visual language; it also covers web and React Native.
- Do not mix sets in one product. Emoji only in content, never as UI icons.
- **The only exception, the language switcher**: the flag accompanies the language name,
  it never replaces it (`🇪🇸 Español`, not `🇪🇸` alone). Worth remembering that flags are
  countries and not languages — Spanish is not only Spain's —; they are used because they
  are recognized at a glance, and that is why the text rules.

## Geometry

- Radii: `rounded-field` (`0.5rem`) on fields and buttons, `rounded-box` (`0.75rem`) on
  cards and modals. Both come from `tokens.css`.
- 1px borders with `base-300`; flat depth (no heavy shadows) — elevation is communicated
  with border + background, not with shadow.
- Spacing: a fixed scale based on multiples of 4px, your framework's or your own. What
  matters is not which, but that **there are no loose values** outside it.

## Motion (animation and effects)

A closed stack, all open source. General rule: **one engine per view** (two engines
double the bundle and fight over the `requestAnimationFrame`).

| Need                                      | Choice                                                                      | License | Note                                                           |
| ----------------------------------------- | --------------------------------------------------------------------------- | ------- | -------------------------------------------------------------- |
| Hover, focus, states                      | CSS `transition` (the `--motion-*` tokens)                                  | —       | 80% of the UI needs no JS                                      |
| App UI (modals, lists, layout)            | **[Motion](https://motion.dev)**                                            | MIT     | React, vanilla JS and Vue; springs, gestures, layout           |
| Transitions between pages                 | **View Transitions API** (native)                                           | —       | Evaluate it before reaching for a library                      |
| Scroll on landings (reveals, sequences)   | Motion's scroll utilities + **[Lenis](https://lenis.darkroom.engineering)** | MIT     | Lenis only in marketing, never in apps                         |
| Animation coming from design              | **Lottie** (lottie-web/dotLottie) or **Rive** (runtimes)                    | MIT     | Rive when it must react to input (state machines)              |
| 3D (viewers, heroes)                      | **Three.js + React Three Fiber**                                            | MIT     | Dynamic import (`ssr: false`); only if the 3D justifies itself |
| Ready-made animated components (landings) | **Magic UI** / **Motion Primitives**                                        | MIT     | On top of Motion; so micro-interactions are not reinvented     |

- **GSAP is out of the default**: today it is free and excellent, but it is owned by
  Webflow and its license (not open source) forbids using it in products that compete
  with Webflow. Only with an ADR and after reviewing that clause.
- Durations: 150ms micro-interactions, 200–300ms enter/exit; `ease-out` on the way in,
  `ease-in` on the way out. Entries: fade + 8px translate-y. No bounces or parallax by
  default.
- Loading: a **skeleton** shaped like the content that is coming (preferred) or a spinner
  — never the text "Loading…".
- **Always** respect `prefers-reduced-motion: reduce` (Motion ships it with
  `useReducedMotion`; the CSS in `tokens.css` already disables the decorative part).

### Motion on mobile

If the product reaches native mobile, the rule does not change: use the engine that runs
on the framework's **UI thread**, and a layer on top only if it genuinely reduces
boilerplate. Lottie and Rive have official runtimes in the main mobile ecosystems.

## Supporting JS libraries (pick from here, do not improvise)

| Need              | Default                                | Note                                               |
| ----------------- | -------------------------------------- | -------------------------------------------------- |
| Charts            | Chart.js                               | Apache ECharts if the dashboard is dense           |
| Data tables       | [TOOL]                                 | Sort/filter/paginate                               |
| Dates             | Native `Intl`; day.js if it gets hairy | No moment.js                                       |
| Forms (React)     | React Hook Form + Zod                  | Declarative validation, the schema is the contract |
| JS animation      | Motion                                 | Only when CSS is not enough                        |
| Data manipulation | Native JS (map/filter/groupBy)         | Lodash only for specific functions (`lodash-es`)   |

## Images, illustrations and vectors (approved sources)

This is where the assets for prototypes and the product get downloaded — all free and
with a license that allows commercial use (always verify the specific asset's license):

| Need                      | Source                                                                        | License / note                               |
| ------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------- |
| Illustrations (SVG)       | [unDraw](https://undraw.co)                                                   | Open license; the color adjusts to `primary` |
| Photos                    | [Unsplash](https://unsplash.com) / [Pexels](https://pexels.com)               | Free licenses; no mandatory attribution      |
| Third-party brand logos   | [Simple Icons](https://simpleicons.org)                                       | CC0; respect each brand's guidelines         |
| Sample avatars            | [DiceBear](https://dicebear.com)                                              | Open-source API/library; for sample data     |
| Background patterns (SVG) | [Hero Patterns](https://heropatterns.com)                                     | CC BY 4.0                                    |
| Image placeholders        | [picsum.photos](https://picsum.photos) / [placehold.co](https://placehold.co) | Prototypes only, never to production         |
| Icons                     | Lucide (see Iconography)                                                      | ISC                                          |

Rules of use:

- **Optimize before committing**: SVG through [SVGO](https://svgo.dev); photos to
  WebP/AVIF at the real render width. Heavy assets go to the file storage, not the repo.
- **`alt` always** (descriptive, or `alt=""` if decorative) — it is part of the
  accessibility baseline.
- One illustration style per product (same as the icons: do not mix).
- No watermarked stock or dubiously licensed assets "for now".

## Mandatory states per view

Every view that loads data explicitly handles: **loading** (skeleton), **empty** (icon +
text + a CTA that orients), **error** (`alert-error` + retry) and **success**. The CI
`Design system` job can only verify the colors; the four states are reviewed by eye.

All four are reviewed **in both themes** before a view is called done. The empty state is
the one most often forgotten and the one that most defines the product: an icon, a
sentence explaining why it is empty and a CTA that orients — never a blank table.

## Per-project brand assets

What does change per project (logo, name, social image, and the palette if the product
demands its own identity) is recorded in
[`../docs/conventions/ui.md`](../docs/conventions/ui.md) → Brand assets. To change the
branding you touch **only the values in `tokens.css`** — not the structure.
