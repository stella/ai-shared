## Coding Conventions

### TypeScript

- No enums: use `as const` objects or union types
- Model mutually exclusive internal states as discriminated unions with a stable
  `type`, `status`, or domain-specific discriminator. Avoid boolean flag sets plus
  optional payload fields when only some combinations are valid.
- When the linter blocks an `as` cast, restructure to narrow properly (type guards,
  `in` checks, records instead of arrays). If truly unavoidable, ask before adding and
  include a `// SAFETY:` comment explaining why the cast is sound.
- When a type mismatch appears, trace it to the source (e.g., the handler or query
  that produces the wrong type) rather than casting at the consumer. Check git to
  verify you did not introduce the mismatch yourself before blaming the framework.
- Never annotate or cast a value the compiler already infers, and never pass explicit
  type arguments to inference-driven hooks (`useLoaderData<T>()`, `useQuery<T>()`, Eden
  calls). Every annotation or explicit generic masks real errors and breaks the
  inference chain; let inference flow and narrow at the boundary instead.
- Validate object literals against a large union type (route, link, query options) with
  `as const satisfies T`, not a `: T` annotation. `satisfies` checks the value without
  widening it or paying the annotation's instantiation cost.
- Use `.at(0)` when the element may not exist (signals possible absence). Use `[0]`
  only when existence is already established (length check, or a `// SAFETY:` comment).
- Prefer arrow functions over function expressions
- Destructure in the parameter when the intermediate variable is not reused
  (e.g., `{ body: { file, name } }` not `body` then `const { file, name } = body`)
- Prefer discriminated union narrowing (`obj.type === "x"`) over `"key" in obj`
  checks. Use `in` only when the type is not a discriminated union and there is no
  discriminator to check.
- For function arguments, including helpers: use normal typed parameters for one
  argument, and also for two arguments when their types are different enough to stay
  readable. Use a named `SomethingOptions`, `SomethingArgs`, or `SomethingParams`
  object for 3+ arguments, or when two same-type or otherwise interchangeable
  positional arguments would be easy to mix up. Reserve `Props` for React component
  props.
- Reuse util types from libraries instead of hand-rolling (e.g.,
  `React.PropsWithChildren<P>` for props with children,
  `React.ComponentProps<"button">` for HTML element props). Check React, TanStack, and
  other deps before defining custom equivalents.
- Keep helper-local types close to the helper they describe: put `SomethingOptions`,
  `SomethingResult`, and similar aliases immediately above the function, not in a
  file-level type dump far away from the implementation.
- If a return type is noisy enough to hurt readability, hoist it into a nearby alias
  such as `SomethingResult` and use it in the signature (e.g., `SomethingResult` or
  `Promise<SomethingResult>`). If the return type is simple, keep it inline.
- Watch type-instantiation cost in hot generic paths (route trees, query options, Eden
  surfaces): prefer narrowing (`satisfies`, route `from`, query `select`) over
  annotation, and keep large unused types out of inferred return positions.

### Module Side Effects

- **No module-level side effects in shared modules.** If a module exports both a
  side-effecting singleton (DB connection, auth client, pool) and reusable utilities,
  split them: put utilities in a separate file so consumers can import them without
  triggering initialization. The side-effecting module re-exports for convenience.
- **Never import test-only types in prod code.** If a prod generic needs to accept
  both prod and test instances, use a structural constraint (`{ transaction: ... }`)
  instead of importing a type from a test file.
- **Defer eager initialization with lazy singletons.** When a module-level call
  (`betterAuth()`, `drizzle()`) depends on another module's export, wrap it in a
  `getX()` getter so it runs at first use, not at import time. This prevents TDZ
  errors from non-deterministic module evaluation order.
