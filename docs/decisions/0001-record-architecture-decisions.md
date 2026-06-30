# 0001. Record architecture decisions

- **Status**: Accepted
- **Date**: [FECHA]
- **Deciders**: [NOMBRES]

## Context and Problem

As the project evolves, architecture decisions are made whose context and
motivation are lost over time. Without a record, the team repeats debates that
were already settled, and new people don't understand why the system is the way
it is.

## Considered Options

- **Don't document** — rely on the team's memory and the commit history.
- **Document in a wiki** — easy to edit but disconnected from the code.
- **Architecture Decision Records (ADRs)** — files versioned alongside the code.

## Decision

We adopt lightweight **Architecture Decision Records (ADRs)** (MADR style),
versioned in `docs/decisions/`. Each relevant decision is documented with the
[`0000-template.md`](0000-template.md) template and numbered sequentially.

## Consequences

**Positive:**

- The "why" of each decision is recorded alongside the code.
- New people get up to speed faster.
- Re-litigating decisions already made is avoided.

**Negative / costs:**

- Requires discipline to create the ADR at the moment of deciding.

**Neutral / to watch:**

- Keeping the [README](README.md) index up to date.

## References

- [Documenting Architecture Decisions — Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [MADR — Markdown Architectural Decision Records](https://adr.github.io/madr/)
