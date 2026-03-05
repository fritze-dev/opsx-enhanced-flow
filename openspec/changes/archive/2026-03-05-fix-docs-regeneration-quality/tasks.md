# Implementation Tasks: Fix Docs Regeneration Quality

## 1. Foundation

No foundation tasks — all changes are within the existing `skills/docs/SKILL.md` file.

## 2. Implementation

- [x] 2.1. [P] Replace space-constrained priority rule (SKILL.md line 82) with section-completeness rule: "Include ALL sections from the template when source data exists. Only omit a section when no source data is available."
- [x] 2.2. [P] Add Behavior depth guidance after Mapping Rules section (after line 96): "Each distinct Gherkin scenario group in the spec should produce at least one Behavior subsection."
- [x] 2.3. Add Enrichment paragraph to Step 4 after Discovery (after line 106): explicit read instructions for full `design.md` (Context, Architecture, Risks), `research.md` (Sections 2-3), and `proposal.md` (Why) from each archive.
- [x] 2.4. Add References determination rule to Step 4 after ADR generation instructions (after line 126): check archive `specs/` subdirectory, cross-reference related ADRs, include GitHub Issues.
- [x] 2.5. Add step independence guardrail to Guardrails section (after line 219): "Each step must read its own source materials independently."

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check: All 9 previously-affected capability docs include Known Limitations when Non-Goals data exists — PASS / FAIL
- [ ] 3.2. Metric Check: All 6 previously-affected capability docs include Future Enhancements when deferred Non-Goals exist — PASS / FAIL
- [ ] 3.3. Metric Check: ADR Context sections ≥ 4 sentences on 5 spot-checked ADRs — PASS / FAIL
- [ ] 3.4. Metric Check: ADR References sections contain ≥ 2 links per ADR — PASS / FAIL
- [ ] 3.5. Metric Check: No capability doc exceeds 120 lines (2 pages) — PASS / FAIL
- [ ] 3.6. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.7. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.8. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before archiving.
- [ ] 3.9. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.8 was not entered.
- [ ] 3.10. Approval: Only finish on explicit **"Approved"** by the user.
