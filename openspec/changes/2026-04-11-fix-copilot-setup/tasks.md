# Implementation Tasks: Agent Skills + AGENTS.md Standards

## 1. Foundation

- [x] 1.1. Create `.agents/skills/workflow/` directory

## 2. Implementation

- [x] 2.1. Rewrite `src/skills/workflow/SKILL.md` — tool-agnostic body, Agent Skills Standard frontmatter
- [x] 2.2. [P] Create `.agents/skills/workflow/SKILL.md` as symlink → `../../../src/skills/workflow/SKILL.md`
- [x] 2.3. [P] Create `AGENTS.md` with agnostic project instructions
- [x] 2.4. Replace `CLAUDE.md` with symlink → `AGENTS.md`
- [x] 2.5. [P] Update `src/templates/claude.md` — agnostic template body and instruction
- [x] 2.6. [P] Update `.github/copilot-setup-steps.yml` — add issues/PR permissions
- [x] 2.7. [P] Delete `.github/copilot-instructions.md`
- [x] 2.8. [P] Delete `.github/skills/workflow/` directory
- [x] 2.9. Update `openspec/CONSTITUTION.md` — Agent Skills + AGENTS.md conventions, remove old Copilot-sync convention

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [x] 3.2. Auto-Verify: generate review.md using the review template.
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports -> fix code OR update specs/design -> re-verify.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run workflow skill with `finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
