# Implementation Tasks: Commit Before Approval

## 1. Foundation

- [ ] 1.1. Update the QA Loop section in `openspec/templates/tasks.md`: add step 3.3 "Commit and push implementation changes for review" and renumber subsequent steps (3.3→3.4, 3.4→3.5, 3.5→3.6, 3.6→3.7)

## 2. Implementation

(no additional implementation tasks — the spec updates were completed during the specs stage)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Generated tasks.md files include "Commit and push implementation changes for review" step in QA Loop — PASS / FAIL
  - [ ] Step numbering in QA Loop is consistent (3.1 through 3.7) — PASS / FAIL
  - [ ] human-approval-gate spec uses semantic step names instead of numbers — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. Commit and push implementation changes for review.
- [ ] 3.4. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.5. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [ ] 3.6. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.5 was not entered.
- [ ] 3.7. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Generate changelog (`/opsx:changelog`)
- [ ] 4.2. Generate/update docs (`/opsx:docs`)
- [ ] 4.3. Bump version
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #82"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
