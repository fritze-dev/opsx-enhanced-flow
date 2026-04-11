# Implementation Tasks: Tool-Agnostic GitHub Operations

## 1. Foundation

(No foundation tasks — this is a text-only change across existing files.)

## 2. Implementation

- [x] 2.1. [P] Update `src/skills/workflow/SKILL.md` line 105: replace `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"` with intent-based instruction "Create a draft PR titled `<Change Name>` with body `WIP: <change-name>`". Update "Skip PR creation if `gh` unavailable" to "Skip if no GitHub tooling is available."
- [x] 2.2. [P] Update `openspec/CONSTITUTION.md` line 58: replace `gh pr ready && gh pr edit --body "... Closes #X"` with "Mark PR as ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)"
- [x] 2.3. [P] Update `README.md` lines 299-309: rewrite "Optional: `gh` CLI for full GitHub integration" section. State that Claude Code Web has built-in GitHub MCP tools. Describe `gh` CLI as optional alternative for environments without MCP tools.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Run `grep -r "gh pr\|gh issue\|gh api" src/ openspec/specs/ openspec/CONSTITUTION.md` — in-scope files clean. Remaining hits in task-implementation and project-init specs (out of scope). PASS.
- [x] 3.2. Metric Check: Verify all modified scenarios describe identical behavior (same outcomes). PASS.
- [x] 3.3. Metric Check: Verify README documents MCP tools as primary, `gh` CLI as optional. PASS.
- [x] 3.4. Auto-Verify: generate review.md using the review template.
- [x] 3.5. User Testing: auto_approve=true, skipped.
- [ ] 3.6. Fix Loop: On verify issues or bug reports → fix text → re-verify.
- [ ] 3.7. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.6 was not entered.
- [x] 3.8. Approval: auto_approve=true.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [x] 4.2. Bump version (2.0.10 → 2.0.11)
- [x] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
