# ADR-054: Stale Worktree Detection Enhancements

## Status

Accepted (2026-04-11)

## Context

The lazy worktree cleanup in `/opsx:workflow propose` used a 3-tier detection hierarchy to identify stale worktrees. Issue #111 revealed three gaps: (1) the proposal lookup used a branch-name glob (`openspec/changes/*-<branch>/`) that fails because worktree branches use a `worktree-` prefix while change directories don't, (2) closed PRs (abandoned work) were not detected, and (3) inactive branches with no PR were invisible to cleanup.

## Decision

1. **Read proposals from the worktree filesystem path** (`<worktree-path>/openspec/changes/*/proposal.md`) instead of glob-matching by branch name. This is naming-convention-agnostic and correctly handles the `worktree-` prefix mismatch.

2. **Prompt users for abandoned and inactive worktrees** (tiers 3-4) rather than auto-cleaning. Closed PRs and stale branches may contain salvageable work. Auto-clean remains for confirmed-completed changes (tiers 1-2).

3. **Use a configurable `stale_days` threshold** (default: 14) rather than a fixed value, allowing projects with different cadences to tune the inactivity window.

4. **Do not add an `abandoned` proposal status**. External signals (PR state, commit inactivity) are sufficient for detection without requiring changes to the proposal template or status lifecycle.

## Alternatives Considered

- **Strip `worktree-` prefix before matching**: Fragile — assumes a specific naming convention that may change.
- **Auto-clean abandoned worktrees**: Risky — could delete work-in-progress that was merely paused.
- **Add `abandoned` status to proposal lifecycle**: Higher implementation cost, requires a mechanism to set the status, and changes to template and parsing logic across multiple files.
- **Fixed inactivity threshold (no configuration)**: Inflexible for teams with different development cadences.

## Consequences

### Positive

- Stale worktrees from completed-but-unmerged changes are now detected correctly
- Abandoned PRs (CLOSED state) surface to the user for cleanup decision
- Long-inactive branches are flagged before they accumulate indefinitely
- Existing cleanup behavior for completed/merged changes is unchanged

### Negative

- Detection hierarchy complexity increased from 3 to 5 tiers
- Users may receive additional prompts during propose when stale worktrees exist (mitigated by only prompting when actual staleness signals are present)

## References

- [Issue #111](https://github.com/fritze-dev/opsx-enhanced-flow/issues/111)
- [Change: fix-stale-worktree-detection](../../openspec/changes/2026-04-11-fix-stale-worktree-detection/)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [ADR-035: PR Merge Check for Branch Deletion](adr-035-pr-merge-check-for-branch-deletion.md)
