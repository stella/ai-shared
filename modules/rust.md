## Coding Conventions

### Rust

- Use Rust 2024 for new crates. Pin the toolchain in `rust-toolchain.toml` and
  keep `rustfmt` and `clippy` installed.
- In workspaces, put shared lint policy in `[workspace.lints]`; member crates
  should opt in with `[lints] workspace = true`.
- Treat
  `cargo clippy --workspace --all-targets --all-features -- -D warnings` as the
  baseline quality gate unless a repo documents a narrower command.
- Use Dylint for shared stella-specific Rust lints that Clippy cannot express.
  Run `cargo dylint --workspace --all` after Clippy when the repo has
  `dylint.toml`.
- Prefer fixing custom lint rules at the shared source over broad local
  suppressions when a rule is wrong across repos.
- Forbid unsafe code by default. If `unsafe` is truly required, keep it in a
  tiny module with a `SAFETY:` comment explaining the invariant the caller and
  callee rely on.
- Do not use `unwrap()`, `expect()`, `panic!()`, `todo!()`, or
  `unimplemented!()` in production code. Return typed errors or make the
  impossible state unrepresentable.
- Avoid unchecked indexing and string slicing. Prefer iterator methods,
  `.get()`, typed span helpers, and APIs that preserve UTF-8 boundary safety.
- Avoid `as` casts. Prefer `TryFrom`, `From`, explicit checked conversion
  helpers, or domain newtypes.
- Prefer narrow domain types over primitive strings/numbers for IDs, byte
  offsets, language codes, entity labels, versions, and artifact formats.
- Keep struct fields private unless direct construction is part of the public
  contract. Use smart constructors for values that must satisfy invariants.
- Use enums for real closed domain states and boolean-blind choices where
  variants carry domain meaning. For callsite ergonomics alone, prefer an
  options struct or `bon` builder over an enum that only simulates named
  arguments.
- For functions, use positional parameters for one or two obvious arguments.
  Use a named `SomethingOptions`, `SomethingArgs`, or `SomethingParams` struct
  for 3+ arguments or same-type arguments that are easy to swap.
- Use `bon` builders for public APIs, constructors, or setup functions with
  many optional/boolean parameters where named callsites improve readability. Do
  not use it to hide unclear domain modeling.
- Prefer `Result<T, E>` with a concrete error enum for library code. Use
  `thiserror` for typed errors; use `miette` only where human-facing diagnostics
  are valuable.
- Add `#[must_use]` to builders, config transforms, computed results, and APIs
  where ignoring the return value is likely a bug.
- Keep comments concise. Comment invariants, non-obvious algorithms, generated
  data contracts, and safety boundaries; do not narrate straightforward code.
- Keep data out of code. Domain dictionaries, language rules, fixtures, and
  generated artifacts should live in reproducible data files or build outputs,
  organized by language/concept where relevant.
- Public docs, logs, diagnostics, and comments should write `stella` lowercase.

### Rust Extensible Rule Systems

- For analyzers, detectors, linters, validators, and similar extensible rule
  systems, prefer module-owned declarative rule specs. Co-locate the rule id,
  diagnostic id, required inputs, dependencies, support resources, activation
  predicate, execution hook, and tests with the rule implementation.
- Keep central registries thin. They should preserve cross-module ordering and
  expose iteration, not contain rule-specific branching, diagnostic mapping, or
  activation logic.
- Reach for macros or derives only when they remove repeated plumbing across
  many rules. Humans should write domain behavior; generated code should handle
  mechanical metadata wiring.

### Rust Module Side Effects

- Avoid expensive module-level initialization. Prefer explicit prepare/build
  steps, lazy singletons, or build-time generated artifacts.
- Do not do filesystem, network, environment, or global logger setup from
  library imports. Applications and CLIs own process-level side effects.
- Keep binding crates thin. Business logic belongs in the Rust core crate;
  TypeScript, Python, WASM, and NAPI layers should translate types and call the
  same core logic.
- Keep generated artifacts versioned and validated at load time. Reject stale,
  mismatched, or oversized artifacts with typed errors.

### Rust Testing

- Use `cargo nextest run --workspace --all-features` when available; otherwise
  use the repo's documented `cargo test` command.
- Add property tests with `proptest` for parsers, span math, redaction,
  normalization, serialization, and logic where examples do not cover the input
  space.
- Add fuzz targets with `cargo-fuzz` for byte/string parsers, document readers,
  search primitives, artifact decoders, and boundary-sensitive code.
- Use fixture parity tests when replacing an implementation in another language.
  The Rust core, TypeScript binding, and Python binding should produce the same
  structured result from the same fixtures.
- Benchmark behavior that is part of the product. Track cold start, warm run,
  artifact load, preparation, and execution separately.
- Do not snapshot sensitive raw text unless the fixture is intentionally public
  and minimal. Prefer normalized summaries, counts, spans, labels, and redacted
  output.
