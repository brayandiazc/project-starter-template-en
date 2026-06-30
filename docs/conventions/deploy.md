# Deployment conventions

> Production operations for [PROJECT_NAME]. Source of truth for how the
> system is deployed, rolled back and operated.
> **Last updated**: [DATE]

## Infrastructure stack

- **Hosting / compute**: [PROVIDER].
- **DNS / TLS**: [PROVIDER].
- **Containers / orchestration**: [TOOL].
- **CI/CD**: [TOOL].

## Environments

| Environment | URL              | Branch    | Deploy    |
| ----------- | ---------------- | --------- | --------- |
| Development | [DEV_URL]        | `develop` | Automatic |
| Staging     | [STAGING_URL]    | `staging` | Automatic |
| Production  | [PRODUCTION_URL] | `main`    | Manual    |

## Rules

- Production is only deployed from `main`.
- Every deploy must be reproducible and reversible.
- Environment variables and secrets are managed according to [`secrets.md`](secrets.md).
- Verify health checks after each deploy.

## Deploy procedure

```bash
# 1. Build
[BUILD_COMMAND]

# 2. Deploy to the environment
[DEPLOY_COMMAND]

# 3. Verify
curl [HEALTHCHECK_URL]
```

## Rollback

```bash
[ROLLBACK_COMMAND]
```

## Health checks and monitoring

- Health endpoint: `[HEALTHCHECK_PATH]`.
- Error monitoring: [TOOL].
- Alerts: [Where and on what notifications are sent].

## References

- [Deploy tool documentation].
