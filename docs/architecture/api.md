# API Reference

> Endpoints, authentication and conventions of the **[PROJECT_NAME]** API.
> Interactive documentation: [LINK_OPENAPI/SWAGGER/POSTMAN]
>
> **Last updated**: [DATE]

## General conventions

- **Base URL**: `[API_BASE_URL]`
- **Versioning**: version prefix in the path (e.g. `/v1`).
- **Format**: JSON (`Content-Type: application/json`).
- **Dates**: ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`).

## API authentication

- Scheme: [Bearer token / API key / OAuth].
- Header: `Authorization: Bearer <token>`.
- See [`auth.md`](auth.md) for the detail.

## Error handling

Standard error format:

```json
{
  "error": {
    "code": "[CODE]",
    "message": "[Human-readable message]",
    "details": []
  }
}
```

| HTTP code | Meaning             |
| --------- | ------------------- |
| 200 / 201 | Success             |
| 400       | Bad request         |
| 401       | Not authenticated   |
| 403       | Not authorized      |
| 404       | Not found           |
| 422       | Validation failed   |
| 429       | Rate limit exceeded |
| 500       | Internal error      |

## Pagination, filtering and sorting

- **Pagination**: `?page=1&per_page=20` (or cursor: `?cursor=...`).
- **Filtering**: `?filter[field]=value`.
- **Sorting**: `?sort=-created_at`.

## Endpoints

### [RESOURCE]

```http
GET    /v1/[resources]          # List
GET    /v1/[resources]/:id      # Get one
POST   /v1/[resources]          # Create
PUT    /v1/[resources]/:id      # Update
DELETE /v1/[resources]/:id      # Delete
```

**Example — create:**

```http
POST /v1/[resources]
Content-Type: application/json
Authorization: Bearer <token>

{
  "[field]": "[value]"
}
```

**Response:**

```json
{
  "id": "[uuid]",
  "[field]": "[value]"
}
```

## Rate limiting

- Limit: [N] requests per [window] per [user/IP].
- Response headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After`.

## Webhooks (if applicable)

- Receiving endpoint, signature verification and supported events.

## API changelog

- [Relevant API contract changes, by version].
