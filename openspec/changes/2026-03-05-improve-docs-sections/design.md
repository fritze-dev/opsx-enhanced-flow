# Technical Design: Improve Docs Sections

## Context

The `/opsx:docs` capability generates user-facing documentation from baseline specs and archive enrichment data. After v1.0.7, the generated docs had content quality regressions (Purpose derived from change motivation instead of capability purpose, Rationale replaced with change-event descriptions) and structural inconsistencies (different heading names for enriched vs spec-only docs). The root cause is in the SKILL.md enrichment guidance.

## Architecture & Components

Four files are affected, all in different layers:

1. **`skills/docs/SKILL.md`** (Skills layer) — Enrichment guidance in Step 2, conciseness guards in Step 3, guardrails section
2. **`openspec/schemas/opsx-enhanced/templates/docs/capability.md`** (Schema layer) — Structural template with section guidance
3. **`openspec/specs/user-docs/spec.md`** (Spec layer) — Baseline spec defining `/opsx:docs` behavior
4. **`docs/capabilities/*.md`** (Output) — 18 generated capability docs

Changes flow top-down: SKILL.md and template define behavior → spec codifies requirements → docs are the output.

## Goals & Success Metrics

* All 18 capability docs use "Purpose" and "Rationale" headings (no "Why This Exists", "Background", or "Design Rationale"): PASS/FAIL
* Every Purpose section describes capability purpose via problem-framing, not change motivation: PASS/FAIL
* Every Rationale section describes design reasoning, not change events: PASS/FAIL
* 6+ docs include a "Future Enhancements" section with actionable items: PASS/FAIL
* SKILL.md contains explicit guidance preventing Purpose/Rationale regression: PASS/FAIL
* Capability template includes Future Enhancements section with guidance: PASS/FAIL

## Non-Goals

- Full docs regeneration via `/opsx:docs` (deferred to friction issue #18)
- Changes to ADR generation, README generation, or other docs steps
- Changes to skills beyond `docs/SKILL.md`
- Changes to specs beyond `user-docs`

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Unified "Purpose" heading for all docs | Standard, unambiguous term; eliminates enriched vs spec-only inconsistency | Keep "Why This Exists" (informal), use "Motivation" (too change-focused) |
| Unified "Rationale" heading for all docs | Standard ADR terminology; covers both research-based and assumption-based design reasoning | "Background" (too vague), "Design Rationale" (redundant with ADR Context) |
| Separate "Future Enhancements" from "Known Limitations" | Limitations = current constraints; Enhancements = actionable future ideas — different audiences and purposes | Single "Limitations & Future" section, embed in Edge Cases |
| "Read before write" guardrail in SKILL.md | Prevents quality regression by requiring agent to read existing doc before generating | Template-only guidance (too easy to miss), no guardrail (regression-prone) |
| Manual doc fixes + deferred regeneration | Safer: preserves established quality, validates guardrails separately | Regenerate now (risks new regressions before guardrails are proven) |

## Risks & Trade-offs

- **Manual fixes may miss edge cases** → Mitigated by systematic diff review of all 18 docs
- **SKILL.md guidance is advisory, not enforced** → Accepted risk: agent compliance with well-written guidance is high; hard enforcement would require code changes
- **Deferred regeneration means current docs are manually curated, not generated** → Accepted: friction issue #18 tracks the regeneration pass

## Open Questions

No open questions.

## Assumptions

- The "read before write" guardrail will be respected by future agent runs. <!-- ASSUMPTION: Agent compliance with SKILL.md guidance -->
- Friction issue #18 will be addressed before the next major capability addition. <!-- ASSUMPTION: Regeneration happens before docs drift -->
