## MODIFIED Requirements

### Requirement: Worktree Cleanup After Archive

The `/opsx:archive` skill SHALL offer worktree cleanup after archiving when the session is in a worktree. The skill SHALL read `worktree.auto_cleanup` from WORKFLOW.md. If `auto_cleanup` is `true`, the system SHALL navigate to the main repository, run `git worktree remove <path>`, and delete the branch. To determine whether the branch has been merged, the system SHALL first check the PR merge status via `gh pr view <branch> --json state`. If the PR state is `MERGED`, the system SHALL use `git branch -D <branch>` (force delete). If `gh` is unavailable, not authenticated, or no PR exists for the branch, the system SHALL fall back to `git branch -d <branch>`. If `auto_cleanup` is `false` or absent, the system SHALL inform the user how to clean up manually (`git worktree remove <path>`).

**User Story:** As a developer I want worktrees cleaned up after archiving, so that stale worktrees don't accumulate on disk.

#### Scenario: Auto-cleanup after archive

- **GIVEN** the user is in a worktree at `.claude/worktrees/add-user-auth`
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system navigates to the main repository
- **AND** runs `git worktree remove .claude/worktrees/add-user-auth`
- **AND** deletes the merged branch `add-user-auth`

#### Scenario: Branch deletion after squash merge

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **AND** the PR for `add-user-auth` was squash-merged to main
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the system attempts to delete the branch during cleanup
- **THEN** the system runs `gh pr view add-user-auth --json state`
- **AND** the result shows `"state": "MERGED"`
- **AND** the system runs `git branch -D add-user-auth`

#### Scenario: Branch deletion without gh CLI

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **AND** `gh` CLI is unavailable or not authenticated
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the system attempts to delete the branch during cleanup
- **THEN** the system falls back to `git branch -d add-user-auth`

#### Scenario: Branch deletion without PR

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **AND** no PR exists for branch `add-user-auth`
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the system attempts to delete the branch during cleanup
- **THEN** the system falls back to `git branch -d add-user-auth`

#### Scenario: Manual cleanup instructions

- **GIVEN** the user is in a worktree
- **AND** WORKFLOW.md has `worktree.auto_cleanup: false` or the field is absent
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system informs the user: "Worktree at <path> still exists. Run `git worktree remove <path>` to clean up."

#### Scenario: Not in worktree — no cleanup

- **GIVEN** the user is in the main working tree
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system SHALL NOT mention worktree cleanup (existing behavior)

## Edge Cases

- **`gh` CLI unavailable during branch deletion**: Fall back to `git branch -d`. If that also fails (squash merge without `gh`), report the error and suggest `git branch -D <branch>` manually.

## Assumptions

No assumptions made.
