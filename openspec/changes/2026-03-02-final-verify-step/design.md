# Design: Final Verify Step in QA Loop

## Approach

Add step 3.5 "Final Verify" to the tasks.md template between the existing Fix Loop (3.4) and Approval (currently 3.5, becomes 3.6). This is a template-only change — no skill or schema modifications needed.

## Changes

### 1. tasks.md Template

**File:** `openspec/schemas/opsx-enhanced/templates/tasks.md`

Current QA section (lines 12-17):
```
## 3. QA Loop & Human Approval
- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [ ] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.5. Approval: Only finish on explicit **"Approved"** by the user.
```

New QA section:
```
## 3. QA Loop & Human Approval
- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [ ] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.
```

### 2. Spec Updates

**human-approval-gate:** Add requirement text and 3 scenarios for final verify gating approval.

**quality-gates:** Add 1 scenario confirming verify works identically as final checkpoint.

## Success Metrics

| # | Metric | Target |
|---|--------|--------|
| 1 | tasks.md template includes 6 QA steps (was 5) | Step 3.5 exists as "Final Verify" |
| 2 | Approval step is 3.6 (was 3.5) | Renumbering complete |
| 3 | Specs cover final verify scenarios | human-approval-gate + quality-gates updated |

## Architecture Decisions

No architectural changes. The verify skill is stateless and works identically whether invoked as initial or final verify. No new skills, commands, or schema artifacts needed.
