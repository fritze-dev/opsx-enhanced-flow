# Technical Design: Diff-Based Verification

## Context

The `/opsx:verify` skill validates implementation against change artifacts using keyword-based codebase search. This approach detects whether code *related to* a requirement exists, but cannot determine whether the *actual changes* match the planned scope. The skill runs in git repositories where `git diff` is always available. This change adds diff-based checks as a complementary verification dimension alongside existing keyword heuristics.

Two files are affected: the quality-gates spec (requirements) and the verify SKILL.md (implementation instructions).

## Architecture & Components

| Component | File | Change |
|-----------|------|--------|
| Quality-gates spec | `openspec/specs/quality-gates/spec.md` | New requirement paragraphs + 7 scenarios for diff-based verification (already done in specs stage) |
| Verify skill | `src/skills/verify/SKILL.md` | New step "Verify Diff Scope" inserted after step 3 (Load artifacts), before step 5 (Verify Completeness). Updates to Completeness (task-diff mapping) and Coherence (unintended change detection) steps. Summary scorecard updated with Diff Scope row. |

**Flow integration**: The new diff step reads `git diff` once and produces a file list that is reused by subsequent checks:
1. Step 3 (Load artifacts) — unchanged
2. **New Step 4: Load Diff** — run `git merge-base HEAD main`, then `git diff <base>...HEAD --name-only`. Store file list. If merge-base fails, set a flag to skip all diff checks.
3. Step 5 (Verify Completeness) — add task-diff mapping sub-check using the file list
4. Step 7 (Verify Coherence) — add unintended change detection sub-check using the file list
5. **New sub-section in step 9 (Report)** — add Diff Scope row to summary scorecard

## Goals & Success Metrics

* Verify detects a completed task with no corresponding diff (task-diff mapping) — PASS/FAIL
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
| Insert diff loading as new step 4, reuse file list in existing steps | Single git call, data shared across checks; avoids running git diff multiple times | Inline git diff in each check step (simpler per-step but redundant calls) |
| Use `git merge-base HEAD main` for base detection | Works for both worktree branches and regular branches; handles rebased histories | Hardcode `main` as base (breaks for non-main default branches); use `@{upstream}` (not available for local-only branches) |
| Unintended changes as single grouped SUGGESTION | Reduces noise; one actionable item instead of N separate findings | One SUGGESTION per file (verbose for large changes); WARNING severity (too aggressive for heuristic) |
| Exclude `openspec/changes/` and `openspec/specs/` from unintended change detection | These paths are always expected in the diff for any OpenSpec change | Include them and match against proposal (over-engineering; these are always legitimate) |
| Task-diff mapping uses keyword match against file paths | Consistent with existing keyword heuristic approach; task descriptions naturally contain component/module names | Full-text diff search (expensive and noisy); require explicit file references in tasks (too rigid) |

## Risks & Trade-offs

- **Task descriptions too vague for file matching** → Skip inconclusive matches rather than false-flag. Note as "inconclusive" in report. Consistent with existing side-effect keyword ambiguity handling.
- **Base branch not named `main`** → Use `git merge-base` which is branch-name-agnostic. Falls back gracefully if no merge base exists.
- **Large diffs producing noisy untraced file lists** → Grouped as single SUGGESTION. Change artifact paths excluded automatically.

## Open Questions

No open questions.

## Assumptions

- Git is available and the working directory is a valid git repository. <!-- ASSUMPTION: Git availability -->
- Task descriptions contain enough keywords to correlate with file paths in the diff. <!-- ASSUMPTION: Task description quality -->
