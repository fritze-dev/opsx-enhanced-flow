# Implementation Tasks: Auto-Test Generation

## 1. Foundation

- [ ] 1.1. Create `openspec/templates/tests.md` Smart Template with id, requires, generates, instruction, and template body
- [ ] 1.2. Sync `src/templates/tests.md` (consumer copy of tests template)

## 2. Implementation

- [ ] 2.1. [P] Update `openspec/WORKFLOW.md`: add `tests` to pipeline array, bump template-version from 3 to 4, update body text flow
- [ ] 2.2. [P] Update `src/templates/workflow.md`: sync pipeline array and template-version
- [ ] 2.3. [P] Update `openspec/templates/tasks.md`: change requires from `[preflight]` to `[tests]`, update instruction to reference generated tests, bump template-version from 1 to 2
- [ ] 2.4. [P] Sync `src/templates/tasks.md` (consumer copy)
- [ ] 2.5. [P] Update `openspec/templates/review.md`: add 8th verification dimension (test coverage), bump template-version from 1 to 2
- [ ] 2.6. [P] Sync `src/templates/review.md` (consumer copy)
- [ ] 2.7. [P] Update `openspec/templates/constitution.md`: add `## Testing` section after Tech Stack
- [ ] 2.8. [P] Sync `src/templates/constitution.md` (consumer copy)
- [ ] 2.9. Update `openspec/CONSTITUTION.md`: add `## Testing` section (Framework: None)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Pipeline integrity: WORKFLOW.md pipeline array contains `tests` between `preflight` and `tasks` — PASS/FAIL
  - [ ] Dependency chain: tasks.md Smart Template `requires` field is `[tests]` — PASS/FAIL
  - [ ] Template completeness: `openspec/templates/tests.md` exists with valid frontmatter — PASS/FAIL
  - [ ] Template sync: All openspec/templates/ changes mirrored in src/templates/ — PASS/FAIL
  - [ ] Review dimension: review.md instruction includes test coverage as 8th dimension — PASS/FAIL
  - [ ] Constitution section: Constitution template includes `## Testing` section — PASS/FAIL
  - [ ] No router changes: `src/skills/workflow/SKILL.md` is unchanged — PASS/FAIL
- [ ] 3.2. Auto-Verify: generate review.md using the review template
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #34"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
