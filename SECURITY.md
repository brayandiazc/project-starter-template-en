# Security Policy

This document describes how to report vulnerabilities in **[PROJECT_NAME]** and the security practices we follow in the repository.

## Table of Contents

- [Reporting Vulnerabilities](#reporting-vulnerabilities)
  - [Information to include](#information-to-include)
  - [What to expect](#what-to-expect)
- [Supported Versions](#supported-versions)
- [Scope](#scope)
- [Out of Scope](#out-of-scope)
- [Handling Secrets](#handling-secrets)
- [Dependencies](#dependencies)
- [Secure Development Practices](#secure-development-practices)
- [Incident Response](#incident-response)
- [Acknowledgments](#acknowledgments)
- [Contact](#contact)

## Reporting Vulnerabilities

If you discover a security vulnerability, **do not open a public issue**. Report it privately through one of these channels:

- **Email**: <[SECURITY_EMAIL]> (preferred — use a subject starting with `Security:` so we prioritize it).
- **GitHub Security Advisories**: the _Security_ tab of the repository → _Report a vulnerability_.

### Information to include

To help us triage and respond quickly, include:

1. A clear description of the vulnerability.
2. Steps to reproduce it (PoC if possible).
3. Estimated impact (what can be compromised).
4. Affected version / commit.
5. Suggested mitigation (optional).
6. If you want public credit in the fix, provide your name and handle.

### What to expect

| Stage                       | Target time          |
| --------------------------- | -------------------- |
| Acknowledgment of receipt   | 48 business hours    |
| Initial triage and severity | 5 business days      |
| Fix for critical severity   | 7 days               |
| Fix for high severity       | 30 days              |
| Fix for medium/low severity | next planned release |

We commit to acknowledging receipt, keeping you informed of progress, not pursuing legal action against good-faith reports, and crediting you in the changelog/advisory once the fix is published (if you wish).

## Supported Versions

| Version                 | Security support        |
| ----------------------- | ----------------------- |
| `main` (main branch)    | Yes                     |
| `develop` (integration) | Yes                     |
| Releases / tags         | [DEFINE_SUPPORT_POLICY] |

## Scope

Surfaces **in scope** for security reports:

- The repository source code.
- The application deployed on the official domains.
- HTTP/API endpoints exposed by the project.
- The repository CI/CD pipelines (`.github/workflows/`).
- Officially published artifacts.

Examples of findings of interest:

- Injections (SQL, command, template, deserialization).
- Cross-Site Scripting (XSS), CSRF, SSRF, clickjacking.
- Broken authentication or authorization bypass.
- Privilege escalation.
- Exposure of sensitive data (PII, API keys, secrets).
- Insecure configurations (CORS, headers, cookies, TLS).
- Vulnerabilities in dependencies with demonstrable impact.
- Race conditions with security impact.
- Path traversal, RCE, LFI/RFI.

## Out of Scope

The following findings **do not qualify** as vulnerabilities:

- Automated scanner reports without demonstrated impact.
- Missing security headers without an exploitation vector.
- Self-XSS, social engineering, phishing.
- Denial of service (DoS / DDoS) via traffic volume.
- Vulnerabilities in dependencies without an exploitation vector in this project.
- Beta/development versions of third-party software.
- Disclosure of already-public information.

## Handling Secrets

- **Never** commit secrets in plaintext (API keys, tokens, passwords, private certificates, `.env` files with real values).
- Manage secrets with your stack's mechanism (secrets manager, encrypted environment variables, etc.). See [`docs/conventions/secrets.md`](docs/conventions/secrets.md).
- Share credentials with new collaborators **out of band** (never via git, plaintext email, or public chat).
- Rotate credentials periodically (every **90 days** suggested) and immediately if a leak is suspected.
- If a secret is committed by mistake: **rotate the secret first**, then clean the history. Rewriting history is not enough — assume it is already compromised.

## Dependencies

- Pin dependency versions with a versioned lockfile.
- Run automated vulnerability audits in CI ([DEPENDENCY_AUDIT_COMMAND]).
- Automated updates are managed with **Dependabot** (`.github/dependabot.yml`) — PRs reviewed by humans before merge.
- Critical vulnerabilities in dependencies are treated with the same priority as vulnerabilities in your own code.

## Secure Development Practices

### Authentication and Authorization

- Hash passwords with a robust algorithm (bcrypt, argon2…).
- Rotate session tokens on each login.
- Validate authorization **on the server** on every request — never trust client-side checks.
- Validate OAuth/SSO flows server-side.

### Input Validation

- Validate and normalize input at all system boundaries.
- Use **parameterized queries** — never concatenate SQL.
- Encode output according to context (HTML, attribute, URL, JS, CSS).
- Prefer allowlists over denylists.

### Communication

- HTTPS mandatory in all public environments (HSTS enabled).
- Sensitive cookies with `Secure`, `HttpOnly`, and `SameSite`.
- Verify the signature of incoming webhooks over the raw body.

### Logging and Monitoring

- Do not log secrets, passwords, tokens, or unnecessary PII.
- Centralize logs with retention and controlled access.
- Monitor errors and configure alerts for authentication anomalies and error spikes.

### Backups and Recovery

- Automated, periodic backups of the data.
- Encrypted backups stored separately from production.
- Periodic restore tests — a backup without a tested restore is not a backup.

### Code Review

- Every PR requires approval before merge (see [CONTRIBUTING.md](CONTRIBUTING.md)).
- Sensitive changes (auth, cryptography, secret handling, infrastructure) require a specific security review.
- Static analysis and dependency auditing are blocking checks.

## Incident Response

In the event of a confirmed security incident:

1. **Contain**: isolate the affected system, revoke compromised credentials.
2. **Communicate internally**: notify the responsible team through the defined channel.
3. **Investigate**: identify root cause, scope, and exploitation vectors.
4. **Remediate**: apply the fix, redeploy, rotate all potentially exposed secrets.
5. **Notify those affected**: if personal data was exposed, according to applicable legal obligations.
6. **Post-mortem**: document the incident, lessons learned, and corrective actions.

## Acknowledgments

We thank those who report vulnerabilities responsibly.

<!-- Reverse chronological order. Format: - YYYY-MM-DD — Name/Handle — Brief summary -->

- _No public reports yet._

## Contact

- **Security reports**: <[SECURITY_EMAIL]> (subject: `Security: …`)
- **General inquiries**: <[SUPPORT_EMAIL]>

---

> Version: 1.0 — Last updated: [DATE]
