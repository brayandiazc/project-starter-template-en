# [PROJECT_NAME] Documentation

Map of the project documentation. Start here to find out which document
answers each question.

| Document                                                       | Question it answers                           | When to read it                          |
| -------------------------------------------------------------- | --------------------------------------------- | ---------------------------------------- |
| [`architecture/architecture.md`](architecture/architecture.md) | How is the system built?                      | When understanding the big picture       |
| [`architecture/stack.md`](architecture/stack.md)               | With which technologies and versions?         | When setting up the environment          |
| [`architecture/database.md`](architecture/database.md)         | What entities and relationships exist?        | When working with data                   |
| [`architecture/auth.md`](architecture/auth.md)                 | How do you sign in and what is allowed?       | When touching authentication/permissions |
| [`architecture/api.md`](architecture/api.md)                   | What endpoints does it expose?                | When integrating or consuming the API    |
| [`architecture/screens.md`](architecture/screens.md)           | Which screens and where each one is?          | When designing features or UI            |
| [`../design/README.md`](../design/README.md)                   | What visual identity and tokens?              | When building any view                   |
| [`product/business-model.md`](product/business-model.md)       | Why does it exist / how does it create value? | To understand the business               |
| [`product/roadmap.md`](product/roadmap.md)                     | Where is it heading?                          | To learn the priorities                  |
| [`decisions/`](decisions/README.md)                            | Why did we make each decision?                | Before re-debating something             |
| [`conventions/`](conventions/README.md)                        | How do we work in this repo?                  | Before writing code                      |

## About the `architecture/` vs `conventions/` distinction

- **`architecture/`** answers **what this project builds** (its data model, its API, its
  screens).
- **`conventions/`** answers **how the work is done** (how it is tested, how it is
  deployed, how secrets are handled) — cross-cutting to any feature.

When a topic does not warrant both questions, it lives in a single document: auth lives
entirely in `architecture/auth.md`, rules included. Only the database keeps the pair, and
each rule lives on exactly one side.

**Why `design/` is not in here**: `docs/` is what you **read** to build; `design/` is
**consumed** — `design/tokens.css` is imported by the application's CSS.

## How to maintain this documentation

- Update the **"Last updated"** line when editing a document.
- Record relevant decisions as [ADRs](decisions/README.md).
- Keep this index up to date if you add or remove documents.
