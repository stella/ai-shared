# ai-shared

Shared AI skills and sync tooling for Stella
repositories.

## Layout

```text
skills/                  # shared flat source of truth
scripts/sync-ai-skills.sh
```

Consumer repositories are expected to use:

```text
.ai/shared/              # submodule pointing here
.ai/local-skills/        # repo-local flat skills
.claude/commands/        # generated flat output
.agents/skills/          # generated flat output
```

## Sync behavior

The sync script overlays:

1. `.ai/shared/skills/`
2. `.ai/local-skills/`

onto both generated targets:

- `.claude/commands/`
- `.agents/skills/`

If the same filename exists in both sources, the
local skill wins.

The generated directories keep only a `.gitignore`
placeholder when no skills are present. `.gitkeep`
files from source directories are ignored and are
not copied into generated outputs.

## Usage from a consumer repo

```bash
bash .ai/shared/scripts/sync-ai-skills.sh .
```

Or add a thin wrapper script in the consumer repo:

```bash
#!/usr/bin/env bash
set -euo pipefail
bash .ai/shared/scripts/sync-ai-skills.sh .
```
