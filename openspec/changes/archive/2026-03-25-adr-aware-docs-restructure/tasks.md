# Implementation Tasks: ADR-Aware Docs Restructure

## 1. Foundation — Templates

- [x] 1.1. Create `openspec/schemas/opsx-enhanced/templates/docs/architecture.md` template (System Architecture, Tech Stack, Conventions)
- [x] 1.2. Create `openspec/schemas/opsx-enhanced/templates/docs/decisions.md` template (Key Design Decisions table, Notable Trade-offs)
- [x] 1.3. Update `openspec/schemas/opsx-enhanced/templates/docs/readme.md` to hub format (nav links + capabilities table only)
- [x] 1.4. Update `openspec/schemas/opsx-enhanced/templates/research.md` — add optional "Related Decisions" section (section 0, before Current State)

## 2. Implementation

### Docs Skill — Step 5 Split
- [x] 2.1. Restructure `skills/docs/SKILL.md` Step 5 into sub-steps: 5a (architecture.md), 5b (decisions.md), 5c (README hub)
- [x] 2.2. Define per-file conditional regeneration in Step 5a: trigger on constitution drift or first run
- [x] 2.3. Define per-file conditional regeneration in Step 5b: trigger on new ADRs (Step 4 flag) or first run
- [x] 2.4. Define per-file conditional regeneration in Step 5c: trigger on capability doc changes (Step 3 flag), architecture.md/decisions.md changes (5a/5b flags), or first run
- [x] 2.5. Update Step 6 cleanup and output summary to reflect 3 output files

### Discover Skill — ADR Awareness
- [x] 2.6. Update `skills/discover/SKILL.md` Step 2: add sub-step after constitution read — read `docs/decisions.md` index, identify relevant ADRs, read selected ADR files
- [x] 2.7. Update `openspec/schemas/opsx-enhanced/schema.yaml` research instruction — add ADR awareness guidance

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric: `/opsx:docs` generates 3 separate files (README hub <50 lines, architecture.md, decisions.md) — PASS/FAIL
- [ ] 3.2. Metric: All 26+ ADRs appear in `docs/decisions.md` Key Design Decisions table — PASS/FAIL
- [ ] 3.3. Metric: `docs/README.md` contains working relative links to architecture.md and decisions.md — PASS/FAIL
- [ ] 3.4. Metric: Capabilities table in README hub is complete (all 18 capabilities, grouped by category) — PASS/FAIL
- [ ] 3.5. Metric: `/opsx:discover` references relevant ADRs in research.md when `docs/decisions.md` exists — PASS/FAIL
- [ ] 3.6. Metric: Constitution change triggers only `docs/architecture.md` regeneration — PASS/FAIL
- [x] 3.7. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [x] 3.8. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.9. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.10. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.9 was not entered.
- [x] 3.11. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
