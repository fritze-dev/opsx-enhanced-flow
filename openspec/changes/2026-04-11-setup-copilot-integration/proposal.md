---
status: active
branch: claude/setup-copilot-integration-2t2Ho
worktree: .claude/worktrees/setup-copilot-integration
capabilities:
  new: []
  modified: []
  removed: []
---
## Why

GitHub Copilot coding agent now supports Agent Skills using the same SKILL.md format with YAML frontmatter. Our skill format is already compatible, but the repo lacks the Copilot-specific configuration files (`.github/copilot-instructions.md`, `copilot-setup-steps.yml`, `.github/skills/`). Without these, Copilot cannot discover or use the plugin's workflow skill. This closes the gap so Copilot can work in this repo alongside Claude Code.

Tracked in Issue #15.

## What Changes

- Add `.github/copilot-instructions.md` — curated project instructions for Copilot (equivalent to `CLAUDE.md`), derived from CONSTITUTION.md
- Add `.github/copilot-setup-steps.yml` — minimal environment setup (no external dependencies needed)
- Add `.github/skills/workflow/SKILL.md` — symlink to `../../src/skills/workflow/SKILL.md` so Copilot discovers the existing skill
- Add convention to CONSTITUTION.md for keeping `copilot-instructions.md` in sync with `CLAUDE.md`

## Capabilities

### New Capabilities

None — this is an infrastructure/configuration change. No new plugin behavior is introduced.

### Modified Capabilities

None — the existing skill format is already Copilot-compatible. No spec-level behavior changes.

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed.

Existing specs reviewed: artifact-pipeline, change-workspace, constitution-management, documentation, human-approval-gate, project-init, quality-gates, release-workflow, roadmap-tracking, spec-format, task-implementation, test-generation, three-layer-architecture, workflow-contract.

None of these specs cover agent-specific configuration file management. The Copilot setup files (`.github/copilot-instructions.md`, `copilot-setup-steps.yml`) are static configuration — not plugin behavior governed by specs. The skill symlink is a file-level concern, not a behavioral requirement.

## Impact

- **`.github/` directory**: Three new files added (instructions, setup steps, skills symlink)
- **CONSTITUTION.md**: One new convention for copilot-instructions.md sync
- **Existing skills**: No changes — symlink references existing `src/skills/workflow/SKILL.md`
- **CI/CD**: No workflow changes — `copilot-setup-steps.yml` is read by Copilot, not by GitHub Actions

## Scope & Boundaries

**In scope:**
- `.github/copilot-instructions.md` (Copilot custom instructions)
- `.github/copilot-setup-steps.yml` (Copilot environment setup)
- `.github/skills/workflow/SKILL.md` (symlink to existing skill)
- CONSTITUTION.md convention for sync

**Out of scope:**
- Other AI agents (Cursor, Windsurf) — user explicitly scoped to Copilot only
- Skill format transformation or build steps — format is already compatible
- Agent profiles (`.agent.md`) — optional, can be added later
- Modifying the existing SKILL.md content or frontmatter
