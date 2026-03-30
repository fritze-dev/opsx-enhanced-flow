## Why

Parallel changes and structural modifications on main cause merge conflicts in feature branches (see #59). Version bumps, ADR numbers, and file path changes all conflict when multiple changes are in-flight. Git worktrees isolate each change in its own working directory with a dedicated branch, eliminating cross-change interference. Additionally, extracting WORKFLOW.md into a template file aligns it with the existing constitution template pattern.

## What Changes

- `/opsx:new` creates a git worktree with a feature branch when `worktree.enabled` is true in WORKFLOW.md
- All 7 change-detecting skills (`ff`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`) auto-detect the active change from worktree context (branch name → change name)
- `/opsx:archive` offers worktree cleanup after archiving
- WORKFLOW.md gains a `worktree:` configuration section (`enabled`, `path_pattern`, `auto_cleanup`)
- WORKFLOW.md content is extracted from the setup skill into `src/templates/workflow.md` (template file, consistent with constitution pattern)
- `/opsx:setup` gains environment checks (gh CLI detection) and asks users whether to enable worktree mode
- `/opsx:setup` configures GitHub merge strategy for rebase-merge when gh CLI is available and user opts in
- `post_artifact` hook becomes worktree-aware (skips branch creation when already on feature branch)

## Capabilities

### New Capabilities

None — all changes fit within existing capability boundaries.

### Modified Capabilities

- `change-workspace`: Add worktree-based workspace creation in `/opsx:new`, worktree context detection across all change-detecting skills, worktree cleanup in `/opsx:archive`
- `artifact-pipeline`: Add `worktree` field to WORKFLOW.md contract, make `post_artifact` worktree-aware
- `project-setup`: Extract WORKFLOW.md into template file, add environment checks (gh CLI), worktree opt-in, merge strategy configuration

### Consolidation Check

1. Existing specs reviewed: `change-workspace`, `artifact-pipeline`, `project-setup`, `workflow-contract`, `three-layer-architecture`, `quality-gates`, `spec-sync`, `task-implementation`, `human-approval-gate`, `interactive-discovery`
2. Overlap assessment: No new capabilities proposed. All changes are extensions of existing specs — worktree creation extends `change-workspace`, WORKFLOW.md config extends `artifact-pipeline`, setup changes extend `project-setup`.
3. Merge assessment: N/A — no new specs proposed.

## Impact

- **Skills modified**: 9 skill files (`new`, `ff`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`, `setup`)
- **Templates**: New `src/templates/workflow.md` file
- **Configuration**: WORKFLOW.md gains `worktree:` section
- **Git**: Worktrees created under `.claude/worktrees/{change}` (already gitignored)
- **GitHub**: Rebase-merge strategy configured via `gh api` during setup

## Scope & Boundaries

**In scope:**
- Worktree creation, detection, and cleanup
- WORKFLOW.md template extraction
- Setup skill environment checks and worktree opt-in
- Post-artifact hook worktree awareness
- GitHub merge strategy configuration in setup

**Out of scope:**
- Automatic conflict resolution
- CI/CD pipeline changes for worktree-based workflows
- Dedicated `/opsx:worktrees` management skill (git CLI suffices)
- Changes to non-change-detecting skills (docs, docs-verify, changelog, bootstrap)
