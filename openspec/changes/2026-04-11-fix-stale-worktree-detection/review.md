## Review: Fix Stale Worktree Detection

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 3/3 complete |
| Requirements | 1/1 verified |
| Scenarios | 8/8 covered |
| Tests | 13/13 covered (manual) |
| Scope | Clean — all changed files trace to tasks |

### Changed Files

| File | Traced To |
|------|-----------|
| `openspec/specs/change-workspace/spec.md` | Specs phase — requirement + scenarios updated |
| `openspec/WORKFLOW.md` | Task 2.1 — `stale_days` config + instruction update |
| `src/templates/workflow.md` | Task 2.2 — template sync |
| `docs/capabilities/change-workspace.md` | Task 2.3 — capability doc update |
| `openspec/changes/2026-04-11-fix-stale-worktree-detection/*` | Pipeline artifacts |

### Requirement Verification

**Lazy Worktree Cleanup at Change Creation** (change-workspace/spec.md):
- Tier 1 (Proposal status): Lookup path changed from branch-name glob to `<worktree-path>/openspec/changes/*/proposal.md` — fixes the `worktree-` prefix mismatch. ✅
- Tier 2 (PR MERGED): Unchanged from previous spec. ✅
- Tier 3 (PR CLOSED): New tier — prompts user for confirmation. Spec text includes `SHALL NOT be suppressed by auto_approve`. ✅
- Tier 4 (Inactivity): New tier — checks `git log -1 --format=%ci`, compares to `stale_days` (default 14). ✅
- Tier 5 (git branch -d): Unchanged fallback. ✅
- Auto-clean vs prompted: Tiers 1-2 auto-clean, tiers 3-4 prompt. Documented in spec. ✅

### Scenario Coverage

| Scenario | Covered |
|----------|---------|
| Cleanup worktree with completed proposal status | ✅ (updated: reads from worktree path) |
| Cleanup worktree via PR status fallback | ✅ (unchanged) |
| Abandoned worktree detected via closed PR | ✅ (new) |
| Inactive worktree detected via commit age | ✅ (new) |
| Recent worktree within inactivity threshold preserved | ✅ (new) |
| No stale worktrees | ✅ (unchanged) |
| Worktree with active change preserved | ✅ (updated: adds stale_days context) |
| Cleanup without gh CLI and no proposal status | ✅ (updated: adds stale_days context) |

### Config Verification

- `openspec/WORKFLOW.md` has `stale_days: 14` in worktree section ✅
- `src/templates/workflow.md` has `#   stale_days: 14` (commented, matching template convention) ✅
- Both files have updated propose instruction mentioning closed PRs, inactivity, worktree filesystem paths ✅

### Edge Cases

| Edge Case | Spec Coverage |
|-----------|--------------|
| Dirty worktree during cleanup | ✅ (existing, unchanged) |
| `gh` CLI unavailable | ✅ (updated: falls through to inactivity then git branch -d) |
| PR state CLOSED | ✅ (new edge case added) |
| `stale_days` absent | ✅ (new edge case: defaults to 14) |
| Branch with no commits | ✅ (new edge case: treated as active) |

### Findings

#### CRITICAL

None.

#### WARNING

None.

#### SUGGESTION

None.

### Verdict

**PASS**
