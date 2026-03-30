# Implementation Tasks: Fix Archive Unstaged Deletions

## 1. Foundation

No foundation tasks — single-line change with no dependencies.

## 2. Implementation

- [ ] 2.1. Add `git add openspec/changes/<name>/` after the `mv` command in `src/skills/archive/SKILL.md` step 5 to stage the old path deletions.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: After archive commit, `git status` shows no unstaged changes for the old change directory — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)
- [ ] 4.6. *(Post-Merge)* Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
