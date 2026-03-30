# Pre-Flight Check: Fix Apply Baseline Edits

## A. Traceability Matrix

- [x] Baseline Spec Exclusion from Implementation Scope
  - Scenario: Task generation excludes baseline spec edits → schema.yaml task instruction
  - Scenario: Apply skips baseline spec edits → skills/apply/SKILL.md guardrails
  - Formal requirement → openspec/specs/task-implementation/spec.md

## B. Gap Analysis

No gaps identified. The change is additive text in three files. Edge cases (doc-only changes, delta specs in scope) are addressed in the delta spec.

## C. Side-Effect Analysis

- **Existing task generation:** No regression — adding text to the IMPORTANT block does not affect existing exclusion rules for sync/archive.
- **Apply skill:** No regression — adding a guardrail is additive; existing guardrails remain unchanged.
- **Spec sync:** Unaffected — sync reads delta specs and writes to baseline specs as before.

## D. Constitution Check

No constitution update needed. The constitution already defines the baseline/delta spec paths (lines 20–22). The exclusion rule is enforced via schema instruction and skill guardrails, not constitution.

## E. Duplication & Consistency

- The schema.yaml instruction already says "Do NOT include sync or archive as tasks." The baseline spec exclusion extends this pattern consistently.
- No contradiction with existing specs. The `spec-sync` spec defines sync as the path for baseline updates — this change reinforces that contract.

## F. Assumption Audit

No assumption markers found in spec.md or design.md for this change.

## Verdict

**PASS** — No warnings, no blockers. Ready for task generation.
