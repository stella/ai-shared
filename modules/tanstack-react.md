## TanStack React

- Prefer `useRouteContext` for data already provided by parent route loaders
  (`beforeLoad`) over firing a separate query. Extend the route context if needed.
- When a route loader only primes a TanStack Query cache, return `void` so its return
  type stays out of the route tree and does not inflate type-inference cost.
- Use `useSuspenseQuery` only in route or page content where the query is preloaded or
  wrapped by an explicit local `Suspense` boundary. In shared chrome (breadcrumbs,
  headers, toolbars, sidebar shell), prefer `useQuery` so a cache miss cannot suspend
  the whole layout.
- Always use `select` with `useParams`, `useSearch`, and `useRouteContext` to subscribe
  only to the fields the component needs.
- Pass `from` to `useParams`, `useSearch`, and `Link`. In shared chrome that spans
  routes, pass `strict: false` to `useParams` or `useSearch`. This narrows the full
  route union, improving precision and type-check performance.
- Let inference flow through `useLoaderData`, `useQuery`, and other inference-driven
  hooks. Do not pass explicit type arguments that can mask a broken inference chain.
- Query option file ordering: key type, key helpers, input type
  (`QueryOptionsInput`), option factory, then hook.
- Query option factories that use `QueryOptionsInput` with a `TContext` must define a
  nearby type alias matching the factory name (for example, `ViewsOptionsInput` for
  `viewsOptions`), destructure `{ key, context }` in the parameter, and reference
  `key.*` and `context.*` directly in the body.
- Define a separate key type (for example, `EntitiesPageKey`) and use it in both the
  `QueryOptionsInput` and key helper. The key helper must accept the key type, not the
  full options input.
- Never spread input objects into query keys. Explicitly reconstruct the key object so
  extra caller properties cannot leak into cache identity.
- Key helpers must compose by spreading the parent key (for example,
  `...entitiesKeys.all(workspaceId)`), never by duplicating the parent's array
  literal.
