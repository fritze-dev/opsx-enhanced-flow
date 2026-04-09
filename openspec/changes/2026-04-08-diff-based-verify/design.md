# Technical Design: Diff-Based Verification

## Context

The `/opsx:verify` skill validates implementation against change artifacts using keyword-based codebase search. This approach detects whether code *related to* a requirement exists, but cannot determine whether the *actual changes* match the planned scope. The skill runs in git repositories where `git diff` is always available. This change adds diff-based checks as a complementary verification dimension alongside existing keyword heuristics.

Two files are affected: the quality-gates spec (requirements) and the verify SKILL.md (implementation instructions).

## Architecture & Components

| Component | File | Change |
|-----------|------|--------|
| Quality-gates spec | `openspec/specs/quality-gates/spec.md` | Updated Post-Implementation Verification requirement: two dimensions (Implementation + Scope), diff content as primary evidence, new scenarios |
| Verify skill | `src/skills/verify/SKILL.md` | Restructured from 10 steps to 6 steps. Step 3 (Load context) loads artifacts + full diff. Step 4 (Verify Implementation) merges task completion, requirement verification, and scenario coverage — using diff content as primary evidence. Step 5 (Verify Scope) merges design adherence, diff scope check, side-effects, and code patterns. |

**Restructured flow** (10 → 6 steps):
1. Select change (unchanged)
2. Check status (unchanged)
3. **Load context** — merges artifact loading + diff loading. Loads full diff content (`git diff <base>...HEAD`) plus file list (`--name-only`). Both stored for use in subsequent steps.
4. **Verify Implementation** — merges old Completeness + Correctness. Task completion, task-diff mapping (against file paths AND diff content), requirement verification (diff as primary evidence, codebase as fallback), scenario coverage. Checks existence and correctness in one pass.
5. **Verify Scope** — merges old Coherence + Side-Effects. Design adherence (verified against diff evidence), diff scope check (file traceability), preflight side-effect cross-check, code pattern consistency.
6. Generate Report — two-dimension scorecard (Implementation + Scope).

## Goals & Success Metrics

* Verify uses diff content (not just file names) to assess whether changes match requirement intent — PASS/FAIL
* Verify detects a completed task with no corresponding diff evidence — PASS/FAIL
* Verify flags files in the diff not covered by any task or design component — PASS/FAIL
* Verify skips diff checks gracefully when no merge base exists — PASS/FAIL
* Verify reports untraced files as a single SUGGESTION, not one per file — PASS/FAIL

## Non-Goals

* Replacing keyword-based heuristics (they remain as complementary checks)
* Line-level diff analysis (file-level granularity is sufficient)
* Automated fix of diff-based findings (report only, user decides)
* Changes to preflight or docs-verify skills

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Restructure verify from 10 to 6 steps, two dimensions (Implementation + Scope) | Eliminates redundancy between Completeness/Correctness (both check requirements); groups related scope checks; cleaner mental model | Keep 3 dimensions + bolt on diff checks as 4th (adds complexity without clarity) |
| Diff content as primary evidence, codebase search as fallback | Diff shows exactly what this change introduced — most relevant evidence. Codebase search catches pre-existing code | Codebase search only (misses what actually changed); diff only (misses pre-existing implementations) |
| Load full diff content + file list in one step | Both needed: file list for scope checks, content for implementation verification | File list only (misses content-level verification); load on demand per check (redundant git calls) |
| Use `git merge-base HEAD main` for base detection | Works for both worktree branches and regular branches; handles rebased histories | Hardcode `main` as base (breaks for non-main default branches); use `@{upstream}` (not available for local-only branches) |
| Unintended changes as single grouped SUGGESTION | Reduces noise; one actionable item instead of N separate findings | One SUGGESTION per file (verbose for large changes); WARNING severity (too aggressive for heuristic) |
| Exclude `openspec/changes/` and `openspec/specs/` from scope checks | These paths are always expected in the diff for any OpenSpec change | Include them and match against proposal (over-engineering; these are always legitimate) |
| Task-diff mapping checks file paths AND content | File-level match alone is insufficient — content must relate to the task | File paths only (a comment change in the right file passes incorrectly); require explicit file references in tasks (too rigid) |

## Risks & Trade-offs

- **Task descriptions too vague for file matching** → Skip inconclusive matches rather than false-flag. Note as "inconclusive" in report. Consistent with existing side-effect keyword ambiguity handling.
- **Base branch not named `main`** → Use `git merge-base` which is branch-name-agnostic. Falls back gracefully if no merge base exists.
- **Large diffs producing noisy untraced file lists** → Grouped as single SUGGESTION. Change artifact paths excluded automatically.

## Open Questions

No open questions.

## Assumptions

- Git is available and the working directory is a valid git repository. <!-- ASSUMPTION: Git availability -->
- Task descriptions contain enough keywords to correlate with file paths in the diff. <!-- ASSUMPTION: Task description quality -->
