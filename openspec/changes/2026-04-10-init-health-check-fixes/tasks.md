# Implementation Tasks: Init Health Check Fixes

## 1. Implementation

- [x] 1.1. [P] Fix spec drift: `openspec/specs/three-layer-architecture/spec.md` — already done during specs stage (verify "7-stage" and "review" present)
- [x] 1.2. [P] Upstream `tasks.md` template: copy expanded instruction + body from `openspec/templates/tasks.md` to `src/templates/tasks.md`, bump `template-version` to `2`
- [x] 1.3. [P] Upstream `specs/spec.md` template: copy implementation-detail prohibition paragraph from `openspec/templates/specs/spec.md` to `src/templates/specs/spec.md`, bump `template-version` to `2`
- [x] 1.4. [P] Sync WORKFLOW.md comments: add the 2 custom action hint comment lines after `actions:` in `openspec/WORKFLOW.md`

## 2. QA Loop & Human Approval
- [x] 2.1. Metric Check: `three-layer-architecture/spec.md` says "7-stage" and lists 7 IDs including "review" — PASS
- [x] 2.2. Metric Check: `src/templates/tasks.md` matches `openspec/templates/tasks.md` content with `template-version: 2` — PASS
- [x] 2.3. Metric Check: `src/templates/specs/spec.md` matches `openspec/templates/specs/spec.md` content with `template-version: 2` — PASS
- [x] 2.4. Metric Check: `openspec/WORKFLOW.md` contains custom action hint comments after `actions:` — PASS
- [x] 2.5. Auto-Verify: generate review.md using the review template.
- [x] 2.6. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 2.7. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [x] 2.8. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 2.7 was not entered.
- [x] 2.9. Approval: Only finish on explicit **"Approved"** by the user.

## 3. Standard Tasks (Post-Implementation)
- [x] 3.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 3.2. Bump version
- [x] 3.3. Commit and push to remote
- [x] 3.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)

## 4. Post-Merge Reminders
- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
