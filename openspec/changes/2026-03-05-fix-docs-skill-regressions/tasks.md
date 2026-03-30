# Implementation Tasks: Fix Docs Skill Quality Regressions

## 1. Foundation

- [x] 1.1. Restore manual ADR: Create `docs/decisions/adr-M001-init-model-invocable.md` from git history (commit `3689c3e`)

## 2. Implementation

### SKILL.md Changes
- [x] 2.1. [P] R1 — Add skip rule for invalid Decisions sections in Step 4 (after Discovery paragraph)
- [x] 2.2. [P] R2 — Add manual ADR preservation rule in Step 4 (after "fully regenerated" line)
- [x] 2.3. [P] R2 — Add manual ADR inclusion in Step 5 (after Key Design Decisions table paragraph)
- [x] 2.4. [P] R2 — Add manual ADR cleanup protection in Step 6
- [x] 2.5. [P] R4 — Replace slug generation with deterministic 6-step algorithm in Step 4
- [x] 2.6. [P] R11 — Refine initial-spec fallback in Step 2

### Template Changes
- [x] 2.7. [P] R10 — Add Rationale guardrail comment in `capability.md` template (after Rationale section)
- [x] 2.8. [P] R9 — Add behavior header guidance comment in `capability.md` template (before Feature Group)
- [x] 2.9. [P] R5 — Replace References section in `adr.md` template with semantic link examples
- [x] 2.10. [P] R6 — Add description length constraint in `readme.md` template (capabilities table row)
- [x] 2.11. [P] R8 — Strengthen trade-offs completeness guidance in `readme.md` template

### Spec Sync (delta specs → baseline)
- [x] 2.12. Sync `decision-docs` delta spec to baseline via `/opsx:sync`
- [x] 2.13. Sync `user-docs` delta spec to baseline via `/opsx:sync`
- [x] 2.14. Sync `architecture-docs` delta spec to baseline via `/opsx:sync`

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: Verify each Success Metric from design.md — all 9 PASS.
  - [x] M1: No phantom ADR from `final-verify-step` archive
  - [x] M2: Manual ADR `adr-M001-init-model-invocable.md` survives regeneration
  - [x] M3: Manual ADR appears in README Key Design Decisions table
  - [x] M4: ADR slugs are deterministic
  - [x] M5: ADR References use semantic link text
  - [x] M6: README capability descriptions ≤ 80 chars / 15 words
  - [x] M7: Rationale sections use present tense
  - [x] M8: Initial-spec-only capabilities have Rationale when derivable
  - [x] M9: Behavior headers include command names for multi-command capabilities
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.
