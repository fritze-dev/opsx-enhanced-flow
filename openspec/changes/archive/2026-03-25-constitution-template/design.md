# Technical Design: Constitution Template Extraction

## Context

The bootstrap skill (`skills/bootstrap/SKILL.md`) hardcodes the constitution section structure (lines 47-69) as an inline markdown block. All other schema-generated artifacts use template files from `openspec/schemas/opsx-enhanced/templates/`. This change extracts the section structure into `templates/constitution.md` and updates the bootstrap skill to reference it.

## Architecture & Components

**Files affected:**

1. **`openspec/schemas/opsx-enhanced/templates/constitution.md`** (NEW)
   - Contains the constitution section headings and guidance comments
   - Same structure currently hardcoded in `SKILL.md` lines 47-69

2. **`skills/bootstrap/SKILL.md`** (MODIFIED)
   - Step 2: Replace the inline markdown block with a reference to the schema's constitution template
   - The skill instructs the agent to read the template from the active schema's template directory

**Interaction flow:**
```
Bootstrap Step 0: openspec schema which opsx-enhanced --json → gets schema path
Bootstrap Step 2: Read templates/constitution.md from schema path → generate constitution
```

No changes to downstream consumers (skills reading `openspec/constitution.md`, `schema.yaml` task generation, `docs/readme.md` template references).

## Goals & Success Metrics

* Constitution section structure exists as `openspec/schemas/opsx-enhanced/templates/constitution.md`
* Bootstrap skill references the template instead of defining sections inline
* The inline markdown block is fully removed from `SKILL.md`
* Template contains exactly the same sections as the current inline definition: Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks

## Non-Goals

* Supporting multiple schema variants (enabled but not implemented)
* Changing the constitution's section content or order
* Modifying the REVIEW-marker resolution flow
* Changing how `openspec/constitution.md` is read by other skills

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Template contains section headings + parenthetical guidance comments | Matches current inline format; guidance helps bootstrap agent understand what to fill in | Full Gherkin-style template (rejected: constitution is freeform, not structured like specs) |
| Bootstrap references template by schema path | Schema path already resolved in Step 0 via `openspec schema which`; natural to reuse | Hardcoded path (rejected: breaks per-schema extensibility) |
| Keep `# Project Constitution` heading in template | Template represents the complete constitution structure | Heading only in bootstrap (rejected: template should be self-contained) |

## Risks & Trade-offs

* **Schema path resolution already exists** → No new infrastructure needed. The bootstrap skill already runs `openspec schema which opsx-enhanced --json` in Step 0, which returns the schema path. Low risk.
* **Template drift from skill** → After extraction, the template is the source of truth. The inline block in the skill is removed entirely, eliminating drift. No risk.

## Open Questions

No open questions.

## Assumptions

- The `openspec schema which` command returns a JSON object with the schema's root path, from which `templates/constitution.md` can be derived. <!-- ASSUMPTION: Schema path resolution available in bootstrap -->
