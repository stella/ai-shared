## Meta Preferences

- Never manually reformat code you did not semantically change (auto-formatter output
  from `bun run format` is fine to include)
- Vary punctuation: prefer colons, semicolons, commas, and parentheses over em dashes
- Prefer explicit over implicit; when a backend endpoint accepts a discriminator
  (e.g., `?type=document|file`), thread it through the full stack (URL params,
  component props) instead of hardcoding a default on the frontend
- If TypeScript can make a class of bug structurally impossible (branded types,
  discriminated unions, exhaustive checks), prefer that over runtime validation or
  manual discipline
- Conventional Commits: `feat:`, `chore:`, `fix:`, `docs:`
- Rebase feature branches onto main (linear history)
- Fail fast: validate at boundaries, return/throw early
- Minimize brace nesting: invert conditions, early returns
- Use named constants, not string literals for domain values
- No direct `document.cookie` assignment
- Avoid spread in loop accumulators (use `.push()`)
- If you encounter a pre-existing bug or lint error while working on something else,
  fix it (separate commit)

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
