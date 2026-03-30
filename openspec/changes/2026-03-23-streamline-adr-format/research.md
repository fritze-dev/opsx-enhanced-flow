# Research: Streamline ADR Format

## 1. Current State

**Affected files:**
- `openspec/schemas/opsx-enhanced/templates/docs/adr.md` — ADR template (7 sections)
- `skills/docs/SKILL.md` — ADR generation instructions (Step 4)
- `docs/decisions/adr-*.md` — 15 generated ADR files (795 lines, ~53 lines avg)

**Issue context vs. current state:** The issue was filed when there were 34 ADRs totaling ~1290 lines. Since then, ADR-012 introduced consolidation heuristics (commit `4b94175`) that reduced the count to 15 ADRs and 795 lines. The volume problem is already solved.

**Template vs. practice divergence — the real problem:** The ADR template defines 7 sections including a separate `## Rationale`. In practice, 14 of 15 ADRs have no separate Rationale section. This happened as an **unintentional side effect** of the consolidation change (ADR-012):

The consolidated ADR format instructions in SKILL.md say:
> **Decision section**: Numbered list of sub-decisions with individual rationale inline

This tells agents to embed rationale in the Decision section but never explicitly removes or addresses the template's `## Rationale` section. Since the consolidation heuristics apply to nearly all archives (3+ rows AND single-topic), the consolidated format became the de facto standard and the separate Rationale section silently disappeared. Only ADR-015 has a separate Rationale — likely because the agent followed the template more literally.

**Was quality lost?** No — quality actually **improved**. Pre-consolidation Rationale sections were **always redundant copies** of the Decision text:

| ADR (pre-consolidation) | Decision | Rationale | Redundancy |
|---|---|---|---|
| ADR-009 | "Patch-only auto-bump. 95%+ of changes are patches; minor/major are rare and intentional." | "95%+ of changes are patches; minor/major are rare and intentional." | 100% copy |
| ADR-019 | "Constitution convention only. Respects skill immutability; constitution is always loaded and authoritative." | "Respects skill immutability; constitution is always loaded and authoritative." | 100% copy |
| ADR-010 | "Sync marketplace.json in same convention. One operation, no drift." | "One operation, no drift." | 100% copy |

This happened because the source data — the design.md Decisions table — has "Decision" and "Rationale" columns, and for most decisions the rationale IS the decision statement. There's no additional depth in a separate column.

Post-consolidation ADRs (e.g., ADR-004) use numbered sub-decisions with **decision-specific** inline rationale via em-dash, which is strictly better: each decision is paired with its own reason instead of a redundant copy at the bottom.

**The Consequences split and Context minimum** (the other questions from the issue) are not problems in practice:
- **Consequences (Positive/Negative):** The split works well. ADRs with substantive trade-offs benefit from the visual separation. Merging would save 2-3 lines but lose structural clarity.
- **Context minimum (4-6 sentences):** Has consistently produced excellent Context sections across all ADRs. The pre-consolidation single-row ADRs had some of the best Contexts in the project.

## 2. External Research

Not applicable — this is a template/instructions alignment fix, not a new format design.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Align template + SKILL.md with current practice** | Fixes the template/practice divergence; minimal change; no quality risk; no regeneration needed if ADR content stays the same | Doesn't address theoretical future issues |
| **B: Full restructure (remove Rationale + merge Consequences + relax Context)** | Addresses all issue questions | Over-engineering — Consequences split and Context minimum aren't problems; risks quality regression |
| **C: Do nothing** | Zero risk | Template remains misleading; agents may produce inconsistent ADRs (some with Rationale, some without) |

## 4. Risks & Constraints

- **Regeneration impact:** Template changes trigger full ADR regeneration on next `/opsx:docs` run. If only the Rationale section is removed and inline-rationale is formalized, most regenerated ADRs should be content-identical (14/15 already have no Rationale section). ADR-015 would be the only one that changes.
- **SKILL.md complexity:** The consolidated format instructions already describe the inline-rationale pattern. The fix is to make this explicit for ALL ADRs (not just consolidated ones) and remove the template's `## Rationale` section.
- **Template as contract:** The template defines what agents generate. As long as it includes `## Rationale`, some agents will produce it, creating inconsistency.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Remove `## Rationale` from template, formalize inline-rationale in SKILL.md for all ADR types |
| Behavior | Clear | Template change + SKILL.md instruction update |
| Data Model | Clear | No data model — markdown template structure only |
| UX | Clear | ADRs remain the same quality; one inconsistent ADR (015) gets aligned |
| Integration | Clear | SKILL.md Step 4, template, regeneration mechanism already exists |
| Edge Cases | Clear | Non-consolidated single-decision ADRs: inline rationale still works (em-dash after the decision statement) |
| Constraints | Clear | Must not break archive backlinks, cross-references, or README table |
| Terminology | Clear | No new terms — "inline rationale" is already the practice |
| Non-Functional | Clear | Minimal line count change; consistency improvement |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use Approach A (align template + SKILL.md with current practice) | The Rationale section was always redundant (100% copy from Decision column); consolidation replaced it with something better (inline rationale); no quality was lost; the only real problem is template/practice divergence | Approach B (full restructure — over-engineering, Consequences and Context are fine), Approach C (do nothing — leaves template misleading) |
| 2 | Keep Consequences split (Positive/Negative) as-is | The split provides useful visual separation for trade-offs; merging would save 2-3 lines but reduce clarity; not a problem in practice | Merge into single +/- list (marginal savings, loses structure) |
| 3 | Keep Context minimum at 4-6 sentences | Has consistently produced high-quality Context sections; relaxing to 2 sentences risks thin contexts that don't explain the problem well | Relax to 2-6 (marginal, risks quality), remove minimum entirely (risks thin contexts) |
