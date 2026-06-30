# Secrets and credentials conventions

> How we manage secrets in [PROJECT_NAME].
> **Last updated**: [DATE]

## Philosophy

- Secrets are **never** committed in plain text.
- Clear separation between **configuration** (non-sensitive) and **secrets** (sensitive).

## Where each thing lives

| Type                     | Where                                    |
| ------------------------ | ---------------------------------------- |
| Application secrets      | [SECRETS_MANAGER / local .env]           |
| Infrastructure variables | Environment variables of the environment |
| CI/CD secrets            | Provider secrets (e.g. GitHub Actions)   |

## Rules

- The `.env` file is in `.gitignore`; only `.env.example` (without values) is versioned.
- Share secrets with new collaborators **out of band** (never via git, plain email or public chat).
- Rotate credentials periodically (suggested every 90 days) and immediately on suspicion of a leak.
- If a secret is committed by mistake: **rotate the secret first**, then clean the history.

## Examples

```bash
# Copy the variables template
cp .env.example .env
# Fill in real values (which are never uploaded)
```

## Useful commands

```bash
[SECRETS_MANAGEMENT_COMMAND]
```

## References

- [SECURITY.md](../../SECURITY.md) — security policy.
- [Documentation of the chosen secrets manager].
