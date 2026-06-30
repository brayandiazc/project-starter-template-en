# Design — [NOMBRE_DEL_PROYECTO]

> Technical and product design decisions: how the problem is solved and
> how the product looks and feels. Relevant decisions are promoted to
> ADRs in [`../decisions/`](../decisions/README.md).
>
> **Last updated**: [FECHA]

## Context and goals

- **Problem**: [What is being solved].
- **Goals**: [What the design must achieve].
- **Non-goals**: [What is explicitly out of scope].

## Requirements

### Functional

- [Functional requirement].

### Non-functional

- [Performance, scalability, availability, security, accessibility…].

## Proposed design

- **General approach**: [Description of the solution].
- **Components and flows**: [How the pieces fit together → links to `architecture.md`].

## Alternatives considered

| Alternative   | Pros   | Cons   | Why was it discarded? |
| ------------- | ------ | ------ | --------------------- |
| [ALTERNATIVA] | [Pros] | [Cons] | [Reason]              |

## Visual identity and design system

- **Design principles**: [Clarity, consistency, etc.].
- **Tokens**: colors, typography, spacing.
- **Components**: allowed library/primitives.

## Accessibility

- Color contrast (WCAG [AA/AAA] target).
- Keyboard navigation and visible focus.
- ARIA roles/attributes where appropriate.

## Interface states

Every view must account for: **loading**, **empty**, **error** and **success**.

## Affected data model

Links to [`database.md`](database.md) if the design introduces or changes entities.

## Risks and mitigations

| Risk     | Impact            | Mitigation            |
| -------- | ----------------- | --------------------- |
| [RIESGO] | [High/Medium/Low] | [How it is mitigated] |

## Open questions

- [ ] [Pending question to resolve].
