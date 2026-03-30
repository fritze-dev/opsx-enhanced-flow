# Implementation Tasks: Design Review Checkpoint

## 1. Foundation

- [x] 1.1. Add "Design review checkpoint" convention to `openspec/constitution.md` in the `## Conventions` section

## 2. Implementation

- [x] 2.1. [P] Update `openspec/specs/artifact-generation/spec.md` — merge delta spec (modified ff requirement + 6 scenarios + edge cases)
- [x] 2.2. [P] Update `docs/capabilities/artifact-generation.md` — update ff behavior description, add Review Checkpoint subsection
- [x] 2.3. [P] Update `README.md` — Quick Start comment (line 78), Feature Cycle table (line 216), add Workflow Principle

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Constitution contains "Design review checkpoint" convention — PASS
  - [x] Artifact-generation spec describes two-phase ff behavior with review checkpoint — PASS
  - [x] All Gherkin scenarios cover: fresh run, partial resume, resume past design, all done — PASS
  - [x] README and capability docs reflect the two-phase ff behavior — PASS
  - [x] `skills/ff/SKILL.md` is NOT modified — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — PASSED, no issues
- [x] 3.3. User Testing: Approved by user.
- [x] 3.4. Fix Loop: Skipped — no issues found.
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered.
- [x] 3.6. Approval: **Approved** by user.
