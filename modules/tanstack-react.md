## TanStack React

- Prefer `useRouteContext` for data already provided by parent route loaders
  (`beforeLoad`) over firing a separate query. Extend the route context if needed.
- When a route loader only primes a TanStack Query cache, return `void` so its return
  type stays out of the route tree and does not inflate type-inference cost.
- Suspense queries only in preloaded route content, never in shared chrome
  (`no-shared-suspense-query`); router reads use `select` and `from`
  (`require-router-select`), and chrome spanning routes reads with `strict: false`
  (`no-strict-route-read-in-chrome`).
- Query option file ordering: key type, key helpers, input type
  (`QueryOptionsInput`), option factory, then hook.
- Query option factories that use `QueryOptionsInput` with a `TContext` must define a
  nearby type alias matching the factory name (for example, `ViewsOptionsInput` for
  `viewsOptions`), destructure `{ key, context }` in the parameter, and reference
  `key.*` and `context.*` directly in the body.
- Define a separate key type (for example, `EntitiesPageKey`) and use it in both the
  `QueryOptionsInput` and key helper. The key helper must accept the key type, not the
  full options input.
- Never spread input objects into query keys (`no-spread-input-in-query-key`).
- Key helpers must compose by spreading the parent key (for example,
  `...entitiesKeys.all(workspaceId)`), never by duplicating the parent's array
  literal.
