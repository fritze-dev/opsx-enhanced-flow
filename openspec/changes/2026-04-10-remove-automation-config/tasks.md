# Implementation Tasks: Remove Automation Config

## 1. Foundation

- [x] 1.1. Remove `automation:` block from `openspec/WORKFLOW.md` frontmatter (lines 17-23)
- [x] 1.2. Remove commented-out `# automation:` block from `src/templates/workflow.md`

## 2. Implementation

- [x] 2.1. [P] Remove `, automation` from frontmatter extraction list in `src/skills/workflow/SKILL.md` (line 22)
- [x] 2.2. [P] Delete `.github/workflows/pipeline.yml`
- [x] 2.3. [P] Remove `and \`automation\`` from template sync convention in `openspec/CONSTITUTION.md` (line 42)
- [x] 2.4. Remove automation feature + behavior sections from `docs/capabilities/workflow-contract.md`
- [x] 2.5. Remove "automation config" from architecture description in `docs/README.md`
- [x] 2.6. Remove CI automation references from `README.md` (3 locations: lines 71, 176, 222)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: grep for `automation` in active source files — zero matches expected (excluding historical changes)
- [x] 3.2. Metric Check: `.github/workflows/pipeline.yml` does not exist
- [x] 3.3. Metric Check: Other CI workflows (`release.yml`, `claude.yml`, `claude-code-review.yml`) still present
- [x] 3.4. Metric Check: workflow-contract spec version bumped to 4
- [x] 3.5. Auto-Verify: generate review.md using the review template
- [ ] 3.6. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.7. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.8. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.7 was not entered.
- [ ] 3.9. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version
- [x] 4.3. Commit and push to remote
- [x] 4.4. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #100"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
