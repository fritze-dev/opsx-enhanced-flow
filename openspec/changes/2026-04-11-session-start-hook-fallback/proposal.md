<!--
---
status: active
branch: worktree-session-start-hook-fallback
worktree: .claude/worktrees/session-start-hook-fallback
capabilities:
  new: []
  modified: []
  removed: []
---
-->
## Why

The declarative plugin auto-install (`enabledPlugins` in `.claude/settings.json`) fails in Claude Code Web sessions due to a race condition between marketplace async-fetch and plugin resolution (anthropics/claude-code#10997). Users must manually run `claude plugin install` every time, defeating the purpose of the declarative setup. A SessionStart hook provides a fallback until the upstream bug is fixed.

## What Changes

- Add a `hooks.SessionStart` entry to `.claude/settings.json` that runs `claude plugin install opsx@opsx-enhanced-flow` on new session startup
- The hook uses `2>/dev/null || true` to fail silently when the plugin is already installed or the marketplace is not yet available
- Existing declarative fields (`extraKnownMarketplaces`, `enabledPlugins`) remain unchanged

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This is a configuration-only change to `.claude/settings.json` — no spec-level behavior is affected.

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. This change modifies only `.claude/settings.json` (a project configuration file, not a spec or skill).

Existing specs reviewed: project-init (covers init behavior, not runtime session hooks).

## Impact

- **`.claude/settings.json`**: Adds `hooks` key with one SessionStart entry
- **Session startup**: One additional command runs on new sessions (~100ms overhead)
- **ADR-050**: The hook is a fallback supplement, not a contradiction — declarative fields remain the primary mechanism

## Scope & Boundaries

**In scope:**
- Adding the SessionStart hook to `.claude/settings.json`

**Out of scope:**
- Modifying the declarative `enabledPlugins` approach
- Fixing the upstream race condition in Claude Code itself
- Changes to `devcontainer.json` (already works for Codespaces)
- Spec or skill modifications
