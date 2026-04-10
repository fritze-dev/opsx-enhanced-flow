# Implementation Tasks: Auto-Approve as Default

## 1. Foundation

(no foundation tasks — existing field, no new infrastructure)

## 2. Implementation

- [ ] 2.1. [P] Uncomment `auto_approve: true` in `openspec/WORKFLOW.md` (line 15)
- [ ] 2.2. [P] Uncomment `auto_approve: true` in `src/templates/workflow.md` (line 15)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] `auto_approve: true` is uncommented and active in WORKFLOW.md — PASS / FAIL
  - [ ] `auto_approve: true` is uncommented and active in consumer template — PASS / FAIL
  - [ ] Spec language reflects "defaults to true" semantics — PASS / FAIL
  - [ ] WORKFLOW.md and template remain in sync per constitution — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #101"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
