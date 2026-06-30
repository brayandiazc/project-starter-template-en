# Transactional emails conventions

> How we send transactional emails in [PROJECT_NAME].
> **Last updated**: [DATE]

## Stack

- **Sending provider**: [PROVIDER] (production).
- **Development environment**: [DEV_TOOL] (local preview without sending).

## Configuration per environment

| Environment | Sending mechanism   |
| ----------- | ------------------- |
| Development | [Local preview]     |
| Test        | [In-memory capture] |
| Production  | [Real PROVIDER]     |

## Rules

- Every email is sent in **HTML and plain text** (multipart).
- Idempotent operations: record `*_enviado_at` to avoid resending.
- Do not include secrets or unnecessary PII in the body.
- Localized subjects and content (see [`i18n.md`](i18n.md)).
- Links with absolute URLs, signed/expirable when appropriate.

## Email types

| Email          | Trigger       |
| -------------- | ------------- |
| Welcome        | User sign-up  |
| Recover access | Reset request |
| [OTHER]        | [Event]       |

## Examples

```text
Subject: Welcome to [PROJECT_NAME]
Body: HTML + plain text, with a CTA and a verification link
```

## References

- [Email provider documentation].
