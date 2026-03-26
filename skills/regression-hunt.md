# Regression Hunt

Track down a behavior that used to work and now fails, changed, or
regressed. Use this when a bug report points to a recent breakage,
especially when the cause is not obvious yet.

## Arguments

$ARGUMENTS — A short description of what regressed.

Helpful extras when available:
- failing test name or file
- error message or log line
- expected behavior
- actual behavior
- suspect PR, branch, commit, or file
- reproduction command, input, route, or endpoint

A plain-English bug report is enough to start. The rest are accelerators,
not requirements.

## Instructions

1. **Restate the regression clearly**:
   - what used to work?
   - what is broken now?
   - what is expected instead?

2. **Reproduce it first**:
   - run the failing test if one exists
   - otherwise use the provided command, input, endpoint, or scenario
   - if no reproduction exists, build the smallest one you can

3. **Bound the problem**:
   - identify where the behavior lives
   - narrow the suspect files, modules, or commits
   - compare against the last known good behavior if possible

4. **Inspect recent change history**:
   - current diff
   - recent commits touching the area
   - suspect PRs or refactors

   Use git history when helpful, but do not stop at blame; verify the actual cause.

5. **Find the root cause**:
   - avoid fixing only the symptom
   - identify the exact logic, assumption, or edge case that changed

6. **Fix it minimally**:
   - preserve intended newer behavior where possible
   - do not revert unrelated improvements just to make the symptom disappear

7. **Add regression coverage**:
   - add or update a test that would have caught this exact issue
   - prefer the smallest focused regression test over broad churn

8. **Verify**:
   - rerun the focused regression check first
   - then run the relevant wider checks for confidence

9. **Report back with**:
   - reproduction
   - root cause
   - fix
   - verification
   - any remaining uncertainty
