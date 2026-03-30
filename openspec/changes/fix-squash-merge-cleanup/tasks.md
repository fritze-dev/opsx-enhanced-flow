# Implementation Tasks: Fix Squash Merge Cleanup

## 1. Foundation

No foundational tasks — single-file change with no dependencies.

## 2. Implementation

- [ ] 2.1. Update `src/skills/archive/SKILL.md` Step 6 substep 4: replace `git branch -d` with PR merge check logic (`gh pr view <branch> --json state --jq '.state'`; if MERGED use `git branch -D`, otherwise fall back to `git branch -d`)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: Branch deletion succeeds after squash merge — PASS / FAIL
- [ ] 3.2. Metric Check: Branch deletion works for regular merges (no regression) — PASS / FAIL
- [ ] 3.3. Metric Check: Graceful fallback when `gh` is unavailable — PASS / FAIL
- [ ] 3.4. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.6. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.7. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.6 was not entered.
- [ ] 3.8. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. (Post-Merge) Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
