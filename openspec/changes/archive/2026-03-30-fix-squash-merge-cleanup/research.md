# Research: Fix Squash Merge Cleanup

## 1. Current State

The archive skill ([SKILL.md](src/skills/archive/SKILL.md)) Step 6 handles worktree cleanup after archiving. The current flow:

1. Detect worktree context via `git rev-parse --git-dir`
2. If `auto_cleanup` is `true`:
   - `git worktree remove <path>`
   - `git branch -d <change-name>` (if merged to main)

The problem: `git branch -d` uses Git's built-in merge detection, which checks if the branch's commits are reachable from HEAD. **Squash merges create a new commit on main** — the original branch commits are never reachable from HEAD. Git therefore reports "not fully merged" and refuses to delete.

The corresponding spec is in [change-workspace/spec.md](openspec/specs/change-workspace/spec.md), lines 172-198 ("Worktree Cleanup After Archive"). The spec says "delete the branch if it has been merged to main" but doesn't specify the mechanism. The SKILL.md hardcodes `git branch -d`.

## 2. External Research

- `git branch -d` checks if all commits on the branch are ancestors of HEAD. Squash merges (and GitHub's "Squash and merge") create a single new commit — original commits are not ancestors.
- `git branch -D` force-deletes regardless of merge status.
- `gh pr view <branch> --json state` returns `{"state":"MERGED"}` for merged PRs.
- `gh pr view <branch> --json mergedAt,mergeCommit` provides additional details if needed.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Check PR state via `gh pr view`, use `-D` if merged | Safe (confirmed via GitHub API), handles all merge strategies | Requires `gh` CLI and authentication |
| B: Always use `git branch -D` after worktree removal | Simple, no external dependency | Unsafe if branch has unmerged work |
| C: Try `-d` first, fall back to `-D` after PR check | Handles both regular and squash merges | More complex, two-step process with no benefit over A |

**Recommended: Approach A.** The `gh` CLI is already a dependency for PR creation in `post_artifact`. Checking PR state before force-deleting is the safest approach and handles all merge strategies (regular, squash, rebase).

## 4. Risks & Constraints

- **`gh` CLI unavailable:** The SKILL.md already handles this case for PR creation ("If `gh` CLI is unavailable or not authenticated, skip PR creation"). Same fallback applies — if `gh` is unavailable, fall back to `git branch -d` and let the user handle the error.
- **No PR exists:** If the branch was never pushed or has no PR, `gh pr view` will fail. In this case, fall back to `git branch -d` (original behavior).
- **Blast radius:** Only affects Step 6.4 of the archive skill. No other skills or specs are impacted.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Single line change in SKILL.md Step 6.4, corresponding spec scenario update |
| Behavior | Clear | Check PR merge state, use `-D` if confirmed merged |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing changes — cleanup becomes silent success instead of error |
| Integration | Clear | Uses existing `gh` CLI dependency |
| Edge Cases | Clear | gh unavailable, no PR exists, regular merge (still works) |
| Constraints | Clear | No breaking changes, backwards compatible |
| Terminology | Clear | No new terms |
| Non-Functional | Clear | No performance impact |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

No user input required — proceeding with Approach A.

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Check PR state via `gh pr view` before branch deletion | Confirmed merge status from GitHub API is authoritative and handles all merge strategies | Always `-D` (unsafe), try `-d` then fall back (unnecessary complexity) |
| 2 | Fall back to `git branch -d` if `gh` is unavailable or no PR exists | Preserves existing behavior in environments without GitHub integration | Skip branch deletion entirely (leaves stale branches) |
