# Pre-Flight Check: Fix Docs Regeneration Quality

## A. Traceability Matrix

**user-docs spec (MODIFIED: Generate Enriched Capability Documentation):**
- [x] Section completeness rule → Scenario: All sections included when source data exists → `skills/docs/SKILL.md` line 82
- [x] Behavior depth guidance → Scenario: Behavior subsections match scenario groups → `skills/docs/SKILL.md` after line 96
- [x] Step independence → Scenario: Step executed in subagent context → `skills/docs/SKILL.md` Guardrails section

**decision-docs spec (MODIFIED: Generate Architecture Decision Records):**
- [x] Enrichment reads → Scenario: ADR enrichment reads are self-contained → `skills/docs/SKILL.md` after line 106
- [x] References determination → Scenario: References determined from archive specs directory → `skills/docs/SKILL.md` after line 126
- [x] Step independence → Scenario: ADR enrichment reads are self-contained → `skills/docs/SKILL.md` Guardrails section

All stories trace to scenarios and components. No orphaned requirements.

## B. Gap Analysis

- **No gap:** Section-completeness rule covers the Known Limitations / Future Enhancements regression fully.
- **No gap:** Enrichment reads cover the ADR thin context regression fully.
- **Acknowledged deferral:** Content depth (thinner Behavior text) is explicitly out of scope — not addressable by SKILL.md rules. Documented in Non-Goals.
- **Acknowledged deferral:** Full per-step restructure deferred as future enhancement for autonomous agent readiness.
- **Edge case covered:** Archive without `research.md` or `proposal.md` — delta spec for decision-docs explicitly states the agent SHALL still generate ADRs using only `design.md` data.

## C. Side-Effect Analysis

- **No regression risk for existing docs:** The `read-before-write` guardrail (SKILL.md line 213) means existing docs are updated incrementally, not regenerated. The priority rule change only affects fresh generation.
- **No impact on Step 5 (README):** The README step reads generated docs from Steps 3-4, not SKILL.md instructions directly. Better quality docs from Steps 3-4 will produce a better README.
- **No impact on other skills:** Changes are isolated to `skills/docs/SKILL.md`. No other skills reference the docs skill's internal step structure.
- **Line number shifts:** Adding ~5 paragraphs to SKILL.md will shift line numbers for later sections. No external references depend on specific line numbers.

## D. Constitution Check

No constitution changes needed. This change does not introduce new technologies, patterns, or architectural conventions. The three-layer architecture (Constitution → Schema → Skills) is preserved — skill instructions are the correct location for these fixes.

## E. Duplication & Consistency

- **Step independence guardrail:** Added to both delta specs (user-docs and decision-docs) AND to the SKILL.md Guardrails section. This is intentional reinforcement, not duplication — the spec defines the requirement, the guardrail enforces it.
- **No contradiction with existing specs:** The existing user-docs spec already says to include Known Limitations and Future Enhancements when data exists (lines 17-18). The section-completeness rule makes this explicit in the skill. No conflict.
- **No contradiction with existing decision-docs spec:** The existing spec already says Context should be enriched from `design.md Context section` and `research.md Approaches` (line 20). The enrichment paragraph makes the read instructions actionable. No conflict.
- **Consistency between delta specs:** Both share the step independence language with consistent wording.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Per-section max limits are sufficient conciseness guards without priority-based section dropping | design.md, user-docs delta spec | Acceptable Risk | Verified: no capability doc exceeds 1.3 pages (77 lines max) even with all sections. Per-section limits (3 sentences, 5 bullets) cap growth. |
| 2 | Step independence guardrail will be respected when combined with explicit read instructions | design.md | Acceptable Risk | Explicit read instructions are more actionable than template comments. Guardrail + instructions is a belt-and-suspenders approach. Fallback (per-step restructure) is documented if insufficient. |
| 3 | Archive artifacts follow schema templates | decision-docs delta spec | Acceptable Risk | All archives were created through the opsx-enhanced workflow. Template compliance is enforced by the schema. |
| 4 | ADR template defines expected output structure | decision-docs delta spec | Acceptable Risk | Template exists at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` and is read by the skill. |

No assumptions rated "Needs Clarification" or "Blocking."
