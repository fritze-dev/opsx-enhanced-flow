# Implementation Tasks: Commit Before Approval

## 1. Foundation

- [x] 1.1. Add commit+push instruction to `openspec/WORKFLOW.md` `apply.instruction`: after `/opsx:verify` passes, commit and push implementation changes before pausing for user approval

## 2. Implementation

(no additional implementation tasks — the spec updates were completed during the specs stage)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] WORKFLOW.md apply.instruction includes commit+push after verify, before user approval — PASS
  - [x] artifact-pipeline spec references apply.instruction for commit behavior — PASS
  - [x] human-approval-gate spec uses semantic step names instead of numbers — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs`)
- [x] 4.3. Bump version
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #82"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
