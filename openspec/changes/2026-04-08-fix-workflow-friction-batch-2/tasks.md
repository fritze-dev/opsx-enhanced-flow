# Implementation Tasks: Fix Workflow Friction Batch 2

## 1. Foundation

(No foundation tasks.)

## 2. Implementation

- [ ] 2.1. Update `openspec/templates/specs/spec.md` instruction: Add guardrail that specs describe behavior (WHAT), not implementation details — no concrete commands, file paths, or API calls. Implementation details belong in SKILL.md or design.md.
- [ ] 2.2. Update `openspec/WORKFLOW.md` apply.instruction: Add fix-loop verify rule — after any fix-loop change (code, specs, or artifacts), re-run `/opsx:verify` before presenting to user. Do not skip step 3.5 (Final Verify).
- [ ] 2.3. Update `openspec/WORKFLOW.md` apply.instruction: Add artifact freshness rule — when a fix resolves an issue flagged in preflight.md or design.md, update the affected artifact to reflect the resolution. Stale verdicts (e.g., "PASS WITH WARNINGS" after the warning is fixed) must not persist.
- [ ] 2.4. Update `openspec/WORKFLOW.md` apply.instruction: Add docs terminology check — before user testing (step 3.3), check that docs/capabilities and docs/README.md do not reference stale terminology from changed specs. `/opsx:docs` in standard tasks handles regeneration, but stale references should be identified early.
- [ ] 2.5. [P] Mirror apply.instruction changes to `src/templates/workflow.md`.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Specs template instruction explicitly prohibits implementation details — PASS / FAIL
  - [ ] Apply.instruction requires verify re-run after fix-loop changes — PASS / FAIL
  - [ ] Apply.instruction requires updating stale artifacts — PASS / FAIL
  - [ ] Apply.instruction includes docs terminology check before user testing — PASS / FAIL
  - [ ] Consumer template mirrors all apply.instruction changes — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Generate changelog (`/opsx:changelog`)
- [ ] 4.2. Generate/update docs (`/opsx:docs`)
- [ ] 4.3. Bump version
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
