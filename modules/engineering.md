## Meta Preferences

- Use Computer Use or desktop/browser UI control only when the user explicitly asks for it. General fix, build, and test requests do not authorize operating user applications; isolated automated tests and code-level checks remain allowed.
- Never manually reformat code you did not semantically change (auto-formatter output
  from `bun fmt` is fine to include)
- In prose, vary punctuation: prefer colons, semicolons, commas, and parentheses
  over em dashes. This does not apply to source code, command syntax, generated
  content, or exact identifiers.
- Omit needless words in comments, commits, PRs, and docs.
- Do not add backward-compatibility machinery by default. First identify the concrete
  older clients, persisted data, integrations, or deployment states that must remain
  supported. When none exist, prefer a clean migration or cutover; aliases, dual
  reads/writes, and staged paths add permanent complexity. When compatibility is
  required, document its boundary and removal condition.
- Prefer explicit over implicit; when a backend endpoint accepts a discriminator
  (e.g., `?type=document|file`), thread it through the full stack (URL params,
  component props) instead of hardcoding a default on the frontend
- Kill the bug class, not the instance: for a recurring or systemic defect, use the
  strongest applicable mechanism. Make invalid states unrepresentable first; cover
  remaining behavior with a property, invariant, idempotence, or fixed-point test over
  the input class. Enforce boundaries with a lint rule or CI check. Keep a minimal
  example regression only when the broader invariant cannot express the failure. When
  correctness depends on a helper being called at every call site, enforce it with a
  custom lint rule, not developer discipline. Do not over-apply this to genuine
  heuristics (a debounce timer is not a bug class).
- Silent drift is a bug class: when structure X must mirror structure Y (a
  projection map mirroring handler payloads, a frontend list mirroring backend
  classifications, a fixture mirroring a real schema), derive one side from the
  other or bind them with a compile-time check; never rely on discipline or a
  hand-updated mirror test. A lookup whose miss means a bug must panic or emit
  telemetry, never fall back silently to a default.
- Surface conflicts, do not average them. When two existing patterns contradict,
  adopt one and never blend them into a hybrid. Precedence: documented convention
  and enforced guards (lint rules, ratchet metrics, committed baselines), then the
  most recent well-tested code, then the most widespread. If a convention and a
  guard disagree, that disagreement is itself the finding: report it, do not
  resolve it silently. Always report the conflict: the winner, the losing call
  sites, and a concrete unification proposal (codemod, lint rule, ratchet metric).
  Unifying is a scope decision, so propose it and let the user pick the moment; if
  they defer, land the guard so the losing pattern can only shrink.
- Avoid boolean fields for states that may grow. Use a named discriminator or
  domain type for values that answer "which kind/status/mode/type?" rather than
  a permanent yes/no question; a two-value closed union (a sum-type enum only in
  languages such as Rust) or equivalent domain type
  now is usually cheaper than migrating an `isX` flag later.
- Conventional Commits, `type(scope): summary`: `feat`, `fix`, `refactor`, `perf`,
  `test`, `docs`, `ci`, `chore`.
- Keep feature branches rebased onto main so review sees a clean diff. How a
  branch lands (merge queue, squash) follows the repository's merge policy; main
  stays linear either way.
- Enable `git rerere` in the clone, never globally (`git config rerere.enabled
true`, plus `rerere.autoupdate true` to auto-stage what it resolves; one-off:
  `git -c rerere.enabled=true -c rerere.autoupdate=true merge ...`) so conflict
  resolutions are recorded and auto-replayed across repeated or long rebases
- A failed read never comes back as an empty value (`[]`, `null`, `{}`): return a
  typed outcome or let the failure propagate, so "nothing there" and "could not
  read" stay distinguishable.
- Every outbound request carries a timeout.
- Modules that must be deterministic take the clock and randomness as inputs
  instead of reading them ambiently.
- Use named constants, not string literals for domain values
- If you encounter a pre-existing bug or lint error, fix it. Preserve focus through
  isolation, not omission: use a separate commit when the fix is small and shares the
  same validation surface; use a separate focused PR when it expands the subsystem,
  risk, or review burden. Never leave a confirmed defect merely to keep a diff narrow.
- Comments explain a non-obvious invariant, trade-off, safety constraint, or why
  the code exists. Do not narrate the next statement, add empty documentation
  blocks, or label closing braces.
- Make abstractions earn their keep. Avoid pass-through wrappers, single-use
  helpers, and interfaces with one implementation unless they establish a real
  ownership boundary, contract, or test seam.
- Prefer deleting concepts, branches, and layers over moving complexity around.
  Keep feature-specific behavior at its canonical owner; do not scatter flags and
  special cases through shared flows.
- Defensive code belongs at real trust and failure boundaries. Do not add null
  checks, silent fallbacks, or catch-and-log blocks for states already excluded by
  types, validation, or framework guarantees.
- No forward-compatibility placeholders: never ship a flag, option, field, or
  export that is accepted but has no effect "for later". Add it in the PR that
  wires it end to end.
- Orchestrate across model tiers when your harness supports subagents and model
  selection: delegate well-scoped, mechanical, or independently verifiable subtasks
  (edits, searches, refactors, test runs) to a subagent on the cheapest model that
  does them correctly; keep planning, cross-cutting design, security-sensitive work,
  and final review on the primary model. If your tooling has no subagents or model
  selection, ignore this.

## Design Principles

- Every operation must work for humans, scripts, and AI agents alike.
- No lock-in: standard formats, self-hosting is first-class.
- AI is a tool, not a persona. No anthropomorphizing.
- **Vertical slices over horizontal layers.** Features have one owning end-to-end
  slice (routes, components, handlers). Keep cross-slice changes minimal; change
  existing code when the end-to-end contract requires it.
