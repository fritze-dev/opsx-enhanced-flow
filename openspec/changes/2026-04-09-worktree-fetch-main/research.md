# Research: Worktree Fetch Latest Main

## 1. Current State

**Affected code:**
- `src/skills/new/SKILL.md` — Step 4.3 runs `git worktree add <path> -b <change-name>` without specifying a start point. Git defaults to `HEAD`, which is the local `main` branch at the time of invocation.
- `openspec/specs/change-workspace/spec.md` — The "Create Worktree-Based Workspace" requirement (line 100) specifies `git worktree add <path> -b <change-name>` without mentioning a fetch or start point.

**Problem:** When local `main` is behind `origin/main` (e.g., a collaborator pushed changes, or the user merged a PR on GitHub without pulling), the new worktree starts from a stale commit. This causes avoidable merge conflicts when the PR is eventually created or merged.

**Stale-spec check:** The `change-workspace` spec accurately reflects the current SKILL.md behavior — both omit the fetch step, so the spec is in sync with the code but both need updating.

## 2. External Research

**Git worktree start-point:** `git worktree add <path> -b <branch> [<start-point>]` accepts an optional start-point. Using `origin/main` as the start-point bases the new branch on the remote tracking ref without requiring the local `main` to be updated first.

**`git fetch` scope:** `git fetch origin main` fetches only the `main` branch from the remote, which is lightweight and fast. It updates `origin/main` without touching the local `main` branch or working tree.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: `git fetch origin main` + use `origin/main` as start-point | Clean — never touches local `main`; minimal network overhead; one fetch for the one branch needed | Requires network access; fails if remote is unreachable |
| B: `git fetch origin main` + `git merge --ff-only origin/main` on local main, then worktree from HEAD | Local `main` stays up to date for other purposes | Touches local `main` which may have diverged; more complex; unnecessary since worktree doesn't need local main |
| C: No fetch, just use `origin/main` without fetching | Zero network; works if user fetched recently | `origin/main` could be stale itself; misleading — appears fresh but may not be |

**Recommended: Approach A** — fetch `origin/main` and use it as the start-point for `git worktree add`. This is exactly what the issue suggests and is the simplest correct solution.

## 4. Risks & Constraints

- **No breaking changes:** This is purely additive behavior. Existing worktrees are unaffected.
- **Non-default remote name:** The skill hardcodes `origin`. This is the standard convention and matches the existing `post_artifact` hook in WORKFLOW.md which also uses `origin`. Not a new limitation.
- **Performance:** `git fetch origin main` is fast (single branch). Negligible impact on `/opsx:new` latency.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Fetch + start-point change in SKILL.md and spec |
| Behavior | Clear | Fetch before worktree creation; fall back on failure |
| Data Model | Clear | No data model changes |
| UX | Clear | Transparent to user; only visible on network failure (warning) |
| Integration | Clear | Affects only `/opsx:new` step 4.3; no downstream skill changes |
| Edge Cases | Clear | Network failure, remote renamed, local main diverged — all handled by approach A |
| Constraints | Clear | Requires network; graceful fallback exists |
| Terminology | Clear | No new terms |
| Non-Functional | Clear | Adds one network call; negligible latency |

## 6. Open Questions

All categories are Clear — no open questions.
