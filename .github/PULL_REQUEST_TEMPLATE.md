# Description

What changes and what problem it solves. If it implements a spec, link it.

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Refactor (no behavior change)
- [ ] Documentation
- [ ] Configuration / tooling

## How to check it works

Concrete steps to verify the result, not the code:

1.
2.

## What no machine checks

> CI already verifies formatting, links, the CHANGELOG entry and the test suite: there
> are no checkboxes for that. Only the things that **fail silently** go here — they pass
> the tests and produce no error in the monitor (`docs/conventions/ai-agents.md`).

- [ ] **Data schema reviewed by hand** — mandatory if there is a migration. It is the
      most expensive thing to change later and the only one neither tests nor monitoring
      catch.
- [ ] If it touches **authorization**: tested with a role other than your own.
- [ ] If it touches **queues or mobile**: create operations are idempotent.
- [ ] If it touches **UI**: the four states (loading, empty, error, success) and both themes.
- [ ] If there is a **custom component**: focus trap, Escape, ARIA and keyboard navigation.
- [ ] Affected documentation updated and the roadmap item ticked if the spec completes it.

## Impact

- **Breaking change**: Yes / No — if yes, what breaks and what has to be done
- **Requires migration**: Yes / No
- **Something grows without a bound** (storage, compute, model calls): Yes / No — if yes,
  is it in the price?

## Evidence

Screenshots or video if there is UI — **in both themes**.

## Issues

Closes #
