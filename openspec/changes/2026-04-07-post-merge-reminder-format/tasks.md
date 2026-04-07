# Implementation Tasks: Post-Merge Reminder Format

## 1. Foundation

No foundation tasks.

## 2. Implementation

- [ ] 2.1. Update `openspec/CONSTITUTION.md`: change Post-Merge items from `- [ ]` to `- ` (plain bullet)
- [ ] 2.2. Update `openspec/specs/task-implementation/spec.md`: rewrite post-merge references from "remain unchecked / remain as `- [ ]`" to "use plain bullet format (no checkbox)"
- [ ] 2.3. Update `openspec/templates/tasks.md`: add clarification in instruction that post-merge constitution items use plain bullet format

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: grep constitution for post-merge checkboxes; grep spec for "remain unchecked" — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix → re-verify.
- [ ] 3.5. Final Verify: Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Generate changelog (`/opsx:changelog`)
- [ ] 4.2. Generate/update docs (`/opsx:docs task-implementation`)
- [ ] 4.3. Bump version
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "..."`)
- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
