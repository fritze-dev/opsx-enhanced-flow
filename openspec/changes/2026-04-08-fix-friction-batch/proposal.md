## Why

Four friction issues (#81, #86, #87, #88) reveal gaps in agent guidance that cause unnecessary pauses, missed auto-fixes, forgotten template syncs, and stale worktrees. Each issue has been observed in real workflow sessions and has a clear, low-risk fix.

## What Changes

- **#81:** Add explicit automated-step guidance to `apply.instruction` — QA steps 3.1 (Metric Check) and 3.2 (Auto-Verify) run without pausing; the human gate is step 3.3 (User Testing).
- **#86:** Add auto-fix guidance to verify skill — mechanically fixable WARNINGs (stale cross-references, inconsistent text between artifacts) are resolved inline and noted in the report, instead of being presented as open issues.
- **#87:** Add a "Template synchronization" convention to the constitution — changes to `openspec/WORKFLOW.md` behavior fields must also be reflected in `src/templates/workflow.md`.
- **#88:** Add post-merge worktree cleanup guidance to `apply.instruction` — after successful `gh pr merge` from within a worktree, the agent switches to the main worktree, removes the completed worktree, and deletes the branch.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `quality-gates`: Add auto-fix behavior for mechanically fixable WARNINGs in the Post-Implementation Verification requirement (#86).
- `task-implementation`: Add guidance that QA Loop steps 3.1 and 3.2 are automated (no pause before the human gate at 3.3) (#81).
- `change-workspace`: Add post-merge worktree cleanup requirement — immediate cleanup when merge happens locally in the same session (#88).

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed.

Existing specs reviewed for overlap:
- `quality-gates` — owns verify behavior, correct location for #86 auto-fix guidance
- `task-implementation` — owns apply behavior and QA loop task processing, correct location for #81
- `human-approval-gate` — owns QA loop structure and approval flow; #81 touches the boundary between task-implementation (what apply does with QA steps) and human-approval-gate (the approval sequence). The fix belongs in task-implementation because the issue is about apply's execution behavior, not the approval structure.
- `change-workspace` — owns worktree lifecycle, correct location for #88 cleanup addition

## Impact

- **WORKFLOW.md** (`openspec/WORKFLOW.md` + `src/templates/workflow.md`): `apply.instruction` updated with automated-step and post-merge cleanup guidance
- **Verify SKILL.md** (`src/skills/verify/SKILL.md`): Auto-fix guidance added for mechanically fixable WARNINGs
- **CONSTITUTION.md** (`openspec/CONSTITUTION.md` + `src/templates/constitution.md`): New "Template synchronization" convention
- **Specs**: `quality-gates`, `task-implementation`, `change-workspace` — requirement-level updates

No breaking changes. No API changes. No external dependencies.

## Scope & Boundaries

**In scope:**
- Instruction text updates in WORKFLOW.md `apply.instruction`
- Verify skill guidance update
- Constitution convention addition
- Spec requirement updates for the three affected capabilities

**Out of scope:**
- Hard enforcement mechanisms (hooks, validation scripts)
- Changes to the tasks template structure (the QA loop steps stay as-is)
- Changes to the `/opsx:new` skill (lazy cleanup already works — #88 is about post-merge, not pre-creation)
- Preflight template changes
