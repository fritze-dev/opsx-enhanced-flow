# Implementation Tasks: Fix Stale Worktree Detection

## 1. Foundation

No foundation tasks — this change modifies existing spec and config files only.

## 2. Implementation

- [ ] 2.1. [P] Update `openspec/WORKFLOW.md`: add `stale_days: 14` to worktree config section and update propose instruction text (line 36)
- [ ] 2.2. [P] Update `src/templates/workflow.md`: mirror WORKFLOW.md changes (add `stale_days` comment and update propose instruction)
- [ ] 2.3. Update `docs/capabilities/change-workspace.md`: update "Lazy Worktree Cleanup at Change Creation" description (lines 50-52)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Worktrees with `status: completed` proposals detected via worktree filesystem path — PASS / FAIL
  - [ ] PRs with state `CLOSED` trigger user prompt — PASS / FAIL
  - [ ] Branches inactive beyond `stale_days` trigger user prompt — PASS / FAIL
  - [ ] Existing cleanup behavior unchanged — PASS / FAIL
  - [ ] `auto_approve: true` does not suppress abandoned/inactive prompts — PASS / FAIL
- [ ] 3.2. Auto-Verify: generate review.md using the review template
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix specs/config → re-verify. Specs must match config before proceeding.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #111"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
