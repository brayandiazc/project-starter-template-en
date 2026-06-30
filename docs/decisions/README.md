# Architecture Decisions (ADRs)

This folder records the project's **architecture decisions** through
_Architecture Decision Records_ (ADRs): short documents that capture a
relevant decision, its context, and its consequences.

## What is an ADR and when to create one?

Create an ADR when you make a decision that is **hard or costly to reverse**,
affects several parts of the system, or that your future self (or a new team
member) will be glad to have documented. Examples: choosing a database, defining
the authentication model, adopting an architectural pattern, switching providers.

You don't need an ADR for trivial or easily reversible decisions.

## Numbering and Naming Convention

- Files: `NNNN-title-in-kebab-case.md` (sequential numbering starting at `0001`).
- The base template is [`0000-template.md`](0000-template.md) — copy it to create a new one.

## State Lifecycle

```
Proposed → Accepted → (eventually) Superseded by ADR-XXXX | Deprecated
```

- **Proposed**: under discussion.
- **Accepted**: current decision.
- **Superseded**: a later decision replaces it (link to the new ADR).
- **Deprecated**: no longer applies.

ADRs are **immutable** once accepted: instead of editing them, a new one is
created that supersedes the previous one.

## Index

| ADR                                           | Title                         | Status   |
| --------------------------------------------- | ----------------------------- | -------- |
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
