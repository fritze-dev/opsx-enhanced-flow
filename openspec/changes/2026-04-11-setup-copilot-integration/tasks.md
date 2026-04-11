# Implementation Tasks: GitHub Copilot Coding Agent Setup

## 1. Foundation

- [ ] 1.1. Create `.github/skills/workflow/` directory

## 2. Implementation

- [ ] 2.1. [P] Create `.github/copilot-instructions.md` with curated project instructions derived from CONSTITUTION.md (three-layer architecture, workflow rules, coding conventions, commit format)
- [ ] 2.2. [P] Create `.github/copilot-setup-steps.yml` with minimal setup (checkout only, no external dependencies)
- [ ] 2.3. [P] Create `.github/skills/workflow/SKILL.md` as symlink to `../../../src/skills/workflow/SKILL.md`
- [ ] 2.4. Add sync convention to `openspec/CONSTITUTION.md` Conventions section for keeping `copilot-instructions.md` aligned with project rules

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [ ] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports -> fix code OR update specs/design -> re-verify. Specs must match code before proceeding.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references (Closes #15)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
