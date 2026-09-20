#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

new_consumer() {
  local name="$1"
  local consumer="$TEST_ROOT/$name"

  mkdir -p "$consumer/.ai"
  ln -s "$SOURCE_ROOT" "$consumer/.ai/shared"
  printf '%s\n' "$consumer"
}

run_sync() {
  local consumer="$1"
  bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" "$consumer"
}

expect_failure() {
  local consumer="$1"
  local expected="$2"
  local output

  if output="$(run_sync "$consumer" 2>&1)"; then
    echo "error: sync unexpectedly accepted $consumer" >&2
    exit 1
  fi
  if [[ "$output" != *"$expected"* ]]; then
    echo "error: expected '$expected', got: $output" >&2
    exit 1
  fi
}

valid_consumer="$(new_consumer valid)"
printf '%s\n' '{"sharedRootFiles":["rustfmt.toml"]}' > "$valid_consumer/.ai/manifest.json"
mkdir -p "$valid_consumer/.claude/commands" "$valid_consumer/.ai/local-skills"
printf '%s\n' '# Plan' > "$valid_consumer/.claude/commands/plan.md"
printf '%s\n' '---' 'name: local-hinted' 'description: "Local skill."' \
  'argument-hint: "[target]"' '---' '' '# Local Hinted' '' 'Body.' \
  > "$valid_consumer/.ai/local-skills/local-hinted.md"
run_sync "$valid_consumer"
cmp "$SOURCE_ROOT/rustfmt.toml" "$valid_consumer/rustfmt.toml"
if [ -e "$valid_consumer/.claude/commands" ]; then
  echo "error: sync kept the legacy .claude/commands directory" >&2
  exit 1
fi
for skill in plan regression-hunt local-hinted; do
  cmp "$valid_consumer/.claude/skills/$skill/SKILL.md" "$valid_consumer/.agents/skills/$skill/SKILL.md"
  grep -q '^description: ' "$valid_consumer/.claude/skills/$skill/SKILL.md"
done
grep -q '^argument-hint: "\[what regressed\]"' "$valid_consumer/.claude/skills/regression-hunt/SKILL.md"
grep -q '^argument-hint: "\[target\]"' "$valid_consumer/.claude/skills/local-hinted/SKILL.md"
for skill_root in .agents/skills .claude/skills; do
  open_pr_skill="$valid_consumer/$skill_root/open-pr/SKILL.md"
  rabbit_round_skill="$valid_consumer/$skill_root/rabbit-round/SKILL.md"
  finish_pr_skill="$valid_consumer/$skill_root/finish-pr/SKILL.md"
  grep -Fqx 'PR_METADATA="$(gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json number,baseRefName,headRefOid,headRepository,url)"' \
    "$open_pr_skill"
  if sed -n '/^## 3\. Rebase the Correct Layer$/,/^## 4\. Review the Actual Change$/p' \
    "$open_pr_skill" \
    | grep 'gh pr view' \
    | grep -Fvx 'PR_METADATA="$(gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json number,baseRefName,headRefOid,headRepository,url)"' \
    >/dev/null; then
    echo "error: open-pr contains an unpinned gh pr view lookup" >&2
    exit 1
  fi
  grep -Fq '`failing_ci` > `needs_changes` > `pending_bots` > `clean`' "$rabbit_round_skill"
  grep -Fq 'review-comment' "$rabbit_round_skill"
  grep -Fq 'issue-comment' "$rabbit_round_skill"
  grep -Fq 'surface, node ID, and content exactly match' "$rabbit_round_skill"
  grep -Fq 'make it stacked only when repository policy or the existing branch' "$finish_pr_skill"
  if grep -Fq 'Open one stacked follow-up PR' "$finish_pr_skill"; then
    echo "error: finish-pr requires an unconditional stacked follow-up" >&2
    exit 1
  fi
done
bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" --check "$valid_consumer"

mkdir -p "$valid_consumer/.claude/commands"
if bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" --check "$valid_consumer" >/dev/null 2>&1; then
  echo "error: check accepted a legacy .claude/commands directory" >&2
  exit 1
fi
rmdir "$valid_consumer/.claude/commands"

dangling_consumer="$(new_consumer dangling)"
mkdir -p "$dangling_consumer/.ai/local-skills"
printf '%s\n' '# Dangling' '' 'Read `/missing-skill` first.' \
  > "$dangling_consumer/.ai/local-skills/dangling.md"
expect_failure "$dangling_consumer" 'references `/missing-skill`, which is not a generated skill'

dangling_prompt_consumer="$(new_consumer dangling-prompt)"
mkdir -p "$dangling_prompt_consumer/.ai/local"
printf '%s\n' '## Routing' '' 'See `/conventions-nowhere`.' > "$dangling_prompt_consumer/.ai/local/agents.md"
printf '%s\n' '{"agents":{"modules":["engineering"],"local":".ai/local/agents.md"}}' \
  > "$dangling_prompt_consumer/.ai/manifest.json"
expect_failure "$dangling_prompt_consumer" 'references `/conventions-nowhere`, which is not a generated skill'

scalar_consumer="$(new_consumer scalar)"
printf '%s\n' '{"sharedRootFiles":"rustfmt.toml"}' > "$scalar_consumer/.ai/manifest.json"
expect_failure "$scalar_consumer" "manifest.sharedRootFiles must be an array"

empty_consumer="$(new_consumer empty)"
printf '%s\n' '{"sharedRootFiles":[""]}' > "$empty_consumer/.ai/manifest.json"
expect_failure "$empty_consumer" "manifest.sharedRootFiles[0] must be a non-empty string"

non_string_consumer="$(new_consumer non-string)"
printf '%s\n' '{"sharedRootFiles":[42]}' > "$non_string_consumer/.ai/manifest.json"
expect_failure "$non_string_consumer" "manifest.sharedRootFiles[0] must be a non-empty string"

missing_consumer="$(new_consumer missing)"
printf '%s\n' '{"sharedRootFiles":["missing.toml"]}' > "$missing_consumer/.ai/manifest.json"
expect_failure "$missing_consumer" "manifest.sharedRootFiles[0] references a missing shared file"

traversal_consumer="$(new_consumer traversal)"
printf '%s\n' '{"sharedRootFiles":["../outside.toml"]}' > "$traversal_consumer/.ai/manifest.json"
expect_failure "$traversal_consumer" 'manifest.sharedRootFiles[0] must be a repo-relative path without ".."'

scoped_consumer="$(new_consumer scoped)"
mkdir -p \
  "$scoped_consumer/.ai/local" \
  "$scoped_consumer/packages/core" \
  "$scoped_consumer/packages/react"
printf '%s\n' '# Root rules' > "$scoped_consumer/.ai/local/agents.md"
printf '%s\n' '# Core rules' > "$scoped_consumer/.ai/local/core-agents.md"
printf '%s\n' '# React rules' > "$scoped_consumer/.ai/local/react-agents.md"
printf '%s\n' '{
  "agents": {
    "title": "Test Guidelines",
    "modules": ["engineering"],
    "local": ".ai/local/agents.md",
    "scopes": [
      {
        "path": "packages/core",
        "local": ".ai/local/core-agents.md"
      },
      {
        "path": "packages/react",
        "modules": ["react"],
        "local": ".ai/local/react-agents.md"
      }
    ]
  }
}' > "$scoped_consumer/.ai/manifest.json"
run_sync "$scoped_consumer"
grep -q '# Test Guidelines' "$scoped_consumer/AGENTS.md"
grep -q '# Root rules' "$scoped_consumer/AGENTS.md"
grep -q '# Core rules' "$scoped_consumer/packages/core/AGENTS.md"
grep -q '## React' "$scoped_consumer/packages/react/AGENTS.md"
grep -q '# React rules' "$scoped_consumer/packages/react/AGENTS.md"
test ! -e "$scoped_consumer/CLAUDE.md"
test ! -e "$scoped_consumer/packages/react/CLAUDE.md"
test -f "$scoped_consumer/packages/react/GEMINI.md"
expected_shim=$'<!-- Generated by .ai/shared/scripts/sync-ai-skills.sh from .ai/manifest.json. -->\n\n@AGENTS.md'
if [ "$(sed -n '1,3p' "$scoped_consumer/packages/react/GEMINI.md")" != "$expected_shim" ]; then
  echo "error: generated scoped shim is not formatter-stable: GEMINI.md" >&2
  exit 1
fi
if grep -q 'CLAUDE.md' "$scoped_consumer/.ai/generated-agent-files.txt"; then
  echo "error: generated prompt registry includes a Claude alias" >&2
  exit 1
fi
grep -q 'packages/core/AGENTS.md' "$scoped_consumer/.ai/generated-agent-files.txt"
bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" --check "$scoped_consumer"

cp "$scoped_consumer/.ai/generated-agent-files.txt" "$scoped_consumer/.ai/generated-agent-files.txt.next"
for legacy_variant in commands skills; do
  if [ "$legacy_variant" = commands ]; then
    legacy_skill_guidance='Use the project skills in `.agents/skills/` or `.claude/commands/` when a task'
    legacy_skill_continuation='matches one of those workflows.'
  else
    legacy_skill_guidance='Use the project skills in `.claude/skills/` when a task matches one of those'
    legacy_skill_continuation='workflows.'
  fi
  printf '%s\n' \
    '@AGENTS.md' \
    '' \
    '## Claude Code' \
    '' \
    "$legacy_skill_guidance" \
    "$legacy_skill_continuation" \
    > "$scoped_consumer/CLAUDE.md"
  printf '%s\n' \
    '<!-- Generated by .ai/shared/scripts/sync-ai-skills.sh from .ai/manifest.json. -->' \
    '' \
    '@AGENTS.md' \
    > "$scoped_consumer/packages/react/CLAUDE.md"
  printf '%s\n' \
    'CLAUDE.md' \
    'packages/react/CLAUDE.md' \
    >> "$scoped_consumer/.ai/generated-agent-files.txt"
  sort -o "$scoped_consumer/.ai/generated-agent-files.txt" \
    "$scoped_consumer/.ai/generated-agent-files.txt"
  run_sync "$scoped_consumer"
  test ! -e "$scoped_consumer/CLAUDE.md"
  test ! -e "$scoped_consumer/packages/react/CLAUDE.md"
  cmp "$scoped_consumer/.ai/generated-agent-files.txt.next" \
    "$scoped_consumer/.ai/generated-agent-files.txt"
done
rm "$scoped_consumer/.ai/generated-agent-files.txt.next"

printf '%s\n' '# Hand-written Claude guidance' > "$scoped_consumer/CLAUDE.md"
printf '%s\n' 'CLAUDE.md' >> "$scoped_consumer/.ai/generated-agent-files.txt"
sort -o "$scoped_consumer/.ai/generated-agent-files.txt" \
  "$scoped_consumer/.ai/generated-agent-files.txt"
expect_failure "$scoped_consumer" "refusing to remove an unmarked prompt file: CLAUDE.md"
rm "$scoped_consumer/CLAUDE.md"
grep -v '^CLAUDE.md$' "$scoped_consumer/.ai/generated-agent-files.txt" \
  > "$scoped_consumer/.ai/generated-agent-files.txt.next"
mv "$scoped_consumer/.ai/generated-agent-files.txt.next" \
  "$scoped_consumer/.ai/generated-agent-files.txt"

printf '%s\n' 'outside content' > "$TEST_ROOT/outside-prompt.md"
rm "$scoped_consumer/packages/core/AGENTS.md"
ln -s "$TEST_ROOT/outside-prompt.md" "$scoped_consumer/packages/core/AGENTS.md"
run_sync "$scoped_consumer"
if [ -L "$scoped_consumer/packages/core/AGENTS.md" ]; then
  echo "error: sync wrote through a symlinked prompt target" >&2
  exit 1
fi
grep -qx 'outside content' "$TEST_ROOT/outside-prompt.md"

printf '%s\n' '{
  "agents": {
    "title": "Test Guidelines",
    "modules": ["engineering"],
    "local": ".ai/local/agents.md",
    "scopes": [
      {
        "path": "packages/core",
        "local": ".ai/local/core-agents.md"
      }
    ]
  }
}' > "$scoped_consumer/.ai/manifest.json"
if bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" --check "$scoped_consumer" >/dev/null 2>&1; then
  echo "error: check accepted a stale scoped prompt registry" >&2
  exit 1
fi
printf '%s\n' '# Hand-written instructions' > "$scoped_consumer/packages/react/AGENTS.md"
expect_failure "$scoped_consumer" "refusing to remove an unmarked prompt file"
printf '%s\n' '<!-- Generated by .ai/shared/scripts/sync-ai-skills.sh from .ai/manifest.json. -->' > "$scoped_consumer/packages/react/AGENTS.md"
run_sync "$scoped_consumer"
if [ -e "$scoped_consumer/packages/react/AGENTS.md" ]; then
  echo "error: sync did not remove a stale registered scoped prompt" >&2
  exit 1
fi
if [ -e "$scoped_consumer/packages/react/GEMINI.md" ]; then
  echo "error: sync did not remove a stale scoped Gemini shim" >&2
  exit 1
fi
bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" --check "$scoped_consumer"

invalid_scopes_consumer="$(new_consumer invalid-scopes)"
printf '%s\n' '{"agents":{"scopes":{}}}' > "$invalid_scopes_consumer/.ai/manifest.json"
expect_failure "$invalid_scopes_consumer" "manifest.agents.scopes must be an array"

missing_scope_consumer="$(new_consumer missing-scope)"
printf '%s\n' '{"agents":{"scopes":[{"path":"packages/missing"}]}}' > "$missing_scope_consumer/.ai/manifest.json"
expect_failure "$missing_scope_consumer" "references a missing directory"

duplicate_scope_consumer="$(new_consumer duplicate-scope)"
mkdir -p "$duplicate_scope_consumer/packages/core"
printf '%s\n' '{"agents":{"scopes":[{"path":"packages/core"},{"path":"packages/core"}]}}' > "$duplicate_scope_consumer/.ai/manifest.json"
expect_failure "$duplicate_scope_consumer" "duplicates scope"

scope_traversal_consumer="$(new_consumer scope-traversal)"
printf '%s\n' '{"agents":{"scopes":[{"path":"../outside"}]}}' > "$scope_traversal_consumer/.ai/manifest.json"
expect_failure "$scope_traversal_consumer" 'must be a repo-relative path without ".."'

missing_module_consumer="$(new_consumer missing-module)"
printf '%s\n' '{"agents":{"modules":["missing"]}}' > "$missing_module_consumer/.ai/manifest.json"
expect_failure "$missing_module_consumer" "references a missing module"

missing_local_consumer="$(new_consumer missing-local)"
printf '%s\n' '{"agents":{"local":".ai/local/missing.md"}}' > "$missing_local_consumer/.ai/manifest.json"
expect_failure "$missing_local_consumer" "references a missing local fragment"

echo "sync-ai validation tests passed."
