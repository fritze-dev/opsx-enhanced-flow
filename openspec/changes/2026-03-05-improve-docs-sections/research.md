# Research: Improve Docs Sections

## 1. Current State

The `/opsx:docs` command generates 18 capability docs, 18 ADRs, and a consolidated README. After the v1.0.7 `improve-docs-quality` change, a detailed review revealed content quality regressions and structural inconsistencies in the generated capability docs:

- **Heading inconsistency**: Enriched docs used "Why This Exists" + "Background", initial-spec-only docs used "Why This Exists" + "Design Rationale" — confusing for readers
- **Purpose regression**: The SKILL.md instructed agents to derive "Why This Exists" from archive proposal "Why" sections, which describe change motivation (e.g., "The init skill was broken"), not capability purpose (e.g., "Without a single initialization command, you'd need to manually...")
- **Rationale regression**: Regenerated docs replaced design reasoning with change-event descriptions in 11 of 18 docs
- **Missing section**: No "Future Enhancements" section existed, despite deferred Non-Goals and tracked GitHub Issues being available as enrichment sources
- **No quality guardrail**: Agent could rewrite docs from scratch, losing established tone and quality

Affected files:
- `skills/docs/SKILL.md` — root cause of Purpose/Rationale regressions
- `openspec/schemas/opsx-enhanced/templates/docs/capability.md` — structural template
- `openspec/specs/user-docs/spec.md` — baseline spec for docs capability
- `docs/capabilities/*.md` — 18 generated capability docs

## 2. External Research

Not applicable — this is an internal documentation quality improvement. No external APIs or libraries involved.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Fix SKILL.md guidance + update template + manual doc fixes | Fixes root cause, prevents future regression, immediate quality improvement | Requires careful manual review of all 18 docs |
| B: Fix SKILL.md only, then regenerate all docs | Less manual work, tests the fix end-to-end | Risk of new regressions during regeneration (the exact problem we're solving) |
| C: Fix SKILL.md + add guardrails, then regenerate | Best of both: fixes root cause and validates with regeneration | Requires trusting the guardrails work on first try |

**Chosen: Approach A** — Fix the root cause in SKILL.md, update the template and spec, manually fix the 18 docs (heading renames + new sections), and defer full regeneration to a separate friction issue (#18).

## 4. Risks & Constraints

- **Skill immutability**: SKILL.md is shared plugin code — changes must remain generic, not project-specific
- **Content quality**: Manual doc edits must preserve the original quality; content regressions were the problem we're fixing
- **Consistency**: All 18 docs must use the same heading structure after the change
- **Spec accuracy**: The user-docs baseline spec must match the updated SKILL.md behavior

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 4 files changed: SKILL.md, template, spec, 18 docs |
| Behavior | Clear | Purpose from spec, Rationale from research/design, Future Enhancements from Non-Goals |
| Data Model | Clear | No data model changes — Markdown files only |
| UX | Clear | Heading renames improve readability; Future Enhancements adds useful section |
| Integration | Clear | No integration changes — docs generation pipeline unchanged |
| Edge Cases | Clear | Covered by existing spec edge cases |
| Constraints | Clear | Skill immutability respected |
| Terminology | Clear | "Purpose" and "Rationale" are standard, unambiguous terms |
| Non-Functional | Clear | No performance or scaling impact |

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Rename "Why This Exists" → "Purpose" and unify "Background"/"Design Rationale" → "Rationale" | Consistent, standard terminology across all docs regardless of enrichment level | Keep separate headings for enriched vs spec-only |
| 2 | Add "Future Enhancements" section separate from "Known Limitations" | Limitations describe current constraints; enhancements describe actionable future ideas — conflating them confuses readers | Merge into Known Limitations, add to Edge Cases |
| 3 | Add "CRITICAL — Purpose section source" guidance to SKILL.md | Root cause fix: agents must derive Purpose from spec Purpose section, not from archive proposal "Why" | Add guidance only to template comments |
| 4 | Add "read before write" guardrail to SKILL.md | Prevents agents from rewriting docs from scratch, preserving established quality | No guardrail — rely on template alone |
| 5 | Classify Non-Goals into Limitations vs Future Enhancements | Non-Goals serve two distinct purposes: current constraints and deferred features | Single list for all Non-Goals |
| 6 | Defer full docs regeneration to friction issue #18 | Manual fixes are safer for this change; regeneration can validate guardrails separately | Regenerate as part of this change |
