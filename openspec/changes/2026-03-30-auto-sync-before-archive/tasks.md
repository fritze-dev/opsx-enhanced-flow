# Implementation Tasks: Auto-Sync Before Archive

## 1. Foundation

No foundation tasks — this change modifies existing files only.

## 2. Implementation

- [x] 2.1. Update `src/skills/archive/SKILL.md` Step 4: Replace sync prompt with automatic sync. Remove AskUserQuestion usage for sync choice. Keep delta spec analysis and summary display. Update guardrails section to match.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] `/opsx:archive` with delta specs completes without sync/archive prompt — PASS
  - [x] Delta specs are synced to baseline automatically — PASS
  - [x] Sync summary is displayed to the user — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify`
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Skipped — no issues found.
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered.
- [x] 3.6. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
