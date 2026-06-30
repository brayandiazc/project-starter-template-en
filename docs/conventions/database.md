# Database conventions

> Data modeling rules and standards in [NOMBRE_DEL_PROYECTO].
> For the project's concrete data model see
> [`../architecture/database.md`](../architecture/database.md).
> **Last updated**: [FECHA]

## Stack

- **Engine**: [BASE_DE_DATOS].
- **Access layer / ORM**: [ORM].
- **Migrations**: [HERRAMIENTA_MIGRACIONES].

## Modeling rules

- **Primary keys**: [strategy — e.g. UUID or auto-increment] consistently.
- **Names**: tables and columns in [convention — snake_case], in [language].
- **Timestamps**: every table has `created_at` and `updated_at`.
- **Foreign keys**: always indexed; `NOT NULL` unless explicitly justified.
- **Preferred types**:

| Case            | Type                |
| --------------- | ------------------- |
| Email           | [TIPO]              |
| Short text      | [TIPO]              |
| Long text       | [TIPO]              |
| Structured JSON | [TIPO]              |
| Money           | [TIPO decimal]      |
| Boolean         | [TIPO] with default |

## Migrations

- Reversible and non-destructive whenever possible.
- One migration per logical change; never edit a migration already applied on `main`.
- Review the impact on existing data before applying in production.

## Examples

```text
crear tabla [recurso]
  id           [pk]
  [referencia] [fk, not null, indexado]
  nombre       [texto, not null]
  timestamps
```

## Useful commands

```bash
[COMANDO_CREAR_MIGRACION]
[COMANDO_MIGRAR]
[COMANDO_ROLLBACK]
```

## References

- [ORM / database engine documentation].
