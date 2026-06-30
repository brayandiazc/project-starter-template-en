# Quality and tooling conventions

> Linters, formatting, static analysis and git hooks for [NOMBRE_DEL_PROYECTO].
> **Last updated**: [FECHA]

## Stack

- **Linter**: [LINTER].
- **Formatter**: [FORMATEADOR].
- **Static analysis / security**: [HERRAMIENTA].
- **Dependency auditing**: [HERRAMIENTA].
- **Git hooks orchestrator**: [HERRAMIENTA] (optional).

## Git hooks

Suggested strategy: cheap and fast hooks on `pre-commit`, the more expensive ones on
`pre-push`. CI runs everything again on the server.

### pre-commit (on every commit)

- Linter on changed files.
- Automatic formatting.
- Check for trailing whitespace, end of file, unresolved conflicts.

### pre-push (on push)

- Full linter.
- Tests (or a fast subset).
- Dependency audit.

## Rules

- Code must pass linter and formatting before merge.
- Quality checks are **blocking** in CI.

## Useful commands

```bash
[COMANDO_LINT]
[COMANDO_FORMAT]
[COMANDO_AUDIT_DEPENDENCIAS]
```

## References

- [Documentation of the chosen tools].
