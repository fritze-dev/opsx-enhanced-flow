# Implementation Tasks: Configurable Documentation Language

## 1. Foundation

- [x] 1.1. Update `skills/init/SKILL.md` Step 4 config template: add commented-out `# docs_language: English` field and add English-enforcement rule for workflow artifacts to the `context` field

## 2. Implementation

- [x] 2.1. [P] Update `skills/docs/SKILL.md`: add "Step 0: Determine Documentation Language" between Prerequisite and Step 1 — read `openspec/config.yaml`, extract `docs_language`, define translation rules
- [x] 2.2. [P] Update `skills/docs/SKILL.md`: add translation reminders to Step 3 (capability docs), Step 4 (ADRs), Step 5 (README)
- [x] 2.3. [P] Update `skills/changelog/SKILL.md`: add "Step 0: Determine Documentation Language" between Prerequisite and Step 1 — same config reading logic as docs skill
- [x] 2.4. [P] Update `skills/changelog/SKILL.md`: add translation reminder to Step 6 (entry generation)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] Init skill config template includes commented-out `docs_language` field — PASS
  - [x] Init skill config template includes English enforcement in `context` — PASS
  - [x] Docs skill has Step 0 that reads and applies `docs_language` — PASS
  - [x] Changelog skill has Step 0 that reads and applies `docs_language` — PASS
  - [x] Missing `docs_language` field defaults to English (backward-compatible) — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — all checks passed
- [x] 3.3. User Testing: Approved by user
- [x] 3.4. Fix Loop: Not entered — no issues found
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered
- [x] 3.6. Approval: **Approved** by user
