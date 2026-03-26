# Implementation Tasks: Verify Preflight Side-Effect Cross-Check

## 1. Foundation

No foundation tasks — no new dependencies or shared infrastructure needed.

## 2. Implementation

- [ ] 2.1. Update `skills/verify/SKILL.md` step 3 (Load artifacts): add `preflight.md` to the artifact read list
- [ ] 2.2. Add new step 8 "Verify Preflight Side-Effects" to `skills/verify/SKILL.md` between current step 7 (Coherence) and step 8 (Report): parse Section C, extract side-effects, cross-check against tasks.md and codebase keywords, emit WARNING for unmatched entries
- [ ] 2.3. Update step 9 (formerly step 8) "Generate Verification Report" in `skills/verify/SKILL.md`: add side-effect findings to the summary scorecard and issue lists

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Verify reads `preflight.md` and extracts side-effects from Section C — PASS / FAIL
  - [ ] Unaddressed side-effects produce WARNING issues in the report — PASS / FAIL
  - [ ] Side-effects matched by task or code evidence produce no issue — PASS / FAIL
  - [ ] Empty/NONE Section C entries are skipped without false warnings — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
