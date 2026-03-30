## Why

After `/opsx:archive` with a squash-merged PR, `git branch -d` fails with "not fully merged" because Git cannot detect squash merges as merged. This leaves stale branches behind and produces confusing error output during an otherwise clean archive flow.

## What Changes

- The archive skill's worktree cleanup step (Step 6.4) will check PR merge status via `gh pr view` before deleting the branch
- If the PR is confirmed merged, use `git branch -D` (safe force delete) instead of `git branch -d`
- Fall back to `git branch -d` if `gh` is unavailable or no PR exists
- The corresponding spec scenario will be updated to reflect the new behavior

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: The "Worktree Cleanup After Archive" requirement's auto-cleanup scenario needs to specify that branch deletion SHALL check PR merge status and use force delete when the PR is confirmed merged, with fallback to safe delete.

### Consolidation Check

1. Existing specs reviewed: `change-workspace` (owns worktree cleanup behavior), `release-workflow` (unrelated — covers versioning/releases)
2. Overlap assessment: No new capability needed. The fix is entirely within the existing `change-workspace` spec's "Worktree Cleanup After Archive" requirement.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- **Affected code:** `src/skills/archive/SKILL.md` Step 6.4
- **Affected spec:** `openspec/specs/change-workspace/spec.md` — "Worktree Cleanup After Archive" requirement
- **Dependencies:** `gh` CLI (already used by `post_artifact` for PR creation)

## Scope & Boundaries

**In scope:**
- Archive skill Step 6.4 branch deletion logic
- change-workspace spec scenario for auto-cleanup

**Out of scope:**
- Other archive skill steps
- Worktree creation logic
- PR creation or merge strategy configuration
