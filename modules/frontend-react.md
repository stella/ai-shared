## UX & Brand

Use semantic tokens (`bg-muted`, `text-foreground`, `border`), not raw colour values.
Full brand deck, micro-interaction guidelines, and visual noise rules in
`/conventions-ux`.

## React

- Put the root/exported component at the top of the file (after imports); helper
  components and types follow below.
- Prefer `if` statements over nested ternaries for conditional rendering. Extract
  complex logic into a small component that returns early with `if` branches instead
  of chaining ternaries.
- React Compiler is enabled in the Vite build. Prefer plain React over prophylactic
  `useMemo`, `useCallback`, and `React.memo`.
- Clean up legacy memoization gradually when touching a file; do not do broad
  mechanical removals. Keep manual memoization only when a library contract requires
  referential stability or profiling proves a real benefit.
- Zustand with `useShallow()` for multi-slice selectors
- Skip barrel files (`index.ts`): import from explicit paths
- Use coss (Base UI) components, registered as `@coss` in `components.json`. Prefer
  coss primitives over hand-rolling.
- Use semantic HTML elements (`<button>`, `<nav>`, `<main>`) over generic `<div>`s with
  ARIA roles. Provide meaningful `alt` text, proper heading hierarchy, labels for form
  inputs, and keyboard event handlers alongside mouse events.
- Never construct Tailwind class names dynamically (e.g. `` `bg-${color}-200` ``);
  Tailwind cannot detect them. Use `style` with CSS variables instead
  (e.g. ``style={{ backgroundColor: `var(--color-${name}-200)` }}``).
- `cn()` utility for conditional class names
- Frontend calls the API via Eden treaty (`apps/web/src/lib/api.ts`). The `api` export
  is a typed proxy mirroring backend routes; use dot notation with HTTP verbs:
  `api.workspaces({ workspaceId }).get()`. Unwrap responses with `.data` / `.error`
  checks or `toAPIError()`.
- Return minimal data from endpoints and mutations. Backend handlers should only return
  what callers actually need; frontend response types should only type what they
  consume. Do not speculatively return extra fields "for completeness."
- Do not create single-use mutation hooks just to wrap an API call. Inline the API call
  at the usage site and use `Result.tryPromise` for retries instead of React Query's
  `retry` on throwaway mutations.
- Reuse existing components (`Button`, `Input`, etc.) with `className` overrides
  instead of writing inline `<button>`, `<input>`, or similar raw HTML elements. This
  keeps behaviour (focus rings, accessibility, sizing) consistent across the app.
- Prefer `useRouteContext` for data already provided by parent route loaders
  (`beforeLoad`) over firing a separate query. Extend the route context if needed
  rather than adding a query.
- When a route loader only primes a TanStack Query cache, return `void` from it so its
  return type stays out of the route tree and does not inflate type-inference cost.
- Use `useSuspenseQuery` only in route/page content where the query is preloaded or
  wrapped by an explicit local `Suspense` boundary. In shared chrome (breadcrumbs,
  headers, toolbars, sidebar shell), prefer `useQuery` so a cache miss cannot suspend
  the whole layout.
- Always use `select` with `useParams`, `useSearch`, and `useRouteContext` to subscribe
  only to the fields the component needs. Without `select`, the component rerenders on
  any param/search/context change.
- Pass `from` (or `strict: false` for shared chrome that spans routes) to
  `useParams`/`useSearch`/`Link` so types narrow from the full route union to a single
  route. The unnarrowed union is both imprecise and expensive to typecheck.
- Use `useDebouncedCallback` from `use-debounce` instead of hand-rolling debounce with
  `useRef<setTimeout>` + manual `clearTimeout`. The library handles cleanup
  automatically.
- Query option file ordering: key type -> key helpers -> input type
  (`QueryOptionsInput`) -> option factory -> hook (e.g., `useEntitiesOptions`).
- Query option factories that use `QueryOptionsInput` with a `TContext` must: define a
  named type alias matching the factory name (e.g., `ViewsOptionsInput` for
  `viewsOptions`, `ChatThreadOptionsInput` for `chatThreadOptions`), destructure
  `{ key, context }` in the parameter, and reference `key.*` / `context.*` directly in
  the body (no further destructuring). This makes it obvious at the call site and
  inside the function which values drive the cache key vs. which are runtime-only deps.
- Define a separate key type (e.g., `EntitiesPageKey`) and use it in both the
  `QueryOptionsInput` and the key helper. The key helper's parameter type must be the
  key type, not the full options input, so the key builder only accepts cache-identity
  fields.
- Never spread input objects into query keys. Explicitly destructure and reconstruct
  the key object so extra properties from callers cannot leak into the cache identity
  and cause spurious refetches.
- Key helpers must compose by spreading the parent key
  (e.g., `...entitiesKeys.all(workspaceId)`), never by duplicating the parent's array
  literal. This ensures changes to the parent key shape propagate automatically.
