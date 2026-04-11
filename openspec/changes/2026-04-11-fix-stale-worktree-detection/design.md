<!--
---
has_decisions: true
---
-->
# Technical Design: Fix Stale Worktree Detection

## Context

The lazy worktree cleanup runs during `/opsx:workflow propose` before creating a new change workspace. It iterates worktrees from `git worktree list` and determines staleness via a tiered detection hierarchy. Issue #111 revealed three gaps: (1) the proposal lookup used a branch-name glob that fails due to the `worktree-` prefix mismatch, (2) closed PRs (abandoned) were not detected, and (3) inactive branches with no PR were invisible.

## Architecture & Components

| File | Change |
|------|--------|
| `openspec/specs/change-workspace/spec.md` | Requirement text: 3 tiers → 5 tiers, fixed lookup path, 4 new scenarios |
| `openspec/WORKFLOW.md` | New `stale_days: 14` config field + updated propose instruction |
| `src/templates/workflow.md` | Mirror WORKFLOW.md changes (template sync convention) |
| `docs/capabilities/change-workspace.md` | Updated capability description |

No new files. No architectural changes — this extends an existing detection hierarchy within the same requirement.

## Goals & Success Metrics

* Worktrees with `status: completed` proposals are detected regardless of branch naming convention — PASS when the lookup reads from worktree filesystem path
* PRs with state `CLOSED` trigger a user prompt — PASS when scenario "Abandoned worktree detected via closed PR" is satisfied
* Branches inactive beyond `stale_days` trigger a user prompt — PASS when scenario "Inactive worktree detected via commit age" is satisfied
* Existing cleanup behavior (completed proposals, merged PRs, git branch -d fallback) is unchanged — PASS when existing scenarios still hold
* `auto_approve: true` does not suppress abandoned/inactive prompts — PASS when tiers 3-4 always prompt

## Non-Goals

* Adding an `abandoned` proposal status to the lifecycle
* Fixing stale main during worktree creation (already addressed in spec line 100)
* Automatic cleanup of abandoned worktrees without user confirmation

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Read proposals from worktree filesystem path | Branch names use `worktree-` prefix but directory names don't — glob matching by branch name fails. Reading from the worktree path is naming-convention-agnostic. | Strip `worktree-` prefix before matching (fragile, assumes convention) |
| User prompt for tiers 3-4, auto-clean for tiers 1-2 | Abandoned worktrees may contain salvageable work; completed/merged changes are confirmed done | Auto-clean all (risky for abandoned work); detect-only without cleanup (leaves stale worktrees) |
| 14-day default for `stale_days`, configurable | Balances vacation pauses (not too short) vs catching abandoned work (not too long) | Fixed threshold (inflexible); no inactivity check (leaves detection gap) |
| Prompts bypass `auto_approve` | Tiers 3-4 involve potential data loss; even automated flows should confirm before deleting potentially useful work | Respect `auto_approve` (could silently delete work) |

## Risks & Trade-offs

- **Inactivity false positive** → Mitigated by configurable threshold and mandatory user confirmation
- **`gh` unavailability** → Tiers 2-3 degrade gracefully to tier 4 (inactivity) and tier 5 (git branch -d)
- **Additional prompts during propose** → Only fires when stale worktrees are detected; no impact on clean state

## Open Questions

No open questions.

## Assumptions

No assumptions made.
