# Implementation Tasks: Fix Stale Worktree Detection

## 1. Foundation

No foundation tasks — this change modifies existing spec and config files only.

## 2. Implementation

- [x] 2.1. [P] Update `openspec/WORKFLOW.md`: add `stale_days: 14` to worktree config section and update propose instruction text (line 36)
- [x] 2.2. [P] Update `src/templates/workflow.md`: mirror WORKFLOW.md changes (add `stale_days` comment and update propose instruction)
- [x] 2.3. Update `docs/capabilities/change-workspace.md`: update "Lazy Worktree Cleanup at Change Creation" description (lines 50-52)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Worktrees with `status: completed` proposals detected via worktree filesystem path — PASS
  - [x] PRs with state `CLOSED` trigger user prompt — PASS
  - [x] Branches inactive beyond `stale_days` trigger user prompt — PASS
  - [x] Existing cleanup behavior unchanged — PASS
  - [x] `auto_approve: true` does not suppress abandoned/inactive prompts — PASS
- [x] 3.2. Auto-Verify: generate review.md using the review template
- [x] 3.3. User Testing: auto_approve — skipped
- [x] 3.4. Fix Loop: not entered (no issues found)
- [x] 3.5. Final Verify: skipped (3.4 not entered)
- [x] 3.6. Approval: auto_approve — auto-continued

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version (2.0.8 → 2.0.9)
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
