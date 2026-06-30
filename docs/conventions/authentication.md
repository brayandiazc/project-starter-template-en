# Authentication and authorization conventions

> Cross-cutting authentication and authorization rules in [PROJECT_NAME].
> For how auth works in this project see
> [`../architecture/auth.md`](../architecture/auth.md).
> **Last updated**: [DATE]

## Stack

- **Authentication**: [MECHANISM / LIBRARY].
- **Authorization**: [MECHANISM / LIBRARY].
- **Password hashing**: [bcrypt / argon2 / …].

## Rules

- Authorization is **always validated on the server**, on every request.
- Never trust client-side checks for security decisions.
- Passwords are stored hashed with a robust algorithm and salt.
- Tokens/sessions are rotated on every login and have an expiration.
- OAuth/SSO flows are validated server-side (email and UID).

## Model

- **User**: [key identity fields].
- **Session / token**: [how it is represented].
- **Roles / permissions**: [RBAC/ABAC scheme].

## Examples

```text
# Authorization check pseudocode
if not current_user.can?(:action, resource)
  reject(403)
```

## Useful commands

```bash
[RELEVANT_COMMAND]
```

## References

- [`../architecture/auth.md`](../architecture/auth.md)
- [SECURITY.md](../../SECURITY.md)
