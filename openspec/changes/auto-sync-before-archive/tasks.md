# Implementation Tasks: Auto-Sync Before Archive

## 1. Foundation

No foundation tasks — this change modifies existing files only.

## 2. Implementation

- [ ] 2.1. Update `src/skills/archive/SKILL.md` Step 4: Replace sync prompt with automatic sync. Remove AskUserQuestion usage for sync choice. Keep delta spec analysis and summary display. Update guardrails section to match.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] `/opsx:archive` with delta specs completes without sync/archive prompt — PASS / FAIL
  - [ ] Delta specs are synced to baseline automatically — PASS / FAIL
  - [ ] Sync summary is displayed to the user — PASS / FAIL
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
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
