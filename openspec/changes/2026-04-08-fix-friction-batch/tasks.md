# Implementation Tasks: Fix Friction Batch (#81, #86, #87, #88)

## 1. Foundation

- [x] 1.1. Add "Template synchronization" convention to `openspec/CONSTITUTION.md` — changes to `openspec/WORKFLOW.md` behavior fields (`apply.instruction`, `post_artifact`, `context`) must also be reflected in `src/templates/workflow.md`. Note: `worktree` config may intentionally differ between project and consumer template.
- [x] 1.2. Add the same convention to `src/templates/constitution.md` under `## Conventions` (as a comment example, consistent with existing template style).

## 2. Implementation

- [x] 2.1. [P] Update `openspec/WORKFLOW.md` `apply.instruction`: add automated-step guidance — Metric Check and Auto-Verify are automated steps that run without pausing; the first human gate is User Testing. (#81)
- [x] 2.2. [P] Update `openspec/WORKFLOW.md` `apply.instruction`: add post-merge worktree cleanup sequence — after successful `gh pr merge` from within a worktree: switch to main worktree, `git worktree remove <path>`, `git branch -D <branch>`. (#88)
- [x] 2.3. Mirror changes from 2.1 and 2.2 into `src/templates/workflow.md` `apply.instruction`. (#87 — applying the new convention immediately)
- [x] 2.4. [P] Update `src/skills/verify/SKILL.md`: add auto-fix guidance after the report generation step — mechanically fixable WARNINGs (stale cross-references, inconsistent naming between artifacts) are resolved inline before presenting the report; auto-fixed issues noted as "WARNING (auto-fixed)" in the report. Judgment-required WARNINGs remain as open issues. (#86)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: grep `apply.instruction` in both WORKFLOW.md files for "automated" or "without pausing" (SM-1) — PASS
- [x] 3.2. Metric Check: grep verify SKILL.md for "auto-fix" (SM-2) — PASS
- [x] 3.3. Metric Check: grep CONSTITUTION.md for "Template synchronization" (SM-3) — PASS
- [x] 3.4. Metric Check: grep `apply.instruction` in both WORKFLOW.md files for "worktree remove" (SM-4) — PASS
- [x] 3.5. Auto-Verify: Run `/opsx:verify`
- [x] 3.6. User Testing: Approved by user.
- [x] 3.7. Fix Loop: Removed unnecessary constitution template comment (consumer projects don't have src/templates/).
- [x] 3.8. Final Verify: Run `/opsx:verify` after fix — all checks passed.
- [x] 3.9. Approval: Approved.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs`)
- [x] 4.3. Bump version
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references (`gh pr ready && gh pr edit --body "... Closes #81, #86, #87, #88"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
