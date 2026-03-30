# Implementation Tasks: Bootstrap Standard Tasks Section

## 1. Foundation

(No foundational setup needed — this is a text-only change.)

## 2. Implementation

- [x] 2.1. Add `## Standard Tasks` section to the constitution template in `skills/bootstrap/SKILL.md` Step 2 (after `## Conventions`)
- [x] 2.2. Update `openspec/specs/constitution-management/spec.md` — add Standard Tasks to the retained sections list in the "Constitution Contains Only Project-Specific Rules" requirement and its scenarios

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: SKILL.md template includes `## Standard Tasks` with HTML comment — PASS
- [x] 3.2. Metric Check: constitution-management spec lists Standard Tasks as retained section — PASS
- [x] 3.3. Metric Check: Standard Tasks section contains only an HTML comment (no invented content) — PASS
- [x] 3.4. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.6. Fix Loop: No issues found — skipped.
- [x] 3.7. Final Verify: Skipped (3.6 not entered).
- [x] 3.8. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)
<!-- Universal post-implementation steps. Always include this section.
     If the constitution defines ## Standard Tasks, append those items after these. -->
- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [ ] 4.5. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
