# Implementation Tasks: Fix Issue Reference in PR Body

## 1. Foundation

No foundational tasks.

## 2. Implementation

- [x] 2.1. Update `openspec/CONSTITUTION.md` pre-merge standard task: add explicit mention of including issue-closing keywords (`Closes #X`) in the PR body when the change originated from a GitHub issue

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Constitution text explicitly mentions issue references in PR body — PASS
- [x] 3.2. Metric Check: Spec scenario covers issue-closing keyword requirement — PASS
- [x] 3.3. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.4. User Testing: Approved by user.
- [x] 3.5. Fix Loop: Skipped — no issues found.
- [x] 3.6. Final Verify: Skipped — 3.5 was not entered.
- [x] 3.7. Approval: Approved by user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs — not needed (no capability doc or README changes)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #X"`)
- [ ] 4.6. (Post-Merge) Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
