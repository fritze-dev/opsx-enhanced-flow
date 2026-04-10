---
status: active
branch: init-health-check-fixes
worktree: .claude/worktrees/init-health-check-fixes
capabilities:
  new: []
  modified: [three-layer-architecture, project-init]
  removed: []
---
## Why

The `/opsx:workflow init` health check detected three drift issues: the three-layer-architecture spec still references a "6-stage pipeline" (should be 7-stage since review was added), two local template customizations haven't been upstreamed to `src/templates/` for consumer propagation, and the local WORKFLOW.md is missing custom action hint comments present in the plugin template.

## What Changes

- Fix three-layer-architecture spec: update "6-stage" → "7-stage" and add "review" to the pipeline list in the Schema Layer requirement and scenario
- Upstream `tasks.md` template customizations (Pre-Merge/Post-Merge subsection handling, Section 5 for post-merge reminders) from `openspec/templates/tasks.md` to `src/templates/tasks.md` with template-version bump to v2
- Upstream `specs/spec.md` template customization (implementation-detail prohibition paragraph) from `openspec/templates/specs/spec.md` to `src/templates/specs/spec.md` with template-version bump to v2
- Add missing custom action hint comments to local `openspec/WORKFLOW.md` after `actions:` array

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `three-layer-architecture`: Fix Schema Layer requirement and scenario to reference 7-stage pipeline instead of 6-stage
- `project-init`: Update Template Merge on Re-Init requirement to note that template-version bumps trigger consumer updates (no spec text change needed — existing spec already covers this behavior, but the version bump in implementation makes the scenario "Unchanged template updated silently" directly exercisable)

### Removed Capabilities

None.

### Consolidation Check

1. Existing specs reviewed: three-layer-architecture, project-init, artifact-pipeline, quality-gates, change-workspace, constitution-management, documentation, release-workflow, task-implementation, human-approval-gate, spec-format, roadmap-tracking, workflow-contract
2. Overlap assessment: three-layer-architecture owns the "6-stage" text that needs fixing. project-init owns template merge behavior. No new specs needed.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `openspec/specs/three-layer-architecture/spec.md` — text correction
- `src/templates/tasks.md` — content upstream + version bump
- `src/templates/specs/spec.md` — content upstream + version bump
- `openspec/WORKFLOW.md` — add 2 comment lines
- Consumer projects will receive template updates on next `/opsx:workflow init` (silent update for uncustomized templates)

## Scope & Boundaries

**In scope:** The three specific drift fixes identified by the init health check.

**Out of scope:** Any behavioral changes to skills, workflow actions, or pipeline mechanics. This is purely spec text correction, template synchronization, and comment restoration.
