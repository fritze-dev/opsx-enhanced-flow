## Why

The `/opsx:verify` skill uses keyword-based codebase search to assess whether requirements are implemented. This is an existence check ("does code related to X exist?"), not a correctness check ("do the actual changes match what was planned?"). Discovered during #79 (spec-only change) where verify passed but didn't validate whether spec edits were correct or complete. Git diff data is available in every environment where verify runs but is not used.

## What Changes

- Add **diff scope verification** to the verify flow: read `git diff <base>...HEAD --name-only`, check that every changed file is traceable to a task or capability in the proposal/design
- Add **task-diff mapping**: for each completed task, verify that corresponding changes exist in the diff; flag tasks marked complete that produced no diff
- Add **unintended change detection**: flag files in the diff not mentioned in design.md's Architecture & Components or not covered by any task description (as SUGGESTION)
- Update the quality-gates spec with scenarios covering diff-based verification behavior

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `quality-gates`: Add requirements and scenarios for diff-based verification as a dimension of the existing Post-Implementation Verification requirement

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed. The diff-based verification is a natural extension of the existing "Post-Implementation Verification" requirement in the `quality-gates` spec. It shares the same actor (developer running verify), trigger (`/opsx:verify`), and report format. Creating a separate spec would produce fewer than 100 lines and duplicate the verify context.

Existing specs reviewed: quality-gates (directly related — owns verify), task-implementation (owns apply flow, not verification), human-approval-gate (post-verify, not relevant).

## Impact

- **Spec**: `openspec/specs/quality-gates/spec.md` — new scenarios added to Post-Implementation Verification requirement
- **Skill**: `src/skills/verify/SKILL.md` — new steps inserted into the verification flow (between current step 3 "Load artifacts" and step 5 "Verify Completeness")
- **No breaking changes** — existing verification dimensions (keyword-based) continue to work; diff checks are additive
- **Graceful degradation** — if no merge base is available (e.g., orphan branch, first commit), diff checks are skipped with a note

## Scope & Boundaries

**In scope:**
- Diff scope check (changed files traceable to tasks/design)
- Task-diff mapping (completed tasks produced changes)
- Unintended change detection (files outside design scope)
- Quality-gates spec updates with scenarios
- Verify SKILL.md updates with new steps

**Out of scope:**
- Replacing existing keyword-based heuristics (they remain as complementary checks)
- Preflight changes (preflight operates before implementation, no diff to check)
- Docs-verify changes (operates on documentation, not implementation diffs)
- New CLI flags or command syntax (verify remains stateless, same invocation)
