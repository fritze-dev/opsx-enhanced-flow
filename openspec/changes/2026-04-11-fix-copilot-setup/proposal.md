---
status: completed
branch: claude/setup-copilot-integration-2t2Ho
worktree: .claude/worktrees/fix-copilot-setup
capabilities:
  new: []
  modified: []
  removed: []
---
## Why

PR #116 (Copilot setup) doesn't work — Copilot can't discover or invoke the skill. Instead of client-specific workarounds, we adopt two open standards: **Agent Skills** (agentskills.io) for cross-client skill discovery and **AGENTS.md** (agents.md) for cross-client project instructions. This also fixes the constitution violation where SKILL.md uses Claude Code-specific tool names.

## What Changes

- Rewrite `src/skills/workflow/SKILL.md` to be **tool-agnostic** (Agent Skills Standard)
- Create `.agents/skills/workflow/SKILL.md` as symlink → `src/skills/workflow/SKILL.md` (cross-client discovery)
- Create `AGENTS.md` with agnostic project instructions
- Replace `CLAUDE.md` with symlink → `AGENTS.md`
- Update `src/templates/claude.md` to generate agnostic AGENTS.md-style content
- Update `.github/copilot-setup-steps.yml` with issues/PR permissions
- Delete `.github/copilot-instructions.md` (AGENTS.md replaces it)
- Delete `.github/skills/workflow/` (`.agents/skills/` replaces it)
- Update `openspec/CONSTITUTION.md` conventions

## Capabilities

### New Capabilities
None.

### Modified Capabilities
None — no spec-level behavior changes.

### Removed Capabilities
None.

### Consolidation Check
N/A — no new specs proposed.

## Impact

- **Skill content**: SKILL.md rewritten tool-agnostic. Same pipeline logic, different language.
- **Consumer template**: `src/templates/claude.md` updated for agnostic output.
- **Project instructions**: AGENTS.md replaces CLAUDE.md as source of truth.
- **Copilot**: Gets cross-client skill + instructions automatically.
- **Existing CI workflows**: Unaffected (stay in `.github/workflows/`).

## Scope & Boundaries

**In scope:** Agent Skills Standard adoption, AGENTS.md adoption, SKILL.md rewrite, template update, cleanup

**Out of scope:** Modifying WORKFLOW.md or Smart Templates, adding agent profiles, supporting other distribution mechanisms
