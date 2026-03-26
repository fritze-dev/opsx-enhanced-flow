# Implementation Tasks: /opsx:docs-verify

## 1. Foundation

- [x] 1.1. Create `skills/docs-verify/` directory structure

## 2. Implementation

- [x] 2.1. Create `skills/docs-verify/SKILL.md` with full skill definition:
  - Frontmatter (name, description, disable-model-invocation: false)
  - Input section (no arguments — operates on entire project)
  - Step 1: Prerequisite check (verify `openspec/WORKFLOW.md` exists)
  - Step 2: Discovery (glob specs, capability docs, ADRs, archives, README)
  - Step 3: Dimension A — Capability Docs vs Specs (check existence + requirement coverage)
  - Step 4: Dimension B — ADRs vs Design Decisions (check archived Decisions tables have ADRs, skip manual adr-MNNN)
  - Step 5: Dimension C — README vs Current State (capabilities table, Key Design Decisions references, constitution consistency)
  - Step 6: Generate Report (summary scorecard, grouped findings by dimension, verdict: CLEAN/DRIFTED/OUT OF SYNC)
  - Graceful degradation (missing docs/, missing archives, missing README)
  - Verification heuristics and output format sections

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check:
  - [x] `/opsx:docs-verify` on a fully in-sync project produces CLEAN verdict with 0 issues — PASS
  - [x] `/opsx:docs-verify` after adding a new spec without regenerating docs produces at least one CRITICAL finding — PASS
  - [x] Report includes file references for every finding — PASS
  - [x] Skill completes without error when `docs/` directory is empty or missing — PASS
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command). Result: 0 CRITICAL, 1 WARNING (minor edge case — accepted).
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Skipped — no fixes needed.
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered.
- [x] 3.6. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. _(Post-Merge)_ Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
