#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-.}"
REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_SKILLS_DIR="$CODEX_HOME/skills"
SYNC_SCRIPT="$REPO_ROOT/.ai/shared/scripts/sync-ai-skills.sh"
AGENTS_DIR="$REPO_ROOT/.agents/skills"
REPO_NAME="$(basename "$REPO_ROOT" | tr '[:upper:]' '[:lower:]')"

if [[ "${CODEX_SKILL_PREFIX+x}" == "x" ]]; then
  SKILL_PREFIX="$CODEX_SKILL_PREFIX"
else
  SKILL_PREFIX="$REPO_NAME-"
fi

if [[ ! -f "$SYNC_SCRIPT" ]]; then
  echo "error: $SYNC_SCRIPT not found." >&2
  echo "Run: git submodule update --init" >&2
  exit 1
fi

bash "$SYNC_SCRIPT" "$REPO_ROOT"

mkdir -p "$CODEX_SKILLS_DIR"

while read -r link_path; do
  target_path="$(readlink "$link_path")"
  case "$target_path" in
    "$AGENTS_DIR"/*)
      rm "$link_path"
      ;;
  esac
done < <(find "$CODEX_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type l)

linked_skills=0

while read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"
  link_name="$SKILL_PREFIX$skill_name"
  link_path="$CODEX_SKILLS_DIR/$link_name"

  if [[ -e "$link_path" ]] && [[ ! -L "$link_path" ]]; then
    echo "error: $link_path already exists and is not a symlink." >&2
    echo "Set CODEX_SKILL_PREFIX to avoid collisions." >&2
    exit 1
  fi

  rm -rf "$link_path"
  ln -s "$skill_dir" "$link_path"
  echo "Linked $link_name -> $skill_dir"
  linked_skills=1
done < <(find "$AGENTS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ "$linked_skills" -eq 0 ]]; then
  echo "No agent skills found in $AGENTS_DIR"
fi
