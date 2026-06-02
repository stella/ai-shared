<p align="center">
  <img src=".github/assets/banner.png" alt="Stella AI shared" width="100%" />
</p>

# ai-shared

Shared AI skills and sync tooling for Stella
repositories.

## Layout

```text
modules/
  <module-name>.md      # reusable AGENTS.md fragments
skills/
  <skill-name>/
    SKILL.md            # shared Codex skill source of truth
scripts/sync-ai-skills.sh
scripts/link-codex-skills.sh
```

Recommended shared planning conventions for consumer repos:

```text
.agents/ARCHITECTURE.md
.agents/GOALS.md
.agents/STATUS.md
.agents/plans/
```

Consumer repositories are expected to use:

```text
.ai/shared/              # submodule pointing here
.ai/manifest.json        # selected modules and local AGENTS fragment
.ai/local/agents.md      # repo-specific AGENTS.md fragment
.ai/local-skills/        # repo-local Codex-style skills
AGENTS.md                # generated and committed
CLAUDE.md                # generated shim importing AGENTS.md
GEMINI.md                # generated shim importing AGENTS.md
.claude/commands/        # generated flat command files
.agents/skills/          # generated Codex-style skills
```

## Sync behavior

The sync script assembles `AGENTS.md` from:

1. `.ai/shared/modules/<name>.md`, in `.ai/manifest.json` order
2. `.ai/local/agents.md`

It also generates `CLAUDE.md` and `GEMINI.md` adapters so the committed root
instructions are immediately usable by multiple coding agents.
When `.ai/manifest.json` contains an `agents` object, these root prompt files are
generated even if the module list is empty and the local fragment is absent, so
`--check` still catches stale committed instructions.

The same script overlays skills from:

1. `.ai/shared/skills/`
2. `.ai/local-skills/`

onto both generated targets:

- `.claude/commands/<skill>.md`
- `.agents/skills/<skill>/SKILL.md`

If the same skill name exists in both sources, the
local skill wins.

The generated directories keep only a `.gitignore`
placeholder when no skills are present. `.gitkeep`
files from source directories are ignored and are
not copied into generated outputs.

Use `--check` in CI to fail when committed generated files are stale:

```bash
bash .ai/shared/scripts/sync-ai-skills.sh --check .
```

## Usage from a consumer repo

```bash
bash .ai/shared/scripts/sync-ai-skills.sh .
```

Or add a thin wrapper script in the consumer repo:

```bash
#!/usr/bin/env bash
set -euo pipefail
bash .ai/shared/scripts/sync-ai-skills.sh "$@" .
```

To link generated agent skills into Codex's global skill directory:

```bash
bash .ai/shared/scripts/link-codex-skills.sh .
```

By default this installs namespaced links like `stella-open-pr`
into `${CODEX_HOME:-$HOME/.codex}/skills` to avoid cross-repo
collisions. Set `CODEX_SKILL_PREFIX=""` if you explicitly want
unprefixed global names.

## Current Shared Commands

- `rabbit-round` — handle bot PR reviews systematically
- `open-pr` — open a clean, verified pull request from the current branch
- `plan` — create implementation plans using the shared `.agents/plans/` convention
- `regression-hunt` — reproduce, isolate, fix, and lock down a regression
- `security-audit` — generic security review with repo-specific overlays
- `product-think` — shape a feature/problem before implementation
