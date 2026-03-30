# Pre-Flight Check: Fix Squash Merge Cleanup

## A. Traceability Matrix

- [x] Requirement: Worktree Cleanup After Archive (MODIFIED) → Scenario: Branch deletion after squash merge → `src/skills/archive/SKILL.md` Step 6.4
- [x] Requirement: Worktree Cleanup After Archive (MODIFIED) → Scenario: Branch deletion without gh CLI → `src/skills/archive/SKILL.md` Step 6.4
- [x] Requirement: Worktree Cleanup After Archive (MODIFIED) → Scenario: Branch deletion without PR → `src/skills/archive/SKILL.md` Step 6.4

## B. Gap Analysis

No gaps identified. The three scenarios cover:
- Happy path (squash merge with `gh` available)
- Fallback path (`gh` unavailable)
- Fallback path (no PR exists)

The existing scenarios (manual cleanup, not in worktree) are unchanged.

## C. Side-Effect Analysis

- **No regression risk:** The change only affects the branch deletion substep. `git worktree remove` (Step 6.3) is untouched.
- **Fallback preserves existing behavior:** When `gh` is unavailable, the system uses `git branch -d` — identical to current behavior.
- **No other skills affected:** `git branch -d` is only used in archive Step 6.4.

## D. Constitution Check

No constitution updates needed. No new patterns introduced — `gh` CLI usage follows the existing pattern from `post_artifact`.

## E. Duplication & Consistency

- No overlapping stories.
- The `gh` CLI fallback pattern is consistent with `post_artifact` in WORKFLOW.md: "If `gh` CLI is unavailable or not authenticated, skip PR creation."
- No contradictions with existing specs.

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers in the delta spec or design.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any change artifacts.
