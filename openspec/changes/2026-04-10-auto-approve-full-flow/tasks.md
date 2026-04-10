# Implementation Tasks: Auto-Approve Full Flow

## 1. Foundation

- [ ] 1.1. Update `openspec/WORKFLOW.md` propose instruction: add auto_approve condition to skip design checkpoint and auto-continue to apply
- [ ] 1.2. Update `openspec/WORKFLOW.md` apply instruction: add auto_approve condition to skip user testing pause when review.md PASS

## 2. Implementation

- [ ] 2.1. [P] Update `src/skills/workflow/SKILL.md` Step 5 propose dispatch: after propose completes, if auto_approve is true, auto-dispatch apply
- [ ] 2.2. [P] Update `src/skills/workflow/SKILL.md` Step 5 apply dispatch: after apply sub-agent returns with PASS, if auto_approve is true, auto-dispatch finalize
- [ ] 2.3. [P] Update `openspec/CONSTITUTION.md` design checkpoint convention to respect auto_approve
- [ ] 2.4. Sync `src/templates/workflow.md` with updated WORKFLOW.md instructions
- [ ] 2.5. Update `docs/capabilities/workflow-contract.md` auto-approve feature + behavior sections
- [ ] 2.6. Update `docs/capabilities/human-approval-gate.md` to mention auto_approve bypass

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: WORKFLOW.md propose instruction contains auto_approve design checkpoint skip
- [ ] 3.2. Metric Check: WORKFLOW.md apply instruction contains auto_approve user testing skip
- [ ] 3.3. Metric Check: SKILL.md has auto-dispatch logic for propose→apply and apply→finalize
- [ ] 3.4. Metric Check: CONSTITUTION.md design checkpoint convention respects auto_approve
- [ ] 3.5. Metric Check: Consumer template synced with WORKFLOW.md
- [ ] 3.6. Metric Check: FAIL/BLOCKED paths still stop (verify instruction text)
- [ ] 3.7. Auto-Verify: generate review.md
- [ ] 3.8. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.9. Fix Loop: On verify issues → fix → re-verify.
- [ ] 3.10. Final Verify: regenerate review.md after fixes. Skip if 3.9 not entered.
- [ ] 3.11. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #105"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
