# Testing conventions

> How we write and run tests in [NOMBRE_DEL_PROYECTO].
> **Last updated**: [FECHA]

## Stack

- **Test framework**: [FRAMEWORK_TEST].
- **Coverage**: [HERRAMIENTA_COBERTURA].
- **System/E2E tests**: [HERRAMIENTA_E2E] (if applicable).

## Test types

| Type         | What it covers                 | Folder               |
| ------------ | ------------------------------ | -------------------- |
| Unit         | Isolated functions/classes     | `[RUTA_UNIT]`        |
| Integration  | Interaction between components | `[RUTA_INTEGRACION]` |
| E2E / system | Complete user flows            | `[RUTA_E2E]`         |

## Rules

- Every functional change is accompanied by tests.
- **Arrange-Act-Assert** (AAA) structure: set up, execute, verify.
- A test verifies **one** thing; descriptive names of the expected behavior.
- Tests must be deterministic (no dependency on network, clock or order).
- Minimum expected coverage: [PORCENTAJE]%.

## Examples

```text
describe "[Unidad bajo prueba]"
  it "[comportamiento esperado] cuando [condición]"
    # Arrange
    # Act
    # Assert
```

## Useful commands

```bash
[COMANDO_TEST]            # Run all tests
[COMANDO_TEST_COBERTURA]  # With coverage report
[COMANDO_TEST_WATCH]      # Watch mode
```

## References

- [Test framework documentation].
