# Implementation Tasks: Diff-Based Verification

## 1. Foundation

(No foundation tasks — no new infrastructure or dependencies needed.)

## 2. Implementation

- [ ] 2.1. Update `src/skills/verify/SKILL.md`: Add new **Step 4 "Load Diff"** after step 3 (Load artifacts). Run `git merge-base HEAD main` to find base commit, then `git diff <base>...HEAD --name-only` to get changed file list. If merge-base fails, set a flag to skip all diff checks and note "No merge base available — diff checks skipped". Exclude files under `openspec/changes/` and `openspec/specs/` from unintended change detection.
- [ ] 2.2. Update `src/skills/verify/SKILL.md`: Add **task-diff mapping** sub-check to step 5 (Verify Completeness). For each completed task, keyword-match task description against file paths in the diff. Flag tasks with no matching diff as WARNING. Skip inconclusive matches (generic task descriptions) and note as inconclusive.
- [ ] 2.3. Update `src/skills/verify/SKILL.md`: Add **diff scope check** sub-check to step 7 (Verify Coherence). For each file in the diff, check traceability to tasks or design components. Collect untraced files and report as a single grouped SUGGESTION.
- [ ] 2.4. Update `src/skills/verify/SKILL.md`: Add **Diff Scope** row to the summary scorecard in step 9 (Generate Verification Report). Show count of files checked and untraced files found.
- [ ] 2.5. Renumber existing steps 4-9 to 5-10 in `src/skills/verify/SKILL.md` to accommodate the new step 4.

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Verify detects a completed task with no corresponding diff (task-diff mapping) — PASS / FAIL
  - [ ] Verify flags files in the diff not covered by any task or design component — PASS / FAIL
  - [ ] Verify skips diff checks gracefully when no merge base exists — PASS / FAIL
  - [ ] Verify reports untraced files as a single SUGGESTION, not one per file — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Generate changelog (`/opsx:changelog`)
- [ ] 4.2. Generate/update docs (`/opsx:docs`)
- [ ] 4.3. Bump version
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #83"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
