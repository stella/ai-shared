## Testing

Only test what can actually go wrong: bugs the type system, framework, or linter would
miss. Prefer invariants over examples when the input space is large. Full conventions
in `/conventions-testing`.

A test guarding a detector or backstop must use inputs the detector can actually
match: production-shaped ids and payloads, not shortened stand-ins a UUID or
pattern guard can never trip; an "asserts nothing bad happened" test over such
fixtures is vacuous. Where a map declares paths or cases, assert declared set
equals exercised set in both directions, and pin fixture literals that stand in
for a producer's output with `satisfies` against the producer's return type.
