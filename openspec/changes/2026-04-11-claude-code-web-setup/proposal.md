<!--
---
status: completed
branch: worktree-claude-code-web-setup
worktree: .claude/worktrees/claude-code-web-setup
capabilities:
  new: []
  modified: [project-init]
  removed: []
---
-->
## Why

The plugin works in Codespaces via devcontainer but has no support for Claude Code Web (claude.ai/code). Claude Code Web uses its own universal image where devcontainer features don't apply. Users opening this repo in Claude Code Web get no plugin, no `gh` CLI, and a broken workflow. Closes #14.

## What Changes

- Add `.claude/settings.json` with plugin marketplace declaration (`extraKnownMarketplaces` + `enabledPlugins`) so the plugin auto-installs in cloud sessions, plus a SessionStart hook that installs the `gh` CLI
- Add `.gitignore` negation rule (`!/.claude/settings.json`) so the settings file is committed despite the `/.claude/` ignore rule
- Add `scripts/setup-remote.sh` — gated on `CLAUDE_CODE_REMOTE=true`, installs `gh` CLI via apt, configures auth if `GH_TOKEN` is available
- Update README with Claude Code Web setup documentation

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `project-init`: Add requirement for `.claude/settings.json` generation during init (so consumer projects also get the Claude Code Web setup pattern)

### Removed Capabilities

_(none)_

### Consolidation Check

1. Existing specs reviewed: project-init, change-workspace, artifact-pipeline, workflow-contract, three-layer-architecture
2. Overlap assessment: `project-init` already covers environment checks, template installation, and setup. Claude Code Web setup is a natural extension of init's responsibility (ensuring the project works across environments). No new spec needed.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- **Files created**: `.claude/settings.json`, `scripts/setup-remote.sh`
- **Files modified**: `.gitignore`, `README.md`, `openspec/specs/project-init/spec.md`
- **No breaking changes** — existing local/Codespaces workflows unaffected
- **User action required**: Claude Code Web users must configure `GH_TOKEN` as environment variable in their environment settings for full `gh` CLI support

## Scope & Boundaries

**In scope:**
- `.claude/settings.json` with plugin declaration + SessionStart hook
- `scripts/setup-remote.sh` for `gh` CLI installation
- `.gitignore` fix for settings.json
- README documentation for Claude Code Web
- Spec update for project-init (settings.json generation during init)

**Out of scope:**
- Changes to the plugin's runtime behavior (SKILL.md unchanged)
- Built-in GitHub tools integration (no replacement for `gh pr create`)
- Environment Setup Script in the cloud UI (user's responsibility)
- Changes to devcontainer setup (continues to work as-is)
