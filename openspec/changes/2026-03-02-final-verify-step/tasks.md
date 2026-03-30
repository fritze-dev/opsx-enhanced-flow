# Implementation Tasks: Final Verify Step

## 1. Foundation

No foundation tasks — this is a template + spec change only.

## 2. Implementation

- [x] 2.1. Update `openspec/schemas/opsx-enhanced/templates/tasks.md`: Add step 3.5 "Final Verify" and renumber Approval to 3.6
- [x] 2.2. Merge delta spec into `openspec/specs/human-approval-gate/spec.md`: Add final verify requirement text and 3 scenarios
- [x] 2.3. Merge delta spec into `openspec/specs/quality-gates/spec.md`: Add final verify scenario
- [x] 2.4. Bump version in `.claude-plugin/plugin.json`

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: tasks.md template has 6 QA steps (was 5), step 3.5 is "Final Verify", Approval is 3.6 — PASS.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: Approved by user.
- [x] 3.4. Fix Loop: No issues found — not entered.
- [x] 3.5. Approval: **Approved** by the user.
