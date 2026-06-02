## Scalability

Never paint yourself into a corner. Architecture must support Magic Circle scale
without a rewrite. Never return unbounded result sets; keep the API stateless; filter
by tenant ID in the query. Full guidelines in `/conventions-scale`.

List endpoints should use cursor pagination and return the standard `Page<T>` envelope
from `apps/api/src/lib/pagination.ts`:
`{ items, nextCursor, limit }`. Offset pagination, `totalCount`, and unbounded lists
require explicit justification.
