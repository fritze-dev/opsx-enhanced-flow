# Implementation Tasks: Diff-Based Verification

## 1. Foundation

(No foundation tasks — no new infrastructure or dependencies needed.)

## 2. Implementation

- [x] 2.1. Restructure `src/skills/verify/SKILL.md`: Simplify from 10 steps to 6 steps. Merge Load artifacts + Load Diff → step 3 "Load context". Merge Completeness + Correctness → step 4 "Verify Implementation". Merge Coherence + Side-Effects → step 5 "Verify Scope". Two-dimension scorecard (Implementation + Scope).
- [x] 2.2. Update `src/skills/verify/SKILL.md` step 3: Load full diff content (`git diff <base>...HEAD`) alongside file list (`--name-only`). Both stored for subsequent steps. Graceful skip when no merge base. Exclude `openspec/changes/` and `openspec/specs/` from scope checks.
- [x] 2.3. Update `src/skills/verify/SKILL.md` step 4 "Verify Implementation": Task-diff mapping matches against file paths AND diff content (content must relate to task, not just file-level match). Requirement verification uses diff content as primary evidence, codebase search as fallback. Checks existence and correctness in one pass. Scenario coverage checks diff content and codebase.
- [x] 2.4. Update `src/skills/verify/SKILL.md` step 5 "Verify Scope": Design adherence verified against diff evidence. Diff scope check for file traceability (grouped SUGGESTION for untraced files). Side-effect cross-check uses diff content + codebase. Code pattern consistency reviews diff content.
- [x] 2.5. Update `openspec/specs/quality-gates/spec.md`: Updated Post-Implementation Verification requirement to two dimensions (Implementation + Scope), diff content as primary evidence, updated scenario terminology.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Verify uses diff content to assess whether changes match requirement intent — PASS (step 4 Requirement Verification uses diff as primary evidence)
  - [x] Verify detects a completed task with no corresponding diff evidence — PASS (step 4 Task-Diff Mapping checks file paths AND content)
  - [x] Verify flags files in the diff not covered by any task or design component — PASS (step 5 Diff Scope Check, single grouped SUGGESTION)
  - [x] Verify skips diff checks gracefully when no merge base exists — PASS (step 3 sets skip flag, graceful degradation section)
  - [x] Verify reports untraced files as a single SUGGESTION, not one per file — PASS (step 5 explicitly groups)
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (passed — 0 critical, 0 warnings, 0 suggestions)
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Fixed sub-dimension labels (Completeness+Correctness, Coherence+Side-Effects), updated stale preflight verdict.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes — passed (0 critical, 0 warnings, 0 suggestions).
- [x] 3.6. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs`)
- [x] 4.3. Bump version (1.0.42 → 1.0.43)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #83"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
