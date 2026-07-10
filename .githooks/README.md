# Git guardrails (optional)

Native git hooks that reinforce the branching in
[`../CONTRIBUTING.md`](../CONTRIBUTING.md) and the secrets policy in
[`../SECURITY.md`](../SECURITY.md):

- `pre-commit` — blocks direct commits on `main` / `master` / `develop`, and
  rejects staged **secret files**: the real `.env` and its variants
  (`.env.local`, `.env.production`, …; `.env.example` / `.env.sample` /
  `.env.template` are allowed), private keys and certificates (`*.pem`,
  `*.key`, `id_rsa*`, `id_ed25519*`, `id_ecdsa*`).
- `pre-push` — blocks direct pushes to those branches.

They are off by default. To enable them in your clone:

```bash
git config core.hooksPath .githooks
```

To disable them: `git config --unset core.hooksPath`.

> They are a **local** safety net; they don't replace server-side branch
> protection (GitHub).
