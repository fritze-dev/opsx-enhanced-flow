---
status: active
branch: worktree-fetch-main
worktree: .claude/worktrees/worktree-fetch-main
capabilities:
  new: []
  modified: [change-workspace]
  removed: []
---
## Why

When `/opsx:new` creates a worktree, it bases the new branch on the local `main` HEAD. If local `main` is behind `origin/main`, the worktree starts from a stale commit, leading to avoidable merge conflicts when the PR is created. The fix is to fetch `origin/main` and use it as the start-point for worktree creation.

## What Changes

- Add a `git fetch origin main` step before worktree creation in `/opsx:new`
- Use `origin/main` as the explicit start-point for `git worktree add` instead of implicit local HEAD

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: The "Create Worktree-Based Workspace" requirement needs to specify that the system SHALL fetch the latest remote main and use `origin/main` as the start-point.

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. The change modifies an existing requirement within `change-workspace`, which already owns the worktree creation behavior.

## Impact

- **Code:** `src/skills/new/SKILL.md` step 4.3 (worktree creation command)
- **Specs:** `openspec/specs/change-workspace/spec.md` — "Create Worktree-Based Workspace" requirement and its scenarios
- **Dependencies:** None. Uses standard git commands.
- **APIs:** None.

## Scope & Boundaries

**In scope:**
- Fetch + start-point change in the `/opsx:new` skill
- Spec update for the worktree creation requirement

**Out of scope:**
- Updating local `main` branch (unnecessary — worktree branches directly from `origin/main`)
- Changes to other skills or worktree cleanup behavior
- Non-`origin` remote names
