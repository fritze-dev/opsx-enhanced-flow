<!--
---
status: active
branch: claude/analyze-issue-111-AmS90
capabilities:
  new: []
  modified: [change-workspace]
  removed: []
---
-->
## Why

Lazy worktree cleanup during `/opsx:workflow propose` fails to detect stale worktrees when their proposals are completed but unmerged. The root cause is a branch-naming mismatch in the proposal lookup path, combined with missing detection for abandoned PRs (CLOSED state) and inactive branches. This leaves stale worktrees accumulating on disk and blocking new workspace creation.

## What Changes

- **Fix proposal lookup path**: Read proposals from the worktree filesystem path (`<worktree-path>/openspec/changes/*/proposal.md`) instead of glob-matching by branch name, which fails due to the `worktree-` prefix mismatch
- **Add CLOSED PR detection**: Treat PRs with state `CLOSED` (closed without merge) as abandoned — prompt user for confirmation before cleanup
- **Add inactivity detection**: Check last commit date on the branch; if older than configurable `stale_days` threshold (default: 14), prompt user for confirmation
- **Add `stale_days` config**: New optional field in WORKFLOW.md `worktree` section for configuring the inactivity threshold
- **Distinguish auto-clean vs prompted cleanup**: Completed/merged changes are auto-cleaned (tiers 1-2); abandoned/inactive changes require user confirmation (tiers 3-4), regardless of `auto_approve` setting

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: The "Lazy Worktree Cleanup at Change Creation" requirement needs an expanded detection hierarchy (3 tiers → 5 tiers), fixed proposal lookup path, and new scenarios for abandoned/inactive worktrees

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. The change modifies the existing `change-workspace` spec which already owns the lazy worktree cleanup requirement.

## Impact

- **Specs**: `openspec/specs/change-workspace/spec.md` — requirement text and scenarios updated
- **WORKFLOW.md**: New `stale_days` config field + updated propose instruction
- **Consumer template**: `src/templates/workflow.md` — mirrored changes per template sync convention
- **Capability docs**: `docs/capabilities/change-workspace.md` — description updated

## Scope & Boundaries

**In scope:**
- Fix the proposal lookup path (root cause of issue #111)
- Add CLOSED PR and inactivity detection tiers with user prompts
- Add `stale_days` configuration
- Update all synced files (WORKFLOW.md, template, capability docs)

**Out of scope:**
- Adding an `abandoned` proposal status (external signals are sufficient)
- Stale main when creating worktrees (already fixed by spec line 100 and `worktree-fetch-main` change)
- Changes to the proposal template or status lifecycle
