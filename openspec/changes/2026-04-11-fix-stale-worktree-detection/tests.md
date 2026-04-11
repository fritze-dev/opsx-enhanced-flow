# Tests: Fix Stale Worktree Detection

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### change-workspace

#### Lazy Worktree Cleanup at Change Creation

- [ ] **Scenario: Cleanup worktree with completed proposal status**
  - Setup: A worktree at `.claude/worktrees/feature-x` on branch `worktree-feature-x` with `status: completed` in `<worktree-path>/openspec/changes/2026-04-10-feature-x/proposal.md`
  - Action: Invoke `/opsx:workflow propose new-change`
  - Verify: System reads proposal from worktree filesystem path, removes the worktree and deletes the branch, reports "Cleaned up stale worktree: feature-x (completed)"

- [ ] **Scenario: Cleanup worktree via PR status fallback**
  - Setup: A worktree on branch `fix-auth` with no proposal `status` field, PR for `fix-auth` has state "MERGED"
  - Action: Invoke `/opsx:workflow propose add-logging`
  - Verify: System removes the worktree and deletes the branch

- [ ] **Scenario: Abandoned worktree detected via closed PR**
  - Setup: A worktree on branch `worktree-abandoned-feature` with `status: active`, PR has state `CLOSED`
  - Action: Invoke `/opsx:workflow propose new-change`
  - Verify: System prompts "Worktree 'abandoned-feature' has a closed PR (not merged). Clean up? [y/N]". On confirm: removes worktree and deletes branch. On decline: preserves worktree.

- [ ] **Scenario: Inactive worktree detected via commit age**
  - Setup: A worktree on branch `worktree-old-experiment` with `status: active`, no PR, last commit 21 days old, `stale_days` is 14
  - Action: Invoke `/opsx:workflow propose new-change`
  - Verify: System prompts "Worktree 'old-experiment' has had no commits for 21 days. Clean up? [y/N]". On confirm: removes worktree and deletes branch. On decline: preserves worktree.

- [ ] **Scenario: Recent worktree within inactivity threshold preserved**
  - Setup: A worktree on branch `worktree-recent-work` with `status: active`, no PR, last commit 5 days old, `stale_days` is 14
  - Action: Invoke `/opsx:workflow propose new-change`
  - Verify: System does NOT prompt for cleanup of `recent-work`

- [ ] **Scenario: No stale worktrees**
  - Setup: No worktrees exist besides the main working tree
  - Action: Invoke `/opsx:workflow propose add-logging`
  - Verify: System proceeds directly to change creation without cleanup messages

- [ ] **Scenario: Worktree with active change preserved**
  - Setup: A worktree at `.claude/worktrees/wip-feature` on branch `wip-feature` with `status: active`, last commit within `stale_days` threshold
  - Action: Invoke `/opsx:workflow propose add-logging`
  - Verify: System does NOT remove the `wip-feature` worktree

- [ ] **Scenario: Cleanup without gh CLI and no proposal status**
  - Setup: A worktree on branch `fix-auth`, no `status` field, `gh` unavailable, last commit within `stale_days` threshold
  - Action: System attempts cleanup
  - Verify: Falls back to `git branch -d fix-auth`. If merged: deleted. If not merged: preserved.

#### Edge Cases

- [ ] **Edge: Dirty worktree during cleanup**
  - Setup: Abandoned worktree with uncommitted changes, user confirms cleanup
  - Verify: `git worktree remove` fails, system reports error and skips worktree

- [ ] **Edge: `gh` CLI unavailable during cleanup**
  - Verify: Falls back to inactivity check (tier 4), then `git branch -d` (tier 5)

- [ ] **Edge: PR state CLOSED during cleanup**
  - Verify: System prompts user rather than auto-cleaning

- [ ] **Edge: `worktree.stale_days` absent**
  - Verify: System defaults to 14 days

- [ ] **Edge: Branch with no commits**
  - Setup: Worktree with a branch that has no commits (`git log -1` fails)
  - Verify: System treats worktree as active, does not flag for cleanup

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 8 |
| Automated tests | 0 |
| Manual test items | 13 |
| Preserved (@manual) | 0 |
| Edge case tests | 5 |
| Warnings | 0 |
