# Implementation Tasks: Fix Workflow Friction Batch 2

## 1. Foundation

(No foundation tasks.)

## 2. Implementation

- [x] 2.1. Update `openspec/templates/specs/spec.md` instruction: Add guardrail that specs describe behavior (WHAT), not implementation details — no concrete commands, file paths, or API calls. Implementation details belong in SKILL.md or design.md.
- [x] 2.2. Update `openspec/WORKFLOW.md` apply.instruction: Add fix-loop verify rule — after any fix-loop change (code, specs, or artifacts), re-run `/opsx:verify` before presenting to user. Do not skip step 3.5 (Final Verify).
- [x] 2.3. Update `openspec/WORKFLOW.md` apply.instruction: Add artifact freshness rule — when a fix resolves an issue flagged in preflight.md or design.md, update the affected artifact to reflect the resolution. Stale verdicts (e.g., "PASS WITH WARNINGS" after the warning is fixed) must not persist.
- [x] 2.4. Update `openspec/WORKFLOW.md` apply.instruction: Add docs terminology check — before user testing (step 3.3), check that docs/capabilities and docs/README.md do not reference stale terminology from changed specs. `/opsx:docs` in standard tasks handles regeneration, but stale references should be identified early.
- [x] 2.5. [P] Mirror apply.instruction changes to `src/templates/workflow.md`.

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Specs template instruction explicitly prohibits implementation details — PASS
  - [x] Apply.instruction requires verify re-run after fix-loop changes — PASS ("Fix loop discipline")
  - [x] Apply.instruction requires updating stale artifacts — PASS ("Artifact freshness")
  - [x] Apply.instruction includes docs terminology check before user testing — PASS ("Docs terminology check")
  - [x] Consumer template mirrors all apply.instruction changes — PASS (identical text in both files)
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (passed — 0 critical, 0 warnings, 0 suggestions)
- [x] 3.3. User Testing: User approved.
- [x] 3.4. Fix Loop: Not entered — no issues found.
- [x] 3.5. Final Verify: Skipped (3.4 not entered).
- [x] 3.6. Approval: User approved ("sieht gut aus").

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs — skipped (no spec changes, no capability docs to regenerate)
- [x] 4.3. Bump version (1.0.43 → 1.0.44)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
