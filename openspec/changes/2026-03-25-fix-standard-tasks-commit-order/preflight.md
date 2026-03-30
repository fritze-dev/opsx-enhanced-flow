# Pre-Flight Check: Fix Standard Tasks Commit Order

## A. Traceability Matrix

- [x] Standard Tasks Exclusion from Apply Scope (modified) → Scenario "Standard tasks marked before commit" → `schema.yaml` apply.instruction, `task-implementation/spec.md`
- [x] Scenario "Apply skips standard tasks section" → unchanged, no implementation needed
- [x] Scenario "Progress count includes standard tasks" → unchanged, no implementation needed
- [x] Scenario "Archive warns on unchecked standard tasks" → unchanged, no implementation needed
- [x] Success Metric: committed tasks.md shows all standard tasks as `[x]` → verifiable by inspecting commit
- [x] Success Metric: no extra follow-up commit → verifiable by git log

## B. Gap Analysis

No gaps found. The change is a single instruction text addition. Edge cases are covered:
- Partial workflow failure: agent won't commit if a step fails, so only completed steps get marked.
- Constitution extras (4.5+): explicitly out of scope, remain unchecked.

## C. Side-Effect Analysis

- **No regression risk.** The apply instruction change only adds a directive; existing behavior (apply skips standard tasks, progress counting) is unaffected.
- **Existing archived changes** are unaffected — they already have their tasks.md frozen.
- **In-flight changes** pick up the new instruction on next invocation — no migration needed.

## D. Constitution Check

No constitution update needed. No new patterns, conventions, or architectural rules introduced.

## E. Duplication & Consistency

- No duplication. The marking-before-commit behavior lives solely in `task-implementation` spec and `schema.yaml` apply instruction.
- Consistent with existing `artifact-pipeline` spec scenario "Apply instruction includes post-apply workflow" — that scenario describes the step sequence, this change adds the marking directive without contradicting it.

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers found in the delta spec or design. Nothing to audit.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found. Clean.
