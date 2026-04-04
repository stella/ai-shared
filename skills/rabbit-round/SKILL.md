---
name: rabbit-round
description: 'Process automated PR review comments systematically. Use this for CodeRabbit, Gemini, GitHub Copilot, Devin, Greptile, and similar bots.'
---

# Rabbit Round

Process automated PR review comments systematically. Use this for
CodeRabbit, Gemini, GitHub Copilot, Devin, Greptile, and similar bots.

This skill is **single-pass**. It does one round, reports the current
state, and stops. Do not schedule future runs from inside this skill.

## Instructions

1. **Get context**:
   - get the PR number for the current branch
   - get the current GitHub username for attribution
   - get the current commit SHA

   Prefer GitHub connector tools when available. Use `gh` via
   `exec_command` when the connector does not expose the needed data.

2. **Fetch current bot feedback**:
   - fetch PR review comments
   - fetch top-level PR issue comments
   - fetch unresolved review threads

   Prefer GitHub connector tools for comment reads and replies. Use
   `gh api graphql` via `exec_command` for review thread resolution
   state, resolving review threads, and minimizing issue comments.

   Filter for known bot accounts only. Never treat human comments as
   bot comments.

3. **Check review-bot status before declaring the round clean**:
   - inspect PR checks for bot jobs such as CodeRabbit, Copilot,
     Gemini, Greptile, Devin, and similar tools
   - if any review bot checks are pending, queued, requested,
     waiting, or in progress, the round is not clean

4. **Triage each bot comment**:
   - **Accept** if it improves correctness, safety, maintainability,
     test coverage, or repo-convention alignment
   - **Push back** if it is incorrect, overreaching, based on a wrong
     assumption, or conflicts with documented conventions

5. **Implement accepted suggestions**:
   - make the code changes
   - group related fixes logically
   - run the relevant project checks

6. **Reply to each addressed bot comment**:
   - reply inline for review comments
   - reply on the PR thread for top-level issue comments

   Reply patterns:
   - accepted and implemented
   - agreed, implemented with a small adjustment
   - already addressed in commit `{hash}`
   - pushing back, with a concrete reason and source or repo convention

   Include `CC on behalf of @{username}` when the repo requires it.

7. **Resolve or minimize only addressed bot feedback**:
   - resolve bot review threads only after the change is implemented
     or the pushback is clearly documented
   - minimize bot issue comments only after they are addressed
   - never resolve or minimize human comments

8. **Process summary-style bot comments too**:
   - if a bot posts a summary comment instead of inline comments,
     treat each concrete item in that summary as actionable feedback
   - do not treat summary comments as informational-only

9. **Check CI and fix real failures**:
   - inspect failing PR checks and logs
   - fix root causes, not symptoms
   - if CI is still failing at the end of the round, report that

10. **Commit and push** if you made changes:
    - use a neutral commit message such as
      `fix: address review comments`
    - push to the active PR branch

11. **Report one round status and stop**:

    Return exactly one of:
    - `clean`: no actionable bot comments remain, review bot checks are
      complete, and CI is green
    - `pending_bots`: review bots have not finished yet
    - `needs_changes`: actionable bot comments remain
    - `failing_ci`: CI is failing and still needs fixes

    If the round is not `clean`, summarize what remains and stop. A
    caller may invoke `/rabbit-round` again later.

## Decision Guidelines

**Accept when the suggestion:**
- fixes a bug or real edge case
- improves type safety
- adds missing tests
- aligns with existing repo patterns
- tightens security or validation appropriately

**Push back when the suggestion:**
- assumes facts not true in this codebase
- conflicts with canonical specs or official sources
- adds complexity for little benefit
- would undo a deliberate, documented decision
- is purely stylistic and inconsistent with the repo
