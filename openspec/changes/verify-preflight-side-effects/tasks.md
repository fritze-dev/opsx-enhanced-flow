# Implementation Tasks: Verify Preflight Side-Effect Cross-Check

## 1. Foundation

No foundation tasks — no new dependencies or shared infrastructure needed.

## 2. Implementation

- [x] 2.1. Update `skills/verify/SKILL.md` step 3 (Load artifacts): add `preflight.md` to the artifact read list
- [x] 2.2. Add new step 8 "Verify Preflight Side-Effects" to `skills/verify/SKILL.md` between current step 7 (Coherence) and step 8 (Report): parse Section C, extract side-effects, cross-check against tasks.md and codebase keywords, emit WARNING for unmatched entries
- [x] 2.3. Update step 9 (formerly step 8) "Generate Verification Report" in `skills/verify/SKILL.md`: add side-effect findings to the summary scorecard and issue lists

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Verify reads `preflight.md` and extracts side-effects from Section C — PASS
  - [x] Unaddressed side-effects produce WARNING issues in the report — PASS
  - [x] Side-effects matched by task or code evidence produce no issue — PASS
  - [x] Empty/NONE Section C entries are skipped without false warnings — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: No issues found — skipped.
- [x] 3.5. Final Verify: Skipped (3.4 was not entered).
- [x] 3.6. Approval: Approved by user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
