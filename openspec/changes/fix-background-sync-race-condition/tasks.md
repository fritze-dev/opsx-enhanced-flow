# Implementation Tasks: Fix Background Sync Race Condition

## 1. Foundation

No foundation tasks — single-file change with no dependencies.

## 2. Implementation

- [x] 2.1. Rewrite the subagent prompt in `src/skills/archive/SKILL.md` step 4 (line 59) to convey that sync is a blocking prerequisite for archive. The prompt must explain that sync writes to `openspec/specs/` and these changes must be included in the archive commit.
- [x] 2.2. Add a state-based validation gate in `src/skills/archive/SKILL.md` step 4 (between current lines 60-61). After the sync agent returns, check that for each delta spec capability at `openspec/changes/<name>/specs/<capability>/`, a corresponding baseline spec exists at `openspec/specs/<capability>/spec.md`. If any are missing, stop and report which capabilities lack baseline specs.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Prompt clarity — subagent prompt explicitly states sync is a blocking prerequisite — PASS
- [x] 3.2. Metric Check: Validation gate — archive skill contains state-based validation (baseline spec existence check) before step 5 — PASS
- [x] 3.3. Metric Check: Failure path — missing baseline spec after sync blocks archive and reports which capabilities are missing — PASS
- [x] 3.4. Auto-Verify: Run `/opsx:verify`
- [x] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.6. Fix Loop: Removed stale "Return full sync output" from prompt (user feedback).
- [x] 3.7. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.6 was not entered.
- [x] 3.8. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)
- [ ] 4.6. *(Post-Merge)* Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
