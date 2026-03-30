# Pre-Flight Check: Final Verify Step

## A. Traceability Matrix

| Requirement | Scenarios | Components |
|-------------|-----------|------------|
| QA Loop with Mandatory Approval (MODIFIED) | Final verify after fix loop, Final verify skipped when clean, Final verify finds new issues | templates/tasks.md |
| Post-Implementation Verification (MODIFIED) | Final verify confirms fix loop resolved all issues | templates/tasks.md (indirect — verify skill unchanged) |

All requirements traced to scenarios and components.

## B. Gap Analysis

No gaps detected. The change is additive (one new step, renumbering). Edge case "skip if fix loop not entered" is covered in the spec scenario.

## C. Side-Effect Analysis

- **Existing archived changes:** Unaffected — they keep their old 5-step QA loop.
- **In-progress changes:** If a change is currently in the QA loop, the old template applies (already written to tasks.md). No migration needed.
- **Verify skill:** Unchanged — it's stateless.
- **Apply skill:** Unchanged — it reads tasks.md checkboxes regardless of numbering.
- **Archive skill:** Unchanged — checks for incomplete tasks generically.

No regressions expected.

## D. Constitution Check

- No new technology introduced.
- No architecture rule changes.
- Template change is within Schema layer (correct layer for this concern).
- README may need a minor update if QA loop is described there.

Checked README lines 137-146 (Definition of Done table) — mentions "QA Loop" but not specific step numbers. No update needed.

## E. Duplication & Consistency

- The "re-verify" text in step 3.4 ("→ re-verify") and the new step 3.5 ("Run `/opsx:verify`") are complementary, not redundant. 3.4 describes iterative re-verification during fixes; 3.5 is the final gate.
- No contradictions detected across specs.

## F. Assumption Audit

No new assumptions introduced. Existing assumptions about verify's stateless behavior and checkbox format remain valid.

## Verdict: PASS

0 blockers, 0 warnings. Ready for task generation.
