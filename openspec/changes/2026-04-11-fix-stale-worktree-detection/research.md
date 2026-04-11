# Research: Fix Stale Worktree Detection

## 1. Current State

The lazy worktree cleanup logic is defined in `openspec/specs/change-workspace/spec.md` (lines 170-218, "Requirement: Lazy Worktree Cleanup at Change Creation"). It runs during `/opsx:workflow propose` before creating a new change workspace.

**Current 3-tier detection hierarchy:**

1. **Proposal status check**: Glob `openspec/changes/*-<branch>/proposal.md` — if `status: completed`, auto-clean
2. **PR status fallback**: `gh pr view <branch> --json state` — if `MERGED`, auto-clean
3. **Git branch fallback**: `git branch -d <branch>` — only succeeds if merged to main

**Related files:**
- `openspec/specs/change-workspace/spec.md` — spec owning the requirement
- `openspec/WORKFLOW.md` (line 36) — propose instruction referencing lazy cleanup
- `src/templates/workflow.md` (line 36) — consumer template mirror
- `docs/capabilities/change-workspace.md` (lines 50-52) — capability doc describing the feature
- `docs/decisions/adr-035-pr-merge-check-for-branch-deletion.md` — existing ADR for PR merge checks
- `src/templates/proposal.md` (line 49) — proposal status field: `active | completed`

**Branch naming convention:** Worktree branches use a `worktree-` prefix (e.g., `worktree-auto-test-generation`), but change directories omit it (e.g., `2026-04-10-auto-test-generation`). This is confirmed by examining multiple proposals' `branch` frontmatter fields.

## 2. External Research

N/A — this is an internal spec-only change. No external APIs or libraries involved.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Fix lookup path + add CLOSED PR + inactivity tiers | Addresses all 3 gaps; incremental change; backward compatible | Adds complexity to detection hierarchy (5 tiers vs 3) |
| Add `abandoned` proposal status | Explicit lifecycle state; simple detection | Requires mechanism to set it; template + parsing changes across multiple files |
| Only fix lookup path (minimal fix) | Simplest change; fixes the reported case | Doesn't address abandoned PRs or inactive worktrees |

**Recommended**: Approach 1 (fix lookup + add tiers). Addresses all reported gaps without requiring new proposal status lifecycle.

## 4. Risks & Constraints

- **User prompts bypass auto_approve**: Abandoned worktree cleanup involves potential data loss. Prompts for tiers 3-4 should fire regardless of `auto_approve` setting.
- **`gh` CLI availability**: Tier 3 (CLOSED PR) depends on `gh`. If unavailable, falls through to inactivity check (tier 4).
- **Inactivity false positives**: Developer on vacation could have work flagged. Mitigated by using a configurable threshold (`stale_days`, default 14) and requiring explicit confirmation.
- **Stale main (from issue comment)**: Already addressed by spec line 100 ("SHALL fetch the latest remote main branch") and the `worktree-fetch-main` change. No spec change needed.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three bugs/gaps identified from issue #111 + comment |
| Behavior | Clear | 5-tier hierarchy with auto-clean vs prompted distinction |
| Data Model | Clear | New `stale_days` config field in WORKFLOW.md worktree section |
| UX | Clear | User prompted for abandoned/inactive; auto-clean for completed/merged |
| Integration | Clear | Reuses existing `gh pr view` pattern from ADR-035 |
| Edge Cases | Clear | Dirty worktree, no PR, no `gh`, recent activity within threshold |
| Constraints | Clear | Must not break existing 3 scenarios; prompts bypass auto_approve |
| Terminology | Clear | "completed" (auto-clean) vs "abandoned/stale" (prompted) |
| Non-Functional | Clear | No performance concern — runs once per propose |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | User prompt for abandoned/inactive worktrees | Abandoned worktrees may contain salvageable work; auto-delete risks data loss | Auto-clean (risky), detect-only without cleanup (leaves stale worktrees) |
| 2 | No `abandoned` proposal status | External signals (PR state, inactivity) are sufficient; avoids template + parsing changes | Add `abandoned` status (higher implementation cost, needs trigger mechanism) |
| 3 | 14-day default for stale_days, configurable | Balances vacation pauses vs catching abandoned work | Fixed threshold (inflexible), no inactivity check (leaves gap) |
| 4 | Read proposals from worktree filesystem path | Fixes the branch-naming mismatch that caused the original issue | Strip `worktree-` prefix from branch name (fragile, assumes naming convention) |
