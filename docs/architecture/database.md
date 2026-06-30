# Data Model

> Schema, entities and relationships of **[NOMBRE_DEL_PROYECTO]**.
> For the modeling **rules and standards** (naming, types, indexes)
> see [`../conventions/database.md`](../conventions/database.md).
>
> **Last updated**: [FECHA]

## Entity-Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ RESOURCE : owns
    USER {
        uuid id PK
        string email
        datetime created_at
    }
    RESOURCE {
        uuid id PK
        uuid user_id FK
        string name
        datetime created_at
    }
```

## Main entities

### [ENTIDAD_1]

- **Purpose**: [What it represents].
- **Key fields**: [field (type) — description].
- **Relationships**: [with which other entities and with what cardinality].

### [ENTIDAD_2]

- **Purpose**: [What it represents].
- **Key fields**: [field (type) — description].
- **Relationships**: [with which other entities and with what cardinality].

## Relationships and cardinality

| Relationship              | Cardinality | Notes            |
| ------------------------- | ----------- | ---------------- |
| [ENTIDAD_A] → [ENTIDAD_B] | 1:N         | [Integrity rule] |

## Indexes and constraints

- [Important index/constraint and why it exists].
- [Uniqueness, FK, check constraint, etc.].

## Migrations and schema versioning

- [How migrations are generated and applied — `[COMANDO_MIGRACIONES]`].
- [Policy for reversible / non-destructive migrations].

## Seed data (seeds)

- [What base data is loaded and with which command — `[COMANDO_SEEDS]`].
