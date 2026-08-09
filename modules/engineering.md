## Meta Preferences

- Never manually reformat code you did not semantically change (auto-formatter output
  from `bun run format` is fine to include)
- In prose, vary punctuation: prefer colons, semicolons, commas, and parentheses
  over em dashes. This does not apply to source code, command syntax, generated
  content, or exact identifiers.
- Omit needless words. Vigorous writing is concise: a sentence should contain no
  unnecessary words, a paragraph no unnecessary sentences, for the same reason that a
  drawing should have no unnecessary lines and a machine no unnecessary parts. Applies
  to comments, commits, PRs, and docs.
- Do not add backward-compatibility machinery by default. First identify the concrete
  older clients, persisted data, integrations, or deployment states that must remain
  supported. When none exist, prefer a clean migration or cutover; aliases, dual
  reads/writes, and staged paths add permanent complexity. When compatibility is
  required, document its boundary and removal condition.
- Prefer explicit over implicit; when a backend endpoint accepts a discriminator
  (e.g., `?type=document|file`), thread it through the full stack (URL params,
  component props) instead of hardcoding a default on the frontend
- If TypeScript can make a class of bug structurally impossible (branded types,
  discriminated unions, exhaustive checks), prefer that over runtime validation or
  manual discipline
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
  a permanent yes/no question; a two-value union, enum, or equivalent domain type
  now is usually cheaper than migrating an `isX` flag later.
- Conventional Commits: `feat:`, `chore:`, `fix:`, `docs:`
- Rebase feature branches onto main (linear history)
- Enable `git rerere` (`git config --global rerere.enabled true`, plus
  `rerere.autoupdate true` to auto-stage what it resolves) so conflict
  resolutions are recorded and auto-replayed across repeated or long rebases
- Fail fast: validate at boundaries, return/throw early
- Minimize brace nesting: invert conditions, early returns
- Use named constants, not string literals for domain values
- No direct `document.cookie` assignment
- Avoid spread in loop accumulators (use `.push()`)
- If you encounter a pre-existing bug or lint error, fix it. Preserve focus through
  isolation, not omission: use a separate commit when the fix is small and shares the
  same validation surface; use a separate focused PR when it expands the subsystem,
  risk, or review burden. Never leave a confirmed defect merely to keep a diff narrow.
- Orchestrate across model tiers when your harness supports subagents and model
  selection: delegate well-scoped, mechanical, or independently verifiable subtasks
  (edits, searches, refactors, test runs) to a subagent on the cheapest model that
  does them correctly; keep planning, cross-cutting design, security-sensitive work,
  and final review on the primary model. If your tooling has no subagents or model
  selection, ignore this.

## Design Principles

- No hidden complexity; code is the docs. Every operation must work for humans,
  scripts, and AI agents alike.
- No lock-in: standard formats, self-hosting is first-class.
- AI is a tool, not a persona. No anthropomorphizing.
- Performance is non-negotiable. Batch operations, minimize round-trips, lazy-load
  aggressively.
- **Vertical slices over horizontal layers.** Features are independent end-to-end
  slices (own routes, components, handlers). New capabilities land in their own slice;
  existing code stays untouched.
