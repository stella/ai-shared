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
run_sync "$valid_consumer"
cmp "$SOURCE_ROOT/rustfmt.toml" "$valid_consumer/rustfmt.toml"
bash "$SOURCE_ROOT/scripts/sync-ai-skills.sh" --check "$valid_consumer"

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

echo "sync-ai sharedRootFiles tests passed."
