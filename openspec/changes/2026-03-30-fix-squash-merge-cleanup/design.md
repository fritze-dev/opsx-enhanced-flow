# Technical Design: Fix Squash Merge Cleanup

## Context

The archive skill's worktree cleanup (Step 6.4) uses `git branch -d` to delete the feature branch after removing the worktree. This fails after squash merges because Git's built-in merge detection checks commit reachability — squash merges create a new commit on main, making the original branch commits unreachable. The `gh` CLI is already used by `post_artifact` for PR creation, so it's an existing dependency.

## Architecture & Components

Single file affected: `src/skills/archive/SKILL.md` — Step 6, substep 4.

Current logic (Step 6.4):
```
If the branch has been merged to main: `git branch -d <change-name>`
```

New logic (Step 6.4):
```
Check PR merge status: `gh pr view <change-name> --json state --jq '.state'`
- If result is "MERGED": `git branch -D <change-name>`
- If `gh` fails (unavailable, no PR): fall back to `git branch -d <change-name>`
```

## Goals & Success Metrics

- Branch deletion succeeds after squash merge without manual intervention — PASS/FAIL
- Branch deletion still works for regular merges (no regression) — PASS/FAIL
- Graceful fallback when `gh` is unavailable — PASS/FAIL

## Non-Goals

- Changing merge strategy or PR workflow
- Adding worktree cleanup to other skills
- Handling `git worktree remove` failures (already covered by existing edge case in spec)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Check PR state via `gh pr view` | Authoritative source; handles all merge strategies | Cherry-pick detection via `git log --cherry` (fragile, slow) |
| Use `--jq '.state'` for parsing | Clean single-value output, no JSON parsing needed | `--json state` + manual parsing (unnecessary complexity) |
| Fall back to `git branch -d` on `gh` failure | Preserves existing behavior; safe default | Skip deletion (leaves stale branches), always `-D` (unsafe) |

## Risks & Trade-offs

- [Risk] `gh` CLI rate limiting on frequent archives → Mitigation: Single API call per archive, well within limits
- [Trade-off] Force delete (`-D`) bypasses Git safety check → Acceptable because GitHub API confirms merge status

## Open Questions

No open questions.

## Assumptions

No assumptions made.
