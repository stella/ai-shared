## Error Handling

- Use `better-result` for typed error handling. Do not use try-catch for control flow;
  wrap failable operations with `Result` instead. Try-catch is only acceptable at
  boundary layers (top-level request handlers, framework hooks).
- Split error semantics deliberately: use `panic(...)` for impossible internal
  invariants and programmer misuse, `TaggedError` subclasses for expected
  business/config/runtime failures, and analytics/logging capture for telemetry-only
  paths that continue execution.
- Prefer tagged errors (`APIError`, `TaggedError` subclasses) over bare `new Error()`.
  Tagged errors carry structured context (status, cause) for error handling and
  reporting. Every `TaggedError` must include a `message: string` field.
- Outside boundary layers, return `Result.err` instead of throwing. Every failure is
  surfaced to the user or propagated to the caller through the project's shared
  notifier or capture owner; never swallow it. No empty `.catch` fallbacks and no
  bare `void promise`.
- Do not leave ad hoc `console.error(...)` in product code. Route telemetry-only
  failures through the shared analytics or logging helpers so observability stays
  structured.
