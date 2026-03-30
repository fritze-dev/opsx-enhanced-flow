# Pre-Flight Check: Fix Archive Unstaged Deletions

## A. Traceability Matrix

- [x] "Archive Completed Change" (modified) → Scenario: Archive stages both new and old paths → `src/skills/archive/SKILL.md` step 5 (add `git add` for old path)
- [x] Edge case: Untracked files in change directory → `git add` on old path only records tracked file deletions (acceptable)

## B. Gap Analysis

No gaps identified. Single-line addition to step 5.

## C. Side-Effect Analysis

- **Other archive steps**: Steps 1-4 and 6-7 untouched. Only step 5 changes.
- **Post-artifact hook**: Not affected — the hook stages `openspec/changes/<name>/` which is the same path we're adding.
- **Regression risk**: None. Adding `git add` for a deleted path is additive — if the path has no tracked files, the command is a no-op.

## D. Constitution Check

No constitution changes needed. Bug fix to the archive skill.

## E. Duplication & Consistency

- The new "Archive stages both new and old paths" scenario is distinct from existing scenarios — it covers the Git staging behavior, not the file move itself.
- No contradictions with existing specs.

## F. Assumption Audit

No assumptions found in spec.md or design.md.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts.
