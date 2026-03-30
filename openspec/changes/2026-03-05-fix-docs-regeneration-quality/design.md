# Technical Design: Fix Docs Regeneration Quality

## Context

The `/opsx:docs` skill generates capability docs (Step 3), ADRs (Step 4), and a consolidated README (Step 5). A full QA cycle (delete all docs → regenerate → diff) revealed two quality regressions:

1. ADR Context sections lost ~50% of their length because Step 4 only reads the Decisions table from `design.md`, implicitly depending on Step 2's loaded data for enrichment context (Issue #28).
2. 9 of 18 capability docs dropped Known Limitations and 6 dropped Future Enhancements because a "space-constrained" priority rule at SKILL.md line 82 marks these sections as `(optional)` (Issue #29).

The fix is contained entirely within `skills/docs/SKILL.md` — the specs already describe correct behavior but are reinforced with explicit step independence language.

## Architecture & Components

**Single file, three change sites:**

| File | Location | Change |
|------|----------|--------|
| `skills/docs/SKILL.md` | Line 82 (Step 3 conciseness guards) | Replace priority rule with section-completeness rule |
| `skills/docs/SKILL.md` | After line 96 (Step 3 Mapping Rules) | Add Behavior depth guidance |
| `skills/docs/SKILL.md` | After line 106 (Step 4 Discovery) | Add Enrichment paragraph with explicit read instructions |
| `skills/docs/SKILL.md` | After line 126 (Step 4 ADR generation) | Add References determination rule |
| `skills/docs/SKILL.md` | Line ~219 (Guardrails section) | Add step independence guardrail |

No cross-module interactions. No new files. No template changes needed — the ADR template comments are cosmetic and not the root cause.

## Goals & Success Metrics

* All 9 previously-affected capability docs include Known Limitations when Non-Goals data exists — PASS/FAIL by section presence check
* All 6 previously-affected capability docs include Future Enhancements when deferred Non-Goals exist — PASS/FAIL by section presence check
* ADR Context sections are ≥ 4 sentences (previously ~2-3 in thin versions) — PASS/FAIL by sentence count on 5 spot-checked ADRs
* ADR References sections contain ≥ 2 links per ADR (previously 0-1) — PASS/FAIL by link count
* No capability doc exceeds 2 pages after adding sections back — PASS/FAIL by line count (< 120 lines)

## Non-Goals

- Content depth regression (thinner Behavior text, fewer Edge Cases) — deferred; occurs whenever docs are generated from scratch without an existing doc as quality floor, not addressable by SKILL.md rules alone (Issue #29)
- Full per-step restructure for autonomous agent readiness — deferred as future enhancement; Approach C in research aligns with planned autonomous agent transition but only Step 4 currently has the implicit dependency problem
- ADR template comment changes — cosmetic, not the root cause

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Replace priority rule with section-completeness rule | Positive guidance ("include when data exists") prevents section dropping without removing conciseness guards (per-section max limits remain) | Remove priority line entirely — rejected because it leaves no guidance |
| Add enrichment reads only to Step 4, not all steps | Only Step 4 has the implicit dependency problem; Step 3's regression is a different root cause (priority rule). Step independence guardrail covers the general case. | Full per-step restructure — deferred as future enhancement for autonomous agent readiness |
| Add step independence as a guardrail, not a structural change | A guardrail rule is simpler and matches the existing SKILL.md structure. If insufficient, per-step restructure is the documented fallback. | Restructure all steps into self-contained subagent instructions — more robust but unnecessary scope |
| Reinforce specs with step independence language | Convention requires spec changes to go through the flow. Explicit spec language prevents future drift between spec and skill. | Skip spec changes — rejected because specs and skill should stay aligned |

## Risks & Trade-offs

- **Agent may still drop sections despite rule change** → Mitigation: The section-completeness rule uses imperative language ("SHALL include ALL sections") and the existing per-section max limits prevent bloat as a secondary guard. If the agent still drops sections, the fallback is restructuring the QA flow to use sequential per-change regeneration.
- **Enrichment reads add overhead to Step 4** → Mitigation: Negligible — reading 2-3 additional markdown files per archive adds < 1 second per archive. There are currently 5 archives.
- **Step independence guardrail is advisory, not enforced** → Mitigation: The guardrail is backed by explicit read instructions in Step 4. The guardrail catches future regressions in other steps. If insufficient, Approach C (per-step restructure) is the documented escalation path.

## Open Questions

No open questions.

## Assumptions

- Per-section maximum limits are sufficient conciseness guards without needing a priority-based section-dropping rule. <!-- ASSUMPTION: Based on observed doc lengths — no capability doc exceeds 1.3 pages even with all sections -->
- The step independence guardrail will be respected by the agent when combined with explicit read instructions. <!-- ASSUMPTION: Explicit read instructions are more actionable than template comments -->
