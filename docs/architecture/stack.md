# [PROJECT_NAME]'s stack

> **What it is**: what was chosen for **this** product and why. It is the **single**
> source of the stack: if a convention repeats one of these facts, it drifts out of sync
> without anyone noticing. The long why behind each choice goes as an ADR in
> [`../decisions/`](../decisions/README.md).
> **Last updated**: [DATE]

## Chosen stack

**[CHOSEN]**, and where it comes from: [this project's own decision · the team's
standard · a client requirement · a deviation from a standard, with an ADR].

> Write where the decision came from, not just what it was. That is what makes it
> auditable, months later, whether somebody chose or simply inherited.

> The rows are **categories**, not choices: fill each one with what this product uses and
> **delete the ones that do not apply** (a CLI has no database, a static site has no
> server framework).

| Piece              | Version   | Note |
| ------------------ | --------- | ---- |
| Main framework     | [VERSION] |      |
| Runtime / language | [VERSION] |      |
| Database           | [VERSION] |      |
| Dependency manager | [VERSION] |      |

## Deviations from the team's standard

Every row needs its ADR in [`../decisions/`](../decisions/README.md). If the table is
empty, all the better: the product is on the beaten path.

| Deviated on | Used instead | Why | ADR |
| ----------- | ------------ | --- | --- |
| [DISCARDED] | [CHOSEN]     |     |     |

## Active services

Only the ones this product has **contracted and connected**. A service not listed here is
not running yet.

| Service       | What for   | Environment variable |
| ------------- | ---------- | -------------------- |
| [SERVICE/API] | [WHAT_FOR] | `[NAMES]`            |
|               |            |                      |

## Third-party APIs we consume

> **Delete it if the product calls none.** One row per API, with its adapter: the
> business logic does not know the provider.

| API        | What for         | Adapter           | Key?     | Fallback if it fails                |
| ---------- | ---------------- | ----------------- | -------- | ----------------------------------- |
| [Provider] | [What it solves] | [Class or module] | [Yes/No] | [Another provider · degrade · fail] |

And for each one, decided **before** implementing — if it is not written down, every call
decides on its own:

- **What shape the object has in OUR domain**, versus what the provider returns. That is
  what the adapter translates; without this it ends up being the provider's JSON under
  another name, and then there is no adapter.
- **What happens when it finds nothing.** If the answer forces an alternative flow, say
  so here: an API limitation that defines a screen is not a technical detail.
- **Caching**: what is stored, how long it lives and why. When many users ask for the
  same thing it is often nearly free and changes the whole cost.
- **Rate limits** and what happens when they are hit.
- **The data's license** and the attribution required when displaying it.

## AI provider

**This template fixes none**, and you should not take one for granted either: it is
chosen here, per product.

|                                                                       |                             |
| --------------------------------------------------------------------- | --------------------------- |
| Main provider                                                         | `AI_PROVIDER=`              |
| Model per task                                                        |                             |
| **Second provider** (configured from day 1, tests running against it) |                             |
| Does it use an exclusive capability?                                  | No / Yes → **ADR required** |

If the answer to the last row is "Yes", the mitigations for an exclusive capability —a
port of your own in the domain, two implementations, storing the input and not just the
result, and an ADR naming the shutdown risk— are mandatory — above all **storing the
input, not just the result**.

## Kickoff decisions

Answered before writing code:

- **The product's central entity**: — _(designed on paper before anything else)_
- **What grows without a bound?**: — _that is the recurring cost_
- **Is there infrastructure cost per user?**: — _if yes, it goes into the price from day one_
- **Is there a screen with continuous interactivity?**: — _if yes, that is where a
  client-side framework earns its place_
- **Does it need something the web cannot give?**: — _if yes, native; if not, a PWA_
