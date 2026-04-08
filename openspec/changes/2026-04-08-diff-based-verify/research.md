# Research: Diff-Based Verification for /opsx:verify

## 1. Current State

**Verify skill** (`src/skills/verify/SKILL.md`) uses a 9-step flow across three dimensions:
- **Completeness**: Parses task checkboxes in tasks.md + keyword-searches codebase for spec requirement evidence
- **Correctness**: Keyword-searches for requirement implementation, checks scenario coverage via grep heuristics
- **Coherence**: Reviews design decisions and code pattern consistency

**All implementation evidence is gathered via keyword/grep search.** The skill never reads `git diff` or compares changed files against expected scope. This means:
- A task marked complete that produced no actual file changes goes undetected
- Files changed outside the design scope (accidental edits, unrelated modifications) are invisible
- For spec-only changes, there's no validation that spec edits actually occurred or are consistent

**Quality-gates spec** (`openspec/specs/quality-gates/spec.md`) defines the "Post-Implementation Verification" requirement with scenarios for completeness, correctness, coherence, side-effects, and graceful degradation. None of the current scenarios involve diff-based checks.

**Affected files:**
- `openspec/specs/quality-gates/spec.md` — needs new scenarios for diff-based verification
- `src/skills/verify/SKILL.md` — needs new steps for diff-reading in the verification flow

**No external dependencies** — `git diff` is available in all environments where the skill runs (git is a prerequisite for worktrees).

## 2. External Research

Not applicable — this change uses built-in git commands (`git diff`, `git diff --name-only`) already available in the execution environment. No new libraries or APIs needed.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add diff checks as a **new dimension** (4th pillar alongside Completeness/Correctness/Coherence) | Clean separation; existing dimensions untouched; easy to skip when diff unavailable | Adds a 4th column to the scorecard; may duplicate some completeness checks |
| B: **Weave diff checks into existing dimensions** (diff scope → Coherence, task-diff mapping → Completeness, etc.) | Leverages existing report structure; no new dimension to explain | Harder to distinguish keyword-based vs diff-based findings; mixes heuristic and concrete evidence |
| C: **Replace keyword heuristics with diff-based checks entirely** | Simplest mental model; no dual-system | Breaks graceful degradation (no diff available for changes without a base branch); loses ability to catch requirements never touched by any change |

**Recommendation: Approach B** — weave diff checks into existing dimensions. The diff checks naturally map:
- Diff Scope Check → Coherence (are changes architecturally coherent with the design?)
- Task-Diff Mapping → Completeness (did each task produce changes?)
- Spec-only Change Mode → Correctness (did spec edits match intent?)
- Unintended Change Detection → Coherence (no out-of-scope files)

This avoids restructuring the report format while adding concrete evidence alongside existing heuristics.

## 4. Risks & Constraints

- **Base branch detection**: `git diff` requires knowing the base branch. In worktrees, this is typically `main`. For non-worktree flows, the branch may not exist or may have diverged. Need a fallback (`git merge-base` or skip diff checks).
- **Spec-only changes**: When a change only edits specs (no code), the current verify flow's keyword search against the codebase is meaningless. The diff-based approach is the only useful verification for these changes.
- **Large diffs**: Changes with many files could produce verbose output. The skill should summarize rather than list every file.
- **Merge commits**: `git diff base...HEAD` handles merge commits correctly (three-dot diff shows changes on the branch), but rebase-heavy workflows may have different base points.
- **No diff available**: First commit on a repo or orphan branches have no merge base. Must degrade gracefully.
- **Skill immutability**: Per constitution, skills are generic plugin code. The diff-based logic must work for any project, not just this one. Using `git diff` and proposal/design references is project-agnostic.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Issue #83 defines 4 specific checks; affected files identified |
| Behavior | Clear | Each check has well-defined input/output: diff → file list → match against artifacts |
| Data Model | Clear | No new data structures; existing report format extended with diff findings |
| UX | Clear | Report output adds diff-based findings to existing sections; no new commands |
| Integration | Clear | Fits into existing verify flow as additional steps; git commands available |
| Edge Cases | Partial | Spec-only mode detection heuristic needs definition; base branch resolution needs fallback strategy |
| Constraints | Clear | Skill immutability respected; no external dependencies |
| Terminology | Clear | "Diff scope", "task-diff mapping", "unintended change" are self-explanatory |
| Non-Functional | Clear | Performance acceptable — `git diff --name-only` is fast even for large repos |

## 6. Open Questions

| # | Question | Category | Impact |
|---|----------|----------|--------|
| 1 | For spec-only change detection, should we use a heuristic (all changed files under `openspec/specs/`) or rely on proposal metadata (no code capabilities listed)? | Edge Cases | High — determines when spec-only mode activates |
| 2 | Should unintended change detection flag files not in design.md as WARNING or SUGGESTION? The issue says "flag", but the existing spec says "err on the side of lower severity when uncertain." | Edge Cases | Medium — affects signal-to-noise ratio of the report |

## 7. Decisions
<!-- Filled after user feedback. -->

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | No separate spec-only mode — diff checks work uniformly for all change types | Diff scope, task-diff mapping, and unintended change detection are file-type-agnostic; existing keyword heuristics already degrade gracefully when irrelevant | Separate spec-only mode with different validation rules; proposal-metadata-based detection |
| 2 | Unintended changes flagged as SUGGESTION, not WARNING | Files outside design scope may be legitimate dependencies; consistent with spec principle "err on lower severity when uncertain" | WARNING (higher visibility but more noise); CRITICAL (too aggressive for heuristic detection) |
