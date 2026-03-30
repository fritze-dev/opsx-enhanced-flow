# Pre-Flight Check: Smart Workflow Checkpoints

## A. Traceability Matrix

- [x] Preflight Quality Check (MODIFIED) — mandatory pause on PASS WITH WARNINGS
  - Scenario: Preflight with warnings requires user acknowledgment → ff skill + continue skill + quality-gates spec
- [x] Step-by-Step Generation (MODIFIED) — auto-continue for routine transitions
  - Scenario: Continue auto-continues through routine transitions → continue skill
  - Scenario: Continue pauses at design review checkpoint → continue skill (existing)
- [x] Fast-Forward Generation (MODIFIED) — mandatory pause on preflight warnings
  - Scenario: Fast-forward pauses on preflight warnings → ff skill
- [x] Verify-before-sync ordering → constitution + apply instruction in schema.yaml

## B. Gap Analysis

No gaps identified. All three sub-problems (#16, #40, #26) are addressed:
- Preflight warnings: mandatory pause added
- Routine transitions: auto-continue defined
- Verify/sync ordering: enforced in constitution + apply instruction

## C. Side-Effect Analysis

- **Continue skill behavior change:** Currently pauses after every artifact. After this change, it auto-continues through routine transitions. Users who relied on the pause-per-artifact behavior may be surprised. However, the design checkpoint and preflight-warnings checkpoint still provide the critical review points.
- **FF skill:** Already flows through most artifacts. Only change is adding a pause on preflight warnings — strictly additive.
- **Apply instruction:** Adding verify-before-sync is additive text. Does not change how apply processes tasks.

## D. Constitution Check

Constitution will be updated as part of this change (checkpoint model + verify-before-sync convention). No contradiction — these are new conventions.

## E. Duplication & Consistency

- The design review checkpoint already exists in constitution (line 39). The new checkpoint model formalizes it alongside the other checkpoints — no duplication, just consolidation.
- The apply instruction in schema.yaml already mentions post-apply order. The update reinforces verify-before-sync explicitly.

## F. Assumption Audit

No assumption markers found in the delta specs or design for this change.

## Verdict

**PASS** — No warnings, no blockers. Ready for task generation.
