# Implementation Tasks: Verify Content-Level Check

## 1. Foundation

(No foundational work needed — single file change with no dependencies.)

## 2. Implementation

- [x] 2.1. Rewrite Step 5 Spec Coverage: Replace "search codebase for keywords related to the requirement" with read-then-compare instructions. New text should instruct: (a) identify implementation file(s) from design.md, proposal Impact, or file naming conventions, (b) read the relevant section of each file, (c) extract key terms from the spec requirement, (d) compare terms against implementation content in context, (e) flag if requirement terms are missing or appear in wrong context.
- [x] 2.2. Rewrite Step 6 Requirement Implementation Mapping: Replace "search codebase for implementation evidence" + "assess if implementation matches requirement intent" with explicit content comparison. New text should instruct: (a) for each spec requirement, read the implementation file section that should contain it, (b) compare spec terminology (headings, field names, normative language) against implementation text, (c) flag terminology mismatches (spec says X, implementation says Y) as WARNING with file:line reference, (d) flag missing coverage (spec requires N items, implementation covers fewer) as WARNING.
- [x] 2.3. Rewrite Step 6 Scenario Coverage: Replace "check if conditions are handled in code" with read-and-verify. New text should instruct: (a) for each scenario's GIVEN/WHEN/THEN, read the implementation section that should handle it, (b) verify the implementation covers the scenario's preconditions, triggers, and assertions, (c) flag uncovered scenarios with specific details about what's missing.
- [x] 2.4. Update Verification Heuristics: Change Correctness heuristic from "Use keyword search, file path analysis, reasonable inference" to "Read implementation files and compare content against spec requirements. Use keyword search only for initial file discovery, then read and compare the relevant sections."

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
  - Verify detects terminology mismatches between spec and implementation
  - Verify reads actual file content before reporting coverage
  - Verify reports stale headings/field names as WARNING with file:line references
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [x] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [x] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Generate changelog (`/opsx:changelog`)
- [x] 4.2. Generate/update docs (`/opsx:docs`)
- [x] 4.3. Bump version
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #X"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
