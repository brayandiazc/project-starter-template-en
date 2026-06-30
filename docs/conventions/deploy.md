# Deployment conventions

> Production operations for [NOMBRE_DEL_PROYECTO]. Source of truth for how the
> system is deployed, rolled back and operated.
> **Last updated**: [FECHA]

## Infrastructure stack

- **Hosting / compute**: [PROVEEDOR].
- **DNS / TLS**: [PROVEEDOR].
- **Containers / orchestration**: [HERRAMIENTA].
- **CI/CD**: [HERRAMIENTA].

## Environments

| Environment | URL              | Branch    | Deploy    |
| ----------- | ---------------- | --------- | --------- |
| Development | [URL_DEV]        | `develop` | Automatic |
| Staging     | [URL_STAGING]    | `staging` | Automatic |
| Production  | [URL_PRODUCCION] | `main`    | Manual    |

## Rules

- Production is only deployed from `main`.
- Every deploy must be reproducible and reversible.
- Environment variables and secrets are managed according to [`secrets.md`](secrets.md).
- Verify health checks after each deploy.

## Deploy procedure

```bash
# 1. Build
[COMANDO_BUILD]

# 2. Deploy to the environment
[COMANDO_DEPLOY]

# 3. Verify
curl [URL_HEALTHCHECK]
```

## Rollback

```bash
[COMANDO_ROLLBACK]
```

## Health checks and monitoring

- Health endpoint: `[RUTA_HEALTHCHECK]`.
- Error monitoring: [HERRAMIENTA].
- Alerts: [Where and on what notifications are sent].

## References

- [Deploy tool documentation].
