## Why

The ADR template defines a separate `## Rationale` section, but 14 of 15 generated ADRs already embed rationale inline in the Decision section. This happened as an unintentional side effect of the consolidation change (ADR-012) — the consolidated format instructions tell agents to put "individual rationale inline" but never explicitly address the template's separate Rationale section. The template and spec are now inconsistent with actual practice, causing occasional inconsistency (ADR-015 has a separate Rationale; the rest don't).

## What Changes

- **Remove `## Rationale` section from ADR template** — aligns the template with the inline-rationale pattern already used by 14/15 ADRs
- **Formalize inline-rationale in Decision section for all ADR types** — not just consolidated ADRs, also single-decision ADRs use the `**Decision text** — rationale` pattern
- **Update decision-docs spec** — remove the separate Rationale requirement, update the consolidated format description to apply to all ADRs, fix the spec/template contradiction
- **Update SKILL.md Step 4** — make inline-rationale the standard for all ADRs, not just consolidated ones
- **README Key Design Decisions table reads from ADRs directly** — currently the table sources Decision/Rationale from design.md archives and only uses ADR files for links. Change to read all data from ADR files, making ADRs the single canonical source. Unifies the extraction path for generated and manual ADRs.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `decision-docs`: Remove separate Rationale section requirement; formalize inline-rationale as the standard format for all ADRs (consolidated and non-consolidated)
- `architecture-docs`: Change Key Design Decisions table data source from design.md archives to ADR files

## Impact

- `openspec/schemas/opsx-enhanced/templates/docs/adr.md` — template structure change
- `skills/docs/SKILL.md` — Step 4 ADR generation instructions
- `openspec/specs/decision-docs/spec.md` — baseline spec (via delta)
- `openspec/specs/architecture-docs/spec.md` — baseline spec (via delta)
- `skills/docs/SKILL.md` — Step 5 README generation instructions
- Next `/opsx:docs` run will regenerate ADRs — ADR-015 is the only one expected to change (its separate Rationale gets folded into Decision)

## Scope & Boundaries

**In scope:**
- ADR template: remove `## Rationale` section
- decision-docs spec: update ADR section requirements and consolidated format description
- SKILL.md Step 4: align instructions for all ADR types
- architecture-docs spec: change README table data source to ADR files
- SKILL.md Step 5: update README generation to read from ADR files instead of design.md

**Out of scope:**
- Consequences section format (Positive/Negative split works well, no change needed)
- Context minimum length (4-6 sentences produces good results, no change needed)
- ADR consolidation heuristics (already working correctly)
- Actual ADR regeneration (happens automatically on next `/opsx:docs` run)
