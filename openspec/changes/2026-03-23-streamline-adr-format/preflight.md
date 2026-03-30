# Pre-Flight Check: Streamline ADR Format

## A. Traceability Matrix

- [x] Story "formal decision records with inline rationale" → Scenario "ADR decision includes inline rationale" → ADR template (`templates/docs/adr.md`), SKILL.md Step 4
- [x] Story "formal decision records with inline rationale" → Scenario "ADRs generated from single archive" → SKILL.md Step 4 generation logic
- [x] Story "related sub-decisions grouped" → Scenario "Single-topic archive with 5 decisions consolidated" → SKILL.md Step 4 consolidated format block
- [x] Story "ADRs in my language" → Scenario "ADR generated in configured language" → SKILL.md Step 4 language reminder, spec heading list
- [x] Story "single document with key decisions" → Scenario "Design decisions table sourced from ADR files" → SKILL.md Step 5 README generation
- [x] All other existing scenarios (numbering, enrichment, references, validation, incremental, manual preservation, conditional regeneration) → Unchanged, carried forward from baseline specs

All stories trace to scenarios, all scenarios trace to components. No orphaned requirements.

## B. Gap Analysis

No gaps identified.

- Edge case "single-decision ADR with inline rationale" is explicitly added to the decision-docs delta spec's Edge Cases section.
- Edge case "Generated ADR with inline rationale extraction" is added to the architecture-docs delta spec's Edge Cases section.
- The new scenario "ADR decision includes inline rationale" covers the ADR format change.
- The new scenario "Design decisions table sourced from ADR files" covers the README table source change.

## C. Side-Effect Analysis

| System | Risk | Assessment |
|--------|------|------------|
| ADR template | `## Rationale` section removed | **Intended.** Direct target of the change. |
| SKILL.md Step 4 | Inline-rationale generalized to all ADR types | **Intended.** Consolidated format block already describes this; change makes it explicit for all types. |
| SKILL.md Step 5 (README) | Key Design Decisions table data source changes from design.md to ADR files | **Intended.** Unifies extraction path; ADRs become single canonical source. |
| Manual ADR extraction | README extracts `## Rationale` from manual ADRs | **No impact.** Manual ADRs still have `## Rationale`; the unified extraction path handles both generated (inline) and manual (section) rationale. |
| ADR regeneration | Next `/opsx:docs` triggers full regeneration | **Expected.** Only ADR-015 content changes (separate Rationale → inline). 14 other ADRs already match the new format. |
| Existing archive design.md files | Decisions tables still have "Rationale" column | **No impact.** Step 4 still reads design.md for ADR generation. Step 5 no longer reads design.md for the README table — reads ADRs instead. |
| README table content quality | Agent must extract/summarize from ADR content instead of structured table columns | **Low risk.** Agent already summarizes when building the table (current Decision column is not verbatim from design.md). Summarizing from ADR content is equally natural for LLM agents. |

No unexpected side effects identified.

## D. Constitution Check

No constitution changes needed. The change affects schema-level artifacts (template, skill instructions) and specs only. No new patterns, conventions, or architecture rules introduced.

## E. Duplication & Consistency

- **decision-docs delta spec vs. baseline**: Delta spec correctly modifies the "Generate Architecture Decision Records" requirement to replace separate Rationale with inline-rationale. The "ADR Consolidation" requirement is updated to explicitly mention the em-dash pattern. Consistent.
- **architecture-docs delta spec vs. baseline**: Delta spec correctly modifies the "Generate Architecture Overview" requirement to source the table from ADR files instead of design.md. The "Generate Documentation Table of Contents" requirement is NOT modified (it references the Key Design Decisions table but defers data source to the overview requirement). Consistent.
- **Delta specs vs. ADR template**: Both will align after implementation — template removes `## Rationale`, spec describes inline pattern.
- **Delta specs vs. SKILL.md**: Steps 4 and 5 will be updated to match the specs.
- **Language-Aware heading list**: Spec scenario updated to list 6 headings — consistent with template removal of Rationale.
- **Cross-spec consistency**: `user-docs` spec is unaffected. `architecture-docs` and `decision-docs` delta specs are consistent with each other (ADRs are generated in Step 4, then read by Step 5).

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Artifacts follow schema templates | decision-docs spec | Acceptable Risk | Core guarantee of the OpenSpec workflow |
| 2 | ADR template defines expected output structure | decision-docs spec | Acceptable Risk | Template is the authoritative format reference |
| 3 | Archives are immutable after archiving | decision-docs spec | Acceptable Risk | Core architectural guarantee |
| 4 | Spec renames/splits are infrequent | decision-docs spec | Acceptable Risk | Historical pattern confirms this |
| 5 | Inline-rationale em-dash pattern is well-understood by agents | design.md | Acceptable Risk | Pattern already successfully used in 14/15 ADRs without explicit template guidance — formalizing it reduces risk further |
| 6 | ADR files are generated before README generation (Step 4 before Step 5) | architecture-docs spec, design.md | Acceptable Risk | SKILL.md step ordering guarantees this — has been stable since initial implementation |
| 7 | Constitution maintained by archive workflow | architecture-docs spec | Acceptable Risk | Core guarantee |

All assumptions rated **Acceptable Risk**. No blockers or clarifications needed.

## Verdict

**PASS** — Template/instruction alignment plus README table source simplification. No gaps, no unexpected side effects, no blocking assumptions.
