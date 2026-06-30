# [NOMBRE_DEL_PROYECTO] Documentation

Map of the project documentation. Start here to find out which document
answers each question.

| Document                                                       | Question it answers                           | When to read it                          |
| -------------------------------------------------------------- | --------------------------------------------- | ---------------------------------------- |
| [`architecture/architecture.md`](architecture/architecture.md) | How is the system built?                      | When understanding the big picture       |
| [`architecture/stack.md`](architecture/stack.md)               | With which technologies and versions?         | When setting up the environment          |
| [`architecture/database.md`](architecture/database.md)         | What entities and relationships exist?        | When working with data                   |
| [`architecture/auth.md`](architecture/auth.md)                 | How do you sign in and what is allowed?       | When touching authentication/permissions |
| [`architecture/api.md`](architecture/api.md)                   | What endpoints does it expose?                | When integrating or consuming the API    |
| [`architecture/design.md`](architecture/design.md)             | How does it look and why?                     | When designing features or UI            |
| [`product/business-model.md`](product/business-model.md)       | Why does it exist / how does it create value? | To understand the business               |
| [`product/roadmap.md`](product/roadmap.md)                     | Where is it heading?                          | To learn the priorities                  |
| [`decisions/`](decisions/README.md)                            | Why did we make each decision?                | Before re-debating something             |
| [`conventions/`](conventions/README.md)                        | How do we work in this repo?                  | Before writing code                      |
| [`glossary.md`](glossary.md)                                   | What does each term mean?                     | When facing unfamiliar vocabulary        |

## About the `architecture/` vs `conventions/` distinction

- **`architecture/`** describes **this** specific project (its data model, its
  auth, its API).
- **`conventions/`** describes **reusable rules** about how we work
  (how we model data, how we authenticate, how we test) — cross-cutting across
  any feature.

## How to maintain this documentation

- Update the **"Last updated"** line when editing a document.
- Record relevant decisions as [ADRs](decisions/README.md).
- Keep this index up to date if you add or remove documents.
