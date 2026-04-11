# Implementation Tasks: SessionStart Hook Fallback

## 1. Implementation

- [x] 1.1. Add `hooks.SessionStart` entry to `.claude/settings.json` with `claude plugin install opsx@opsx-enhanced-flow 2>/dev/null || true` and `matcher: "startup"`

## 2. QA Loop & Human Approval
- [x] 2.1. Metric Check: `.claude/settings.json` is valid JSON — PASS
- [x] 2.2. Metric Check: Existing declarative fields preserved — PASS
- [x] 2.3. Metric Check: Plugin auto-installs in Claude Code Web session — deferred (manual test after merge)
- [x] 2.4. Auto-Verify: generate review.md using the review template
- [x] 2.5. User Testing: Approved by user.
- [x] 2.6. Fix Loop: Not entered.
- [x] 2.7. Final Verify: Skipped (no fixes needed).
- [x] 2.8. Approval: Approved.

## 3. Standard Tasks (Post-Implementation)
- [x] 3.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 3.2. Bump version
- [x] 3.3. Commit and push to remote
- [x] 3.4. N/A — pushed directly to main (no PR needed for config-only fix)

## 4. Post-Merge Reminders
- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
