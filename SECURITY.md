# Security Policy

How to report vulnerabilities in **[PROJECT_NAME]** and what security practices the
repository follows.

## Reporting a vulnerability

**Do not open a public issue.** Report it privately through one of these channels:

- **GitHub Security Advisories** — the repository's _Security_ tab → _Report a
  vulnerability_ (preferred: it stays traced and allows publishing the advisory).
- **Email** — <[SECURITY_EMAIL]>, with the subject starting with `Security:`.

Include: a description, steps to reproduce it (a PoC if you can), the estimated impact,
the affected version or commit and, if you want credit in the fix, your name or handle.

This is maintained by a single person: **there is no response SLA**. What there is, is a
commitment to acknowledge receipt, prioritize by real impact, not retaliate against
good-faith reports and credit you in the changelog if you want. Critical vulnerabilities
are handled before any feature.

### What counts and what does not

In scope: the repository's code, the application deployed on its official domains, the
endpoints it exposes and the workflows in `.github/workflows/`.

**Not** counted: automated scanner output with no demonstrated impact, missing headers
with no exploitation vector, self-XSS, social engineering, volumetric DoS, or dependency
vulnerabilities this project cannot reach.

## Handling secrets

- **Never** commit secrets in plain text: keys, tokens, passwords, private certificates
  or a `.env` with real values. The `secret-scan.yml` workflow scans the history with
  gitleaks.
- The canonical place is **the team's credential manager**; `.env` is generated from
  there and `.env.example` documents the contract with no values. See
  [`docs/conventions/secrets.md`](docs/conventions/secrets.md).
- In CI, the provider's encrypted secrets (GitHub Actions Secrets) — never in the YAML.
- **If a secret leaks: rotate first, clean the history afterwards.** Rewriting history is
  not enough; assume it has been compromised since the first push.

## Dependencies

- The lockfile is always versioned; no open ranges in production.
- **Dependabot** (`.github/dependabot.yml`) opens the update PRs.
- A critical vulnerability in a dependency has the same priority as one in your own code.

## Where security is reviewed by hand

These four areas are looked at explicitly because they **fail silently**: they pass the
tests and produce not one single error in the monitor.

| Area              | What gets checked                                                                         |
| ----------------- | ----------------------------------------------------------------------------------------- |
| **Authorization** | Every endpoint, with roles other than your own. Validation always on the server           |
| **Input**         | Parameterized queries (never concatenate SQL), validation at every edge                   |
| **Sessions**      | Hashing with argon2/bcrypt, token rotation on every login, `Secure`+`HttpOnly`+`SameSite` |
| **Webhooks**      | Signature verified over the **raw body**, before parsing                                  |

The rest is baseline and non-negotiable: HTTPS with HSTS in every public environment, no
secrets or PII in logs, and encrypted backups **with a tested restore** — a backup with
no tested restore is not a backup.

Before merging anything touching authentication, authorization, payments or user data,
walk that table explicitly in the PR.

## Incident response

1. **Contain** — isolate what is affected and revoke compromised credentials.
2. **Investigate** — root cause, scope and vector.
3. **Remediate** — fix, redeploy and rotate every secret that could have been exposed.
4. **Notify** — the affected people if personal data was exposed, per whichever data
   protection regulation applies to the product.
5. **Post-mortem** — what failed and what changes so it does not happen again, as an ADR
   if it touches structure.

## Contact

- Security: <[SECURITY_EMAIL]> (subject `Security: …`)
- General: <[SUPPORT_EMAIL]>
