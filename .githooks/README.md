# Git guardrails (optional)

Native git hooks that reinforce the branching in
[`../CONTRIBUTING.md`](../CONTRIBUTING.md):

- `pre-commit` — blocks direct commits on `main` / `master` / `develop`.
- `pre-push` — blocks direct pushes to those branches.

They are off by default. To enable them in your clone:

```bash
git config core.hooksPath .githooks
```

To disable them: `git config --unset core.hooksPath`.

> They are a **local** safety net; they don't replace server-side branch
> protection (GitHub). They require no AI tooling.
