# Database conventions

> Data modeling rules and standards in [PROJECT_NAME].
> For the project's concrete data model see
> [`../architecture/database.md`](../architecture/database.md).
> **Last updated**: [DATE]

## Stack

- **Engine**: [DATABASE].
- **Access layer / ORM**: [ORM].
- **Migrations**: [MIGRATIONS_TOOL].

## Modeling rules

- **Primary keys**: [strategy — e.g. UUID or auto-increment] consistently.
- **Names**: tables and columns in [convention — snake_case], in [language].
- **Timestamps**: every table has `created_at` and `updated_at`.
- **Foreign keys**: always indexed; `NOT NULL` unless explicitly justified.
- **Preferred types**:

| Case            | Type                |
| --------------- | ------------------- |
| Email           | [TYPE]              |
| Short text      | [TYPE]              |
| Long text       | [TYPE]              |
| Structured JSON | [TYPE]              |
| Money           | [decimal TYPE]      |
| Boolean         | [TYPE] with default |

## Migrations

- Reversible and non-destructive whenever possible.
- One migration per logical change; never edit a migration already applied on `main`.
- Review the impact on existing data before applying in production.

## Examples

```text
create table [resource]
  id          [pk]
  [reference] [fk, not null, indexed]
  name        [text, not null]
  timestamps
```

## Useful commands

```bash
[CREATE_MIGRATION_COMMAND]
[MIGRATE_COMMAND]
[ROLLBACK_COMMAND]
```

## References

- [ORM / database engine documentation].
