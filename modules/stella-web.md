## Stella Web Stack

- Follow the brand deck, micro-interaction guidance, and visual-noise rules in
  `/conventions-ux`.
- Use coss (Base UI) components, registered as `@coss` in `components.json`. Prefer
  coss primitives over hand-rolled controls.
- Use the shared `cn()` utility for conditional class names.
- Use Zustand's `useShallow()` for selectors that return multiple state slices.
- Use `useDebouncedCallback` from `use-debounce` instead of implementing debounce with
  `useRef<setTimeout>` and manual cleanup.
- Call the API through the typed client in `apps/web/src/lib/api.ts`. The `api`
  export is a typed proxy over the generated route table; use dot notation with HTTP
  verbs, for example `api.workspaces({ workspaceId }).get()`. Unwrap responses with
  `.data`/`.error` checks or `toAPIError()`; query functions read through
  `readQueryResult`.
- Do not create a single-use mutation hook merely to wrap an API call; inline the
  call at its usage site. Mutations are never retried silently.
