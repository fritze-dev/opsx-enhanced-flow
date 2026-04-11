# Implementation Tasks: SessionStart Hook Fallback

## 1. Implementation

- [ ] 1.1. Add `hooks.SessionStart` entry to `.claude/settings.json` with `claude plugin install opsx@opsx-enhanced-flow 2>/dev/null || true` and `matcher: "startup"`

## 2. QA Loop & Human Approval
- [ ] 2.1. Metric Check: `.claude/settings.json` is valid JSON — PASS / FAIL
- [ ] 2.2. Metric Check: Existing declarative fields preserved — PASS / FAIL
- [ ] 2.3. Metric Check: Plugin auto-installs in Claude Code Web session — PASS / FAIL (manual, deferred)
- [ ] 2.4. Auto-Verify: generate review.md using the review template
- [ ] 2.5. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 2.6. Fix Loop: On verify issues or bug reports → fix → re-verify.
- [ ] 2.7. Final Verify: regenerate review.md after all fixes. Skip if 2.6 was not entered.
- [ ] 2.8. Approval: Only finish on explicit **"Approved"** by the user.

## 3. Standard Tasks (Post-Implementation)
- [ ] 3.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 3.2. Bump version
- [ ] 3.3. Commit and push to remote
- [ ] 3.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #112"`)

## 4. Post-Merge Reminders
- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
