# Implementation Tasks: Tool-Agnostic GitHub Operations

## 1. Foundation

(No foundation tasks — this is a text-only change across existing files.)

## 2. Implementation

- [ ] 2.1. [P] Update `src/skills/workflow/SKILL.md` line 105: replace `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"` with intent-based instruction "Create a draft PR titled `<Change Name>` with body `WIP: <change-name>`". Update "Skip PR creation if `gh` unavailable" to "Skip if no GitHub tooling is available."
- [ ] 2.2. [P] Update `openspec/CONSTITUTION.md` line 58: replace `gh pr ready && gh pr edit --body "... Closes #X"` with "Mark PR as ready for review, update body with change summary and issue references if applicable (e.g., `Closes #X`)"
- [ ] 2.3. [P] Update `README.md` lines 299-309: rewrite "Optional: `gh` CLI for full GitHub integration" section. State that Claude Code Web has built-in GitHub MCP tools. Describe `gh` CLI as optional alternative for environments without MCP tools.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Run `grep -r "gh pr\|gh issue\|gh api" src/ openspec/specs/ openspec/CONSTITUTION.md` — expect zero hits. PASS / FAIL.
- [ ] 3.2. Metric Check: Verify all modified scenarios describe identical behavior (same outcomes). PASS / FAIL.
- [ ] 3.3. Metric Check: Verify README documents MCP tools as primary, `gh` CLI as optional. PASS / FAIL.
- [ ] 3.4. Auto-Verify: generate review.md using the review template.
- [ ] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.6. Fix Loop: On verify issues or bug reports → fix text → re-verify.
- [ ] 3.7. Final Verify: regenerate review.md after all fixes to confirm consistency. Skip if 3.6 was not entered.
- [ ] 3.8. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
