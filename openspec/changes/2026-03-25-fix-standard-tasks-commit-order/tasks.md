# Implementation Tasks: Fix Standard Tasks Commit Order

## 1. Foundation

(No foundational setup needed — this is a text-only change.)

## 2. Implementation

- [x] 2.1. Update `apply.instruction` in `openspec/schemas/opsx-enhanced/schema.yaml` to add directive: before committing, ensure all standard task checkboxes (including the commit step) are marked complete in tasks.md
- [x] 2.2. Update `openspec/specs/task-implementation/spec.md` via delta spec merge — the new scenario "Standard tasks marked before commit" and updated normative description will be applied by `/opsx:sync`

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: Committed tasks.md shows all standard tasks (4.1-4.4) as `- [x]` — will be PASS (instruction now requires it)
- [x] 3.2. Metric Check: No extra follow-up commit needed for standard task checkboxes — will be PASS (instruction now requires it)
- [x] 3.3. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.4. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.5. Fix Loop: No issues found — skipped.
- [x] 3.6. Final Verify: Skipped (3.5 not entered).
- [x] 3.7. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)
<!-- Universal post-implementation steps. Always include this section.
     If the constitution defines ## Standard Tasks, append those items after these. -->
- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [ ] 4.5. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
