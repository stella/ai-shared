## Frontend

### UX & Brand

- Use semantic design tokens (for example, `bg-muted`, `text-foreground`, and
  `border`) instead of raw colour values.
- Use the design system's primitives instead of native controls; where none exists,
  prefer semantic elements over ARIA roles. Keyboard behavior accompanies pointer
  behavior.
- Use a component's variants and sizes; add a variant instead of restyling it
  through `className`. Spacing around the component stays the caller's.
- When using statically scanned utility CSS, do not construct class names dynamically
  (for example, `` `bg-${token}-200` ``). Use an explicit class map or a style backed
  by CSS custom properties.

### UI Architecture

- Prefer explicit branches over nested ternaries. Extract complex conditional UI into
  a small helper or component that returns early.
- Subscribe to the smallest state slice a view needs. Broad subscriptions cause
  unrelated state changes to rerender the view.
- Return minimal data from endpoints and mutations. Response types should contain only
  what callers consume; do not add fields speculatively for completeness.
