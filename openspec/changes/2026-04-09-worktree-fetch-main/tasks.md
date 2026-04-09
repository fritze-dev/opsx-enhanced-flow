# Implementation Tasks: Worktree Fetch Latest Main

## 1. Foundation

No foundation tasks — no new dependencies or infrastructure needed.

## 2. Implementation

- [x] 2.1. Update `src/skills/new/SKILL.md` step 4.3: add `git fetch origin main` before worktree creation, use `origin/main` as start-point

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Worktree based on `origin/main` after fetch — PASS.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — PASSED, no issues
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Skipped — no issues found.
- [x] 3.5. Final Verify: Skipped — fix loop was not entered.
- [x] 3.6. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs`)
- [x] 4.3. Bump version (1.0.46 → 1.0.47)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #95"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
