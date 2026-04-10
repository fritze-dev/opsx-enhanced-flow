---
status: active
branch: transparent-knowledge-management
worktree: .claude/worktrees/transparent-knowledge-management
capabilities:
  new: []
  modified: [project-init]
  removed: []
---
## Why

Claude Code's auto-memory saves project knowledge to opaque, machine-local `~/.claude/projects/*/memory/` files. This project already has rich transparent knowledge mechanisms (constitution, specs, ADRs, issues), but nothing tells the agent to prefer them. Observed memories duplicate what exists in change artifacts and ADRs, proving the problem. Consumer projects initialized via `/opsx:workflow init` also lack this guidance since no CLAUDE.md bootstrap exists.

## What Changes

- Add `## Knowledge Management` section to `CLAUDE.md` with agent directive: do not use auto-memory for project knowledge, route to transparent artifacts instead
- Add `- **Knowledge transparency:** ...` convention entry to `openspec/CONSTITUTION.md`
- Create `src/templates/claude.md` — bootstrap template for CLAUDE.md generation during init
- Update init instruction in `openspec/WORKFLOW.md` to generate CLAUDE.md in Fresh mode
- Sync init instruction change to `src/templates/workflow.md` (template synchronization convention)

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `project-init`: Add CLAUDE.md generation to Fresh mode init — the init action will generate CLAUDE.md from a new bootstrap template alongside the constitution

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed.

Existing specs reviewed: `project-init`, `constitution-management`, `three-layer-architecture`, `workflow-contract`. The CLAUDE.md bootstrap fits naturally into `project-init` (Install OpenSpec Workflow requirement) since init already handles template installation and constitution generation. The knowledge transparency convention is a constitution content change covered by `constitution-management` (Constitution Update requirement). No new capability needed.

## Impact

- `CLAUDE.md` — gains knowledge management directive (loaded in every agent session)
- `openspec/CONSTITUTION.md` — gains knowledge transparency convention
- `src/templates/claude.md` — new bootstrap template (shipped with plugin)
- `openspec/WORKFLOW.md` + `src/templates/workflow.md` — init instruction updated
- Consumer projects running `/opsx:workflow init` will get CLAUDE.md generated automatically

## Scope & Boundaries

**In scope:**
- Approach C (CLAUDE.md directive + constitution convention) from issue #69
- Init bootstrap template for CLAUDE.md
- Init instruction update for CLAUDE.md generation

**Out of scope:**
- `/opsx:learn` skill (future work, Approach A from issue)
- Hook-based memory redirect (Approach B from issue)
- Cleanup of existing memory files (outside repo, manual post-merge step)
- Hard enforcement of auto-memory disabling (relies on convention-based compliance per ADR-004/ADR-006/ADR-015)
