# Quality and tooling conventions

> Linters, formatting, static analysis and git hooks for [PROJECT_NAME].
> **Last updated**: [DATE]

## Stack

- **Linter**: [LINTER].
- **Formatter**: [FORMATTER].
- **Static analysis / security**: [TOOL].
- **Dependency auditing**: [TOOL].
- **Git hooks orchestrator**: [TOOL] (optional).

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
[LINT_COMMAND]
[FORMAT_COMMAND]
[DEPENDENCY_AUDIT_COMMAND]
```

## References

- [Documentation of the chosen tools].
