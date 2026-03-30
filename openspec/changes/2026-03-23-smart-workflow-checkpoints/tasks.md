# Implementation Tasks: Smart Workflow Checkpoints

## 1. Foundation

- [x] 1.1. Add checkpoint model and verify-before-sync convention to `openspec/constitution.md`. Replace the existing "Design review checkpoint" convention (line 39) with a comprehensive checkpoint model section that defines: (a) mandatory-pause transitions: design review, preflight PASS WITH WARNINGS, discovery Q&A; (b) auto-continue transitions: research→proposal, proposal→specs, specs→design, preflight(PASS)→tasks; (c) verify-before-sync rule: `/opsx:verify` must run before `/opsx:sync` or `/opsx:archive`.

## 2. Implementation

- [x] 2.1. [P] Update `openspec/schemas/opsx-enhanced/schema.yaml` apply instruction (lines 194-198) to explicitly state verify-before-sync ordering: `/opsx:verify` → `/opsx:archive` (which includes sync). Clarify that sync must not run before verify.
- [x] 2.2. [P] Update `skills/continue/SKILL.md` to add auto-continue behavior. After step 3 "STOP after creating ONE artifact" logic, add: at routine transitions (research→proposal, proposal→specs, specs→design, preflight(PASS)→tasks), immediately proceed to generate the next artifact without pausing. At mandatory-pause checkpoints (after design, after preflight with warnings), stop and wait for user input. This changes the "Create ONE artifact per invocation" guardrail to "Create artifacts until a mandatory-pause checkpoint or pipeline end is reached."
- [x] 2.3. [P] Update `skills/ff/SKILL.md` to add mandatory pause on preflight warnings. After generating preflight, check the verdict. If PASS WITH WARNINGS: pause, present each warning, and require explicit user acknowledgment before generating tasks. If PASS: auto-continue to tasks. If BLOCKED: stop (already handled by artifact dependency).

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Constitution contains checkpoint model — PASS / FAIL. Continue skill has auto-continue behavior — PASS / FAIL. FF skill pauses on preflight warnings — PASS / FAIL. Apply instruction enforces verify-before-sync — PASS / FAIL.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.
