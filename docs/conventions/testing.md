# Testing conventions

> How we write and run tests in [PROJECT_NAME].
> **Last updated**: [DATE]

## Stack

- **Test framework**: [TEST_FRAMEWORK].
- **Coverage**: [COVERAGE_TOOL].
- **System/E2E tests**: [E2E_TOOL] (if applicable).

## Test types

| Type         | What it covers                 | Folder               |
| ------------ | ------------------------------ | -------------------- |
| Unit         | Isolated functions/classes     | `[UNIT_PATH]`        |
| Integration  | Interaction between components | `[INTEGRATION_PATH]` |
| E2E / system | Complete user flows            | `[E2E_PATH]`         |

## Rules

- Every functional change is accompanied by tests.
- **Arrange-Act-Assert** (AAA) structure: set up, execute, verify.
- A test verifies **one** thing; descriptive names of the expected behavior.
- Tests must be deterministic (no dependency on network, clock or order).
- Minimum expected coverage: [PERCENTAGE]%.

## Examples

```text
describe "[Unit under test]"
  it "[expected behavior] when [condition]"
    # Arrange
    # Act
    # Assert
```

## Useful commands

```bash
[TEST_COMMAND]            # Run all tests
[TEST_COVERAGE_COMMAND]  # With coverage report
[TEST_WATCH_COMMAND]      # Watch mode
```

## References

- [Test framework documentation].
