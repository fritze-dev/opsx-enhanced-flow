## Why

When `/opsx:docs` regenerates all documentation from scratch, two quality regressions occur: ADR Context sections are ~50% thinner because Step 4 lacks self-contained enrichment reads (Issue #28), and 9 of 18 capability docs lose their Known Limitations section because a "space-constrained" priority rule marks it as optional (Issue #29). Both were discovered during a full QA cycle for Issue #25 and workarked around manually — the fix needs to be in the skill instructions themselves.

## What Changes

- **Replace space-constrained priority rule** in SKILL.md Step 3 with a section-completeness rule: include all template sections when source data exists, only omit when no data is available
- **Add Behavior depth guidance** to Step 3: each distinct Gherkin scenario group should produce at least one Behavior subsection
- **Add self-contained enrichment reads** to SKILL.md Step 4: explicit instructions to read full `design.md` (Context, Architecture, Risks), `research.md` (Sections 2-3), and `proposal.md` (Why) from each archive — not just the Decisions table
- **Add References determination rule** to Step 4: check archive `specs/` subdirectory to find relevant specs, cross-reference related ADRs, include GitHub Issues
- **Add step independence guardrail** to SKILL.md Guardrails section: each step must read its own source materials independently
- **Reinforce spec language** in `user-docs` and `decision-docs` specs with step independence and section-completeness requirements

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `user-docs`: Add section-completeness requirement (replace optional priority with data-driven inclusion), add Behavior depth rule, add step independence requirement
- `decision-docs`: Add self-contained enrichment read requirement for ADR generation, add References determination rule, add step independence requirement

## Impact

- `skills/docs/SKILL.md` — Primary fix surface (Step 3 conciseness guards, Step 4 enrichment, Guardrails section)
- `openspec/specs/user-docs/spec.md` — Delta spec reinforcing section-completeness
- `openspec/specs/decision-docs/spec.md` — Delta spec reinforcing enrichment reads
- No breaking changes. Existing docs are unaffected due to `read-before-write` guardrail.

## Scope & Boundaries

**In scope:**
- SKILL.md instruction fixes (priority rule, enrichment, guardrail)
- Delta specs for user-docs and decision-docs
- Closes GitHub Issues #28 and #29

**Out of scope:**
- Content depth regression (thinner Behavior text, fewer Edge Cases items) — deferred; occurs whenever docs are generated from scratch (no existing doc as quality floor for `read-before-write`), not addressable by SKILL.md rules alone, see Issue #29
- Full per-step restructure for autonomous agent readiness — deferred as future enhancement (Approach C in research)
- ADR template changes — the template comments are cosmetic and not the root cause
