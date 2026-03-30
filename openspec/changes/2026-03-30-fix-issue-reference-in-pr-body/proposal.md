## Why

When the pre-merge standard task updates the PR body (`gh pr edit --body "..."`), any `Closes #X` references from the initial PR creation are lost. With squash merges, GitHub only processes issue-closing keywords from the PR body — not from individual commit messages. This means linked issues stay open after merge.

## What Changes

- The constitution's pre-merge standard task wording will be updated to explicitly require including `Closes #X` references (if applicable) when updating the PR body

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `constitution-management`: The Standard Tasks requirement needs to specify that PR body updates SHALL preserve or include GitHub issue-closing keywords.

### Consolidation Check

1. Existing specs reviewed: `constitution-management` (owns standard tasks), `release-workflow` (versioning, unrelated), `task-implementation` (task execution, not PR body content)
2. Overlap assessment: No new capability. The fix is a refinement of the existing standard tasks convention within `constitution-management`.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- **Affected file:** `openspec/CONSTITUTION.md` — pre-merge standard task wording
- **Affected spec:** `openspec/specs/constitution-management/spec.md`

## Scope & Boundaries

**In scope:**
- Constitution pre-merge standard task wording

**Out of scope:**
- `post_artifact` hook (PR body gets overwritten anyway)
- Skill changes (convention-based, not skill logic)
- GitHub merge strategy settings
