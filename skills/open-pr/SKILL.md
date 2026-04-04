# Open PR

Open a pull request for the current branch with a clean title, a useful
description, and enough verification context for reviewers.

## Instructions

1. **Check branch state**:
   - confirm the current branch
   - confirm it is not the default branch
   - inspect `git status --short`
   - inspect the diff against the intended base branch

2. **Sanity-check what is being proposed**:
   - summarize the user-facing change
   - look for accidental unrelated edits
   - if the branch mixes unrelated work, stop and say so

3. **Run the relevant verification**:
   - tests
   - lint
   - typecheck
   - build

   Use the repo's actual commands. If something cannot be run, say so
   in the PR body.

4. **Push the branch** if needed:

   ```bash
   git push -u origin <branch>
   ```

5. **Write a good PR title**:
   - short
   - specific
   - outcome-oriented
   - neutral in tone

6. **Write a useful PR body** with:
   - what changed
   - why it changed
   - any important design choice or tradeoff
   - verification performed
   - any remaining risk or follow-up

7. **Open the PR**:

   ```bash
   gh pr create
   ```

   Prefer an explicit title/body rather than interactive editing.

8. **Run one rabbit round after opening**:
   - invoke `/rabbit-round` once
   - if it returns `pending_bots`, stop and leave the PR as draft
   - if it returns `needs_changes` or `failing_ci`, address the issues
     and rerun manually later
   - if it returns `clean`, report that the PR is ready for the next
     human-controlled step

   Do not assume background scheduling tools exist. Do not create cron
   jobs or loops from this skill.

9. **After opening**, fetch the PR URL/number and report it back.

## Guidelines

- Do not mention internal tool provenance unless the user wants that.
- Do not hide failing checks or missing verification.
- Keep the title/body reviewer-friendly, not changelog-like.
- If the repo has a PR template, follow it.
