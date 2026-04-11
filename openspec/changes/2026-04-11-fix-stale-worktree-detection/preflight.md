# Pre-Flight Check: Fix Stale Worktree Detection

## A. Traceability Matrix

- [x] Lazy Worktree Cleanup → Scenario: Cleanup worktree with completed proposal status → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: Cleanup worktree via PR status fallback → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: Abandoned worktree detected via closed PR → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: Inactive worktree detected via commit age → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: Recent worktree within inactivity threshold preserved → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: No stale worktrees → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: Worktree with active change preserved → `change-workspace/spec.md`
- [x] Lazy Worktree Cleanup → Scenario: Cleanup without gh CLI and no proposal status → `change-workspace/spec.md`
- [x] Config → `worktree.stale_days` in WORKFLOW.md → `openspec/WORKFLOW.md`
- [x] Template Sync → `src/templates/workflow.md` mirrors WORKFLOW.md changes

## B. Gap Analysis

No gaps identified. The 5-tier hierarchy covers all known detection paths:
- Completed proposal (tier 1)
- Merged PR (tier 2)
- Closed/abandoned PR (tier 3, new)
- Inactive branch (tier 4, new)
- Merged-to-main fallback (tier 5)

Edge cases addressed: `gh` unavailable, dirty worktree, no commits on branch, `stale_days` absent.

## C. Side-Effect Analysis

- **Existing cleanup behavior**: Tiers 1, 2, and 5 are unchanged. The new tiers (3, 4) are additive. No regression risk.
- **User prompt flow**: Tiers 3-4 introduce prompts during `/opsx:workflow propose`. This is a new interaction pattern for lazy cleanup but consistent with existing UX (the router already prompts for change selection).
- **`auto_approve` behavior**: Tiers 3-4 explicitly bypass `auto_approve`. This is intentional and documented in the spec.

## D. Constitution Check

No constitution update needed. No new patterns, technologies, or architectural changes introduced.

## E. Duplication & Consistency

- **ADR-035** (PR merge check for branch deletion): The new tier 3 reuses the same `gh pr view` pattern. Consistent with the existing approach.
- **Post-Merge Worktree Cleanup** requirement: Unchanged. Lazy cleanup (this change) and immediate cleanup are complementary, as documented in the spec.
- **Active vs Completed Change Detection** requirement: Unchanged. The `status` field lifecycle (`active → completed`) is not modified.

## F. Assumption Audit

No ASSUMPTION markers found in spec.md or design.md related to this change. The existing assumption ("System clock accuracy") is unchanged.

## G. Review Marker Audit

No REVIEW markers found. PASS.

---

**Verdict: PASS**
