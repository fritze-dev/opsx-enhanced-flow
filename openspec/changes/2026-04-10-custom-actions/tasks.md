# Implementation Tasks: Custom Actions

## 1. Foundation

- [x] 1.1. Update CONSTITUTION.md Architecture Rules line to reflect "4 built-in actions + consumer-defined custom actions" instead of "4 actions"

## 2. Implementation

- [x] 2.1. Update `src/skills/workflow/SKILL.md` Step 1 — replace hardcoded action list with dynamic validation against `actions` array from WORKFLOW.md frontmatter, with fallback to built-in actions if WORKFLOW.md is missing
- [x] 2.2. Update `src/skills/workflow/SKILL.md` Step 5 — add generic fallback block for custom actions: read `## Action: <name>` instruction from WORKFLOW.md, execute directly with change context
- [x] 2.3. Update `src/templates/workflow.md` — add comment in frontmatter explaining custom action usage

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Built-in actions behave identically — PASS
- [x] 3.2. Metric Check: Custom action in `actions` array dispatches correctly — PASS
- [x] 3.3. Metric Check: Action not in array produces error with list — PASS
- [x] 3.4. Metric Check: Missing `## Action:` section produces clear error — PASS
- [x] 3.5. Auto-Verify: generate review.md using the review template.
- [ ] 3.6. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.7. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.8. Final Verify: regenerate review.md after all fixes. Skip if 3.7 was not entered.
- [ ] 3.9. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #33"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
