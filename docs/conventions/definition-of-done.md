# Definition of Done

> What "done" means in [PROJECT_NAME]. If a line can't be checked off, the
> change isn't done — it is _declared_ done.
> **Last updated**: [DATE]

## Behavior

- [ ] The full flow was exercised end to end (by hand or with a high-level
      automated test), not just with unit tests.
- [ ] The happy path **and at least two error paths** (invalid input, a
      dependency failing) respond sensibly.
- [ ] Loading, empty, error, and success states render correctly (if there is UI).

## Tests

- [ ] At least one test exists that would fail if the change were reverted.
- [ ] No existing test was weakened, skipped, or deleted to make CI green.
- [ ] Coverage of the changed lines is meaningful
      (see [`testing.md`](testing.md)).

## Interfaces and data

- [ ] Public API changes are documented in
      [`../architecture/api.md`](../architecture/api.md); breaking changes have
      a migration note in `CHANGELOG.md`.
- [ ] Error messages are actionable, not "something went wrong".
- [ ] Migrations are reversible and safe to run hot
      (see [`database.md`](database.md)).
- [ ] No secrets in the code or in the logs (see [`secrets.md`](secrets.md)).

## Delivery

- [ ] Atomic, readable commits per [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md).
- [ ] The PR description answers the **why**, not just the what.
- [ ] A rollback plan exists (revert commit, feature flag off, etc.).
- [ ] Affected docs in `docs/` and `CHANGELOG.md` are up to date; notable
      decisions have their ADR in [`../decisions/`](../decisions/README.md).
