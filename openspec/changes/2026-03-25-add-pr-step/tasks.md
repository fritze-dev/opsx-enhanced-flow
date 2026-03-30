# Implementation Tasks: Add PR Step to Workflow

## 1. Foundation
<!-- No foundation tasks needed — all changes are to existing files -->

## 2. Implementation

- [x] 2.1. Add `## Pull Request` section to `openspec/schemas/opsx-enhanced/templates/proposal.md`
- [x] 2.2. Append PR creation steps to proposal `instruction` in `openspec/schemas/opsx-enhanced/schema.yaml` (branch, commit, push, draft PR, record URL in proposal.md, graceful degradation)
- [x] 2.3. Update `apply.instruction` in `openspec/schemas/opsx-enhanced/schema.yaml` to include "execute constitution standard tasks" in post-apply sequence
- [x] 2.4. Add PR update standard task to `## Standard Tasks` in `openspec/constitution.md`

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)
- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [ ] 4.5. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
