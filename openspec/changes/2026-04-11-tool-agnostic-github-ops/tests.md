# Tests: Tool-Agnostic GitHub Operations

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### artifact-pipeline

#### Post-Artifact Commit and PR Integration

- [ ] **Scenario: First artifact triggers branch and PR creation**
  - Setup: A change workspace where no feature branch exists yet, GitHub tooling is available (gh CLI, MCP tools, or API)
  - Action: Agent finishes creating the first artifact
  - Verify: Agent creates a feature branch, commits, pushes, and creates a draft PR

- [ ] **Scenario: Graceful degradation without GitHub tooling**
  - Setup: No GitHub tooling is available (no gh CLI, no MCP tools, no API access)
  - Action: Agent finishes creating the first artifact
  - Verify: Agent creates the branch, commits, attempts push, and skips PR creation

### change-workspace

#### Lazy Worktree Cleanup at Change Creation

- [ ] **Scenario: Cleanup worktree via PR status fallback**
  - Setup: A worktree on branch `fix-auth` with no proposal `status` field, and the PR for `fix-auth` has state "MERGED"
  - Action: User invokes `/opsx:workflow propose add-logging`
  - Verify: System removes the worktree and deletes the branch

- [ ] **Scenario: Cleanup without GitHub tooling and no proposal status**
  - Setup: A worktree exists on branch `fix-auth`, proposal has no `status` field and no GitHub tooling is available, last commit is within the `stale_days` threshold
  - Action: System attempts cleanup
  - Verify: System falls back to `git branch -d fix-auth`; if merged, branch is deleted and worktree removed; if not merged, `git branch -d` fails and worktree is preserved

#### Post-Merge Worktree Cleanup

- [ ] **Scenario: Cleanup after successful local merge**
  - Setup: Agent is working inside a worktree at `.claude/worktrees/fix-auth` on branch `fix-auth`
  - Action: Agent merges the PR which succeeds
  - Verify: System switches to main worktree, removes worktree, deletes local and remote branch, reports "Cleaned up worktree: fix-auth (merged)"

### Verification: grep audit

- [ ] **Scenario: No gh CLI references in scope**
  - Setup: All changes applied
  - Action: Run `grep -r "gh pr\|gh issue\|gh api" src/ openspec/specs/ openspec/CONSTITUTION.md`
  - Verify: Zero results returned

- [ ] **Scenario: README documents MCP tools as primary**
  - Setup: README changes applied
  - Action: Read README setup section
  - Verify: MCP tools mentioned as built-in, `gh` CLI described as optional alternative

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 7 |
| Automated tests | 0 |
| Manual test items | 7 |
| Preserved (@manual) | 0 |
| Edge case tests | 1 |
| Warnings | 0 |
