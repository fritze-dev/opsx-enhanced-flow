# Implementation Tasks: Fix Stale Spec References

## 1. Foundation

No foundation tasks — all changes are spec text edits.

## 2. Implementation

### config.yaml → WORKFLOW.md (Gap 1 + Gap 5)

- [x] 2.1. [P] Fix `decision-docs/spec.md`: replace 2x `openspec/config.yaml` → `openspec/WORKFLOW.md` (lines 134, 139)
- [x] 2.2. [P] Fix `user-docs/spec.md`: replace 5x `openspec/config.yaml` → `openspec/WORKFLOW.md` (lines 195, 206, 214, 230, 236)
- [x] 2.3. [P] Fix `release-workflow/spec.md`: replace 3x `openspec/config.yaml` → `openspec/WORKFLOW.md` (lines 181, 186, 194)
- [x] 2.4. [P] Fix `architecture-docs/spec.md`: replace 2x `openspec/config.yaml` → `openspec/WORKFLOW.md` (lines 136, 141)
- [x] 2.5. Fix `constitution-management/spec.md`: rewrite 4x config.yaml references (lines 69, 74, 85, 183) — semantic rewrite to WORKFLOW.md context field
- [x] 2.6. Fix `interactive-discovery/spec.md`: replace config.yaml + schema.yaml prerequisite check with WORKFLOW.md + templates/ (lines 13, 84)

### openspec/schemas/ → openspec/templates/ (Gap 2)

- [x] 2.7. [P] Fix `decision-docs/spec.md`: replace 1x template path (line 173)
- [x] 2.8. [P] Fix `user-docs/spec.md`: replace 3x template paths (lines 12, 108, 265)
- [x] 2.9. [P] Fix `architecture-docs/spec.md`: replace 3x template paths (lines 21, 94, 166)
- [x] 2.10. Fix `constitution-management/spec.md`: replace 5x schema/template paths (lines 12, 17, 23, 125, 186)

### openspec/constitution.md → CONSTITUTION.md (Gap 3)

- [x] 2.11. [P] Fix `constitution-management/spec.md`: replace 11x lowercase constitution path (lines 20, 34, 42, 74, 84, 90, 98, 114, 124, 160, 182)
- [x] 2.12. [P] Fix `architecture-docs/spec.md`: replace 5x lowercase constitution path (lines 12, 27, 36, 89, 165)
- [x] 2.13. [P] Fix `project-bootstrap/spec.md`: replace 3x lowercase constitution path (lines 17, 34, 86)
- [x] 2.14. [P] Fix `release-workflow/spec.md`: replace 1x lowercase constitution path (line 91)

### schema.yaml → WORKFLOW.md (Gap 7)

- [x] 2.15. [P] Fix `constitution-management/spec.md`: replace 1x schema.yaml reference (line 125)
- [x] 2.16. [P] Fix `task-implementation/spec.md`: replace 1x schema.yaml reference (line 22)

### plugin.json path (Gap 8)

- [x] 2.17. Fix `release-workflow/spec.md`: replace 3x `.claude-plugin/plugin.json` → `src/.claude-plugin/plugin.json` in auto-bump requirement (lines 13, 19, 29)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Run grep verification for each success metric from design.md — PASS / FAIL.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs`)
- [x] 4.3. Bump version
- [x] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #79"`)
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
