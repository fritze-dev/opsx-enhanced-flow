# ADR-035: PR Merge Check for Branch Deletion

## Status

Accepted (2026-03-30)

## Context

The `/opsx:archive` skill's worktree cleanup step used `git branch -d` to delete the feature branch after removing the worktree. This command relies on Git's built-in merge detection, which checks whether the branch's commits are reachable from HEAD. Squash merges (GitHub's "Squash and merge" option) create a new commit on main that combines all branch commits — the original commits are never reachable from HEAD. As a result, `git branch -d` fails with "not fully merged" after any squash-merged PR, leaving stale branches behind and producing confusing error output. The `gh` CLI is already an existing dependency used by the `post_artifact` hook for PR creation, so leveraging it for merge status checks requires no new dependencies.

## Decision

1. **Check PR state via `gh pr view` before branch deletion** — the GitHub API is the authoritative source for merge status and correctly identifies squash merges, rebase merges, and regular merges alike. Using `gh pr view <branch> --json state --jq '.state'` provides a clean single-value output without JSON parsing.
2. **Use `git branch -D` (force delete) when PR is confirmed merged** — force delete bypasses Git's commit-reachability check, which is safe because the GitHub API has already confirmed the merge.
3. **Fall back to `git branch -d` when `gh` is unavailable** — preserves existing behavior in environments without GitHub integration or when no PR exists for the branch.

## Alternatives Considered

- **Cherry-pick detection via `git log --cherry`**: Fragile and slow — unreliable for squash merges where commit content is combined.
- **Always use `git branch -D`**: Simple but unsafe — would delete branches with unmerged work without any verification.
- **Skip branch deletion entirely**: Leaves stale branches behind, which accumulate over time.

## Consequences

### Positive

- Branch deletion succeeds regardless of merge strategy (squash, rebase, regular)
- No manual cleanup needed after squash-merged PRs
- Graceful degradation when `gh` CLI is unavailable

### Negative

- Force delete (`-D`) bypasses Git's safety check — mitigated by GitHub API confirmation of merge status. If `gh` gives a false positive (extremely unlikely), the branch would be force-deleted even if not truly merged.

## References

- [Change: fix-squash-merge-cleanup](../../openspec/changes/2026-03-30-fix-squash-merge-cleanup/)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [ADR-033: Worktree-Based Change Lifecycle](adr-033-worktree-based-change-lifecycle.md)
- [ADR-034: Auto-Sync Before Archive](adr-034-auto-sync-before-archive.md)
