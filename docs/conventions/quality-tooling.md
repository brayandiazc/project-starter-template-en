# Quality and tooling conventions

> Linters, formatting, static analysis and git hooks for [PROJECT_NAME].
> **Last updated**: [DATE]

> The concrete stack —engine, library, tools— is decided by the project and recorded by
> [`../architecture/stack.md`](../architecture/stack.md), with the why in
> [`../decisions/`](../decisions/README.md). Only the **rules** go here, which do not
> change when the tool changes.

## Git hooks

Strategy: **`pre-commit` fixes, `pre-push` verifies.** The first formats and never blocks
—a hook that blocks over formatting only teaches people to use `--no-verify`—; the second
runs the same checks as CI and does block, because a broken link or a red test is not
noise.

CI runs everything again on the server, but as a **safety net, not as the verification
loop**: on a private repository Actions minutes are finite and finding there a failure
that took 15 seconds locally costs a whole run.

The hooks live versioned in [`.githooks/`](../../.githooks). Git does not use them until
you tell it to, **once per clone** (it does not travel in the repository):

```bash
git config core.hooksPath .githooks
```

Do it when you clone. To skip them just this once: `git commit --no-verify` or
`git push --no-verify`.

### pre-push (included and active)

It runs the same checks as the `Quality` job, in the same order as
[`quality.yml`](../../.github/workflows/quality.yml): formatting, internal links,
placeholders, inheritance, design system, README instructions, the template's test
suite and the project's tests. It takes ~15 seconds.
(The canonical list is [`pre-push`](../../.githooks/pre-push)'s own — if this falls
behind, the hook wins.)

**It blocks the push if something fails**, and it does not stop at the first failure: it
runs them all and lists them together, just like the workflow's `!cancelled()`. If a
script no longer exists —because the project pruned it when instantiating— it is skipped,
not failed.

Depending on the stack, add: the full linter, a fast subset of tests, a dependency audit.

### pre-commit (included and active)

- **It formats what is staged** with Prettier (`md`, `html`, `css`, `json`, `yml`) and
  re-stages it into the commit. **It never blocks**: formatting is not a decision, it is
  noise.
- It skips files that have unstaged changes: reformatting them would pull into the commit
  work you decided to leave out.
- It does not touch application code — that belongs to the stack's linter. When the stack
  is chosen, add its linter over changed files here, plus checks for trailing whitespace
  and unresolved conflicts.

## Rules

- Code must pass the linter and formatter before merging.
- Quality checks are **blocking** in CI.

## Useful commands

The test and lint commands live in the "Usage" block of
[`README.md`](../../README.md) — a single copy. Only the ones not there go here:

```bash
[FORMAT_COMMAND]
[DEPENDENCY_AUDIT_COMMAND]
```
