# [PROJECT_NAME] — Architecture

> High-level view of how the system is built and how responsibilities are
> distributed. For the actual stack (versions, libraries) see
> [`stack.md`](stack.md). For the business see
> [`../product/business-model.md`](../product/business-model.md).
>
> **Last updated**: [DATE]

## Diagram

```mermaid
graph TD
    subgraph Client
        A[Web / App]
    end
    subgraph "Application layer"
        B[API / Backend]
        C[Worker / Async tasks]
    end
    subgraph Data
        D[(Database)]
        E[(Cache)]
    end
    subgraph External
        F[External service]
    end

    A --> B
    B --> D
    B --> E
    B --> C
    C --> F
    B --> F
```

## Components

| Component     | Responsibility                                | Technology   |
| ------------- | --------------------------------------------- | ------------ |
| [COMPONENT_1] | [What it does and what it is responsible for] | [TECHNOLOGY] |
| [COMPONENT_2] | [What it does and what it is responsible for] | [TECHNOLOGY] |
| [COMPONENT_3] | [What it does and what it is responsible for] | [TECHNOLOGY] |

## Key decisions

| Decision     | Reason            |
| ------------ | ----------------- |
| [DECISION_1] | [Why it was made] |
| [DECISION_2] | [Why it was made] |

> The detail and alternatives for each relevant decision are recorded as
> ADRs in [`../decisions/`](../decisions/README.md).

## Non-negotiable rules

- [System invariant or rule that must never be broken].
- [Another rule].

## Main flows

```mermaid
sequenceDiagram
    actor U as User
    participant A as API
    participant D as Database
    U->>A: Request
    A->>D: Query
    D-->>A: Data
    A-->>U: Response
```

## References

- [`stack.md`](stack.md) — tech stack and versions.
- [`database.md`](database.md) — data model.
- [`auth.md`](auth.md) — authentication and authorization.
- [`api.md`](api.md) — API reference.
- [`../conventions/`](../conventions/README.md) — working conventions.
