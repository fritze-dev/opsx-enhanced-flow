---
has_decisions: true
---
# Technical Design: Worktree Fetch Latest Main

## Context

`/opsx:new` creates worktrees via `git worktree add <path> -b <name>`, which implicitly bases the new branch on the local HEAD. When local `main` is behind `origin/main`, the worktree starts from stale code. The fix adds a fetch step and uses `origin/main` as the explicit start-point.

## Architecture & Components

**Affected files:**
- `src/skills/new/SKILL.md` — Step 4.3: add fetch before worktree creation, use `origin/main` as start-point, handle fetch failure with fallback.

No other skills, templates, or modules are affected.

## Goals & Success Metrics

* Worktree created by `/opsx:new` SHALL be based on `origin/main` after a successful fetch — PASS/FAIL by inspecting `git log -1` in the new worktree vs `git ls-remote origin main`.
* When network is unavailable, `/opsx:new` SHALL warn and fall back to local HEAD without blocking — PASS/FAIL by testing with an unreachable remote.

## Non-Goals

- Updating the local `main` branch (unnecessary — worktree branches from `origin/main` directly)
- Supporting non-`origin` remote names
- Changes to other skills or worktree cleanup behavior

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Use `origin/main` as start-point instead of updating local `main` | Simpler — no need to touch local main, which may have diverged; one fewer failure mode | Update local main with `git merge --ff-only` — more complex, may fail if local main diverged |
| Warn and fall back on fetch failure | Non-blocking — offline work should still be possible; worktree from stale local is better than no worktree | Abort on fetch failure — too restrictive for offline scenarios |

## Risks & Trade-offs

- [Network latency] → `git fetch origin main` is single-branch and fast; negligible impact on `/opsx:new` startup time.
- [Offline usage] → Mitigated by graceful fallback to local HEAD with a user-visible warning.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
