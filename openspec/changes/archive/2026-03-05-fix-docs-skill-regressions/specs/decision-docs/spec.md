## MODIFIED Requirements

### Requirement: Generate Architecture Decision Records
The `/opsx:docs` command SHALL generate Architecture Decision Records (ADRs) from the `## Decisions` tables found in all archived `design.md` files at `openspec/changes/archive/*/design.md`. Each row in a Decisions table SHALL become one ADR file at `docs/decisions/adr-NNN-<slug>.md` where NNN is a zero-padded sequential number. The agent SHALL read the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` for the expected output format. ADR numbering SHALL be global and sequential across all archives, sorted chronologically by archive date prefix (`YYYY-MM-DD`). Within each archive, decisions SHALL be numbered in table row order. ADRs SHALL be fully regenerated on each run (not incremental). The `docs/decisions/` directory SHALL be created if it does not exist. When regenerating, the agent SHALL NOT delete files matching `adr-M*.md` — these are manual ADRs (see below).

The agent SHALL NOT generate an ADR index at `docs/decisions/README.md`. ADR discovery is handled by inline links in the `docs/README.md` Key Design Decisions table. If `docs/decisions/README.md` exists from a previous run, the agent SHALL delete it.

**Skip rule for invalid Decisions sections:** After reading each `design.md`, the agent SHALL verify that a markdown table with pipe delimiters exists under a heading containing "Decisions" (e.g., `## Decisions` or `## Architecture Decisions`). A valid Decisions table MUST have columns that include "Decision" and "Rationale". If the section contains only prose (e.g., "No architectural changes"), a non-Decisions table (e.g., Success Metrics), or no table at all, the agent SHALL skip that archive for ADR generation.

Each ADR SHALL include:
- **Status**: "Accepted" with the archive date
- **Context**: From the `design.md` Context section, enriched with `research.md` Approaches and findings from the same archive where available. The Context section SHALL be at least 4-6 sentences. It SHALL include what motivated the decision (the problem being solved), what was investigated or researched, and key constraints or trade-offs that shaped the decision. The agent SHALL NOT write thin Context sections like "we chose X over Y because Z".
- **Decision**: From the Decisions table "Decision" column
- **Rationale**: From the Decisions table "Rationale" column
- **Alternatives Considered**: From the Decisions table "Alternatives" column, expanded into bullets
- **Consequences**: Split into two subsections:
  - **Positive**: Benefits of this decision, derived from the rationale, context, and positive outcomes
  - **Negative**: Drawbacks, risks, or trade-offs, derived from the `design.md` "Risks & Trade-offs" section filtered to relevance for this specific decision where possible
- **References**: Links to related resources using semantic link text. The agent SHALL use descriptive text like `[Spec: three-layer-architecture](path)`, NOT raw file paths as link text like `[../../openspec/specs/three-layer-architecture/spec.md](path)`. Include the relevant spec file, related ADRs if the decision connects to other decisions, and the GitHub Issue if applicable.

The slug SHALL be derived from the Decision column text using this deterministic algorithm:
1. Lowercase the entire string
2. Replace any character that is NOT in `[a-z0-9]` with a hyphen
3. Collapse consecutive hyphens into a single hyphen
4. Trim leading and trailing hyphens
5. Truncate to 50 characters
6. Trim trailing hyphens again (in case truncation split a word)

**User Story:** As a developer or contributor I want formal decision records with clear positive and negative consequences and links to related specs, so that I can understand why architectural choices were made, what trade-offs were accepted, and where to find more context.

#### Scenario: ADRs generated from single archive with Decisions table
- **GIVEN** an archived change at `openspec/changes/archive/2026-03-04-release-workflow/` with a `design.md` containing a Decisions table with 4 rows
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent creates 4 ADR files under `docs/decisions/` with split Consequences and References sections

#### Scenario: ADR numbering across multiple archives
- **GIVEN** two archived changes: `2026-03-02-initial-spec` with 3 decisions and `2026-03-04-release-workflow` with 4 decisions
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the initial-spec decisions are numbered ADR-001 through ADR-003 and the release-workflow decisions are numbered ADR-004 through ADR-007

#### Scenario: ADR context enriched with research data
- **GIVEN** an archived change with both a `design.md` containing a Decisions table and a `research.md` with an Approaches section
- **WHEN** the agent generates an ADR for a decision from that change
- **THEN** the ADR "Context" section includes relevant research findings and investigated approaches alongside the design context, totaling at least 4-6 sentences

#### Scenario: ADR context has sufficient depth
- **GIVEN** an archived change with a `design.md` containing a Context section
- **WHEN** the agent generates an ADR
- **THEN** the ADR Context section is at least 4-6 sentences, including the problem motivation, what was investigated, and key constraints

#### Scenario: ADR consequences split into positive and negative
- **GIVEN** an archived change with a `design.md` containing Risks & Trade-offs
- **WHEN** the agent generates an ADR
- **THEN** the Consequences section has a "Positive" subsection listing benefits and a "Negative" subsection listing drawbacks or trade-offs

#### Scenario: ADR includes references with semantic link text
- **GIVEN** an ADR generated for a decision about a specific capability
- **WHEN** the agent writes the ADR
- **THEN** the References section includes links with descriptive text (e.g., `[Spec: release-workflow]`) and NOT raw file paths as link text

#### Scenario: Archive without design.md produces no ADRs
- **GIVEN** an archived change with no `design.md` file
- **WHEN** the developer runs `/opsx:docs`
- **THEN** no ADRs are generated for that archive and no errors are raised

#### Scenario: Archive with prose-only Decisions section skipped
- **GIVEN** an archived change with a `design.md` that has `## Architecture Decisions` containing only prose like "No architectural changes" and no pipe-delimited table
- **WHEN** the developer runs `/opsx:docs`
- **THEN** no ADRs are generated for that archive

#### Scenario: Archive with non-Decisions table skipped
- **GIVEN** an archived change with a `design.md` that has a `## Success Metrics` table (columns: #, Metric, Target) but no valid Decisions table
- **WHEN** the developer runs `/opsx:docs`
- **THEN** no ADRs are generated for that archive — the Success Metrics table is NOT misinterpreted as decisions

#### Scenario: Stale ADR index deleted
- **GIVEN** `docs/decisions/README.md` exists from a previous run
- **WHEN** the agent runs `/opsx:docs`
- **THEN** the agent deletes `docs/decisions/README.md`

#### Scenario: Agent reads ADR template
- **GIVEN** an ADR template exists at `openspec/schemas/opsx-enhanced/templates/docs/adr.md`
- **WHEN** the agent generates an ADR
- **THEN** the agent reads the template and uses it as the structural format for the output

#### Scenario: Slug generated deterministically
- **GIVEN** a Decision column text of "Sync marketplace.json in same convention"
- **WHEN** the agent derives the slug
- **THEN** the slug is `sync-marketplace-json-in-same-convention` (dots become hyphens, consecutive hyphens collapsed)

#### Scenario: Manual ADRs preserved during regeneration
- **GIVEN** `docs/decisions/adr-M001-init-model-invocable.md` exists
- **WHEN** the agent regenerates ADRs via `/opsx:docs`
- **THEN** the file `adr-M001-init-model-invocable.md` is NOT deleted or overwritten

## ADDED Requirements

### Requirement: Manual ADR Preservation
The `/opsx:docs` command SHALL preserve manual ADRs during regeneration. Manual ADRs are files in `docs/decisions/` matching the pattern `adr-M*.md`. They use the `adr-MNNN-slug.md` naming convention (M prefix + 3-digit zero-padded number) to distinguish them from generated ADRs (`adr-NNN-slug.md`). The agent SHALL NOT delete, overwrite, or renumber manual ADR files. Manual ADRs SHALL be included in the `docs/README.md` Key Design Decisions table after all generated ADRs, with links like `[ADR-M001](decisions/adr-M001-init-model-invocable.md)`. The agent SHALL extract the Decision and Rationale from the manual ADR's `## Decision` and `## Rationale` sections for the table.

**User Story:** As a contributor I want to create ADRs for decisions made outside the archive workflow (e.g., during bootstrap recovery), so that important architectural decisions are not lost when docs are regenerated.

#### Scenario: Manual ADR appears in README table
- **GIVEN** `docs/decisions/adr-M001-init-model-invocable.md` exists with `## Decision` and `## Rationale` sections
- **WHEN** the agent generates `docs/README.md`
- **THEN** the Key Design Decisions table includes a row for ADR-M001 with the decision text, rationale, and a link to the file

#### Scenario: Multiple manual ADRs ordered by number
- **GIVEN** `adr-M001-first.md` and `adr-M002-second.md` exist in `docs/decisions/`
- **WHEN** the agent generates the Key Design Decisions table
- **THEN** ADR-M001 appears before ADR-M002, and both appear after all generated ADRs

## Edge Cases

- **Slug derivation**: The slug is always derived from the original English Decision column text in design.md, never from translated content. This ensures stable file names across language changes.
- **No archives with design.md**: The agent SHALL skip ADR generation entirely and create no `docs/decisions/` directory.
- **Decisions table format variants**: The agent SHALL handle both 3-column (`Decision | Rationale | Alternatives`) and 4-column (`# | Decision | Rationale | Alternatives Considered`) formats.
- **Empty Decisions table**: The agent SHALL skip that archive's design.md for ADR generation.
- **Prose-only Decisions section**: If `## Decisions` or `## Architecture Decisions` contains only prose with no pipe-delimited table, the agent SHALL skip that archive entirely — even if other tables exist elsewhere in the same design.md.
- **No negative consequences identifiable**: If the design.md Risks section has no content relevant to a specific decision, the agent SHALL write "No significant negative consequences identified" under the Negative subsection rather than leaving it empty.
- **No related specs identifiable**: If a decision is cross-cutting and not tied to a specific capability spec, the References section SHALL link to the constitution or the most relevant architectural spec.
- **Manual ADR with missing sections**: If a manual ADR lacks `## Decision` or `## Rationale`, the agent SHALL use the ADR title (from `# ADR-MNNN:` heading) as the decision text and leave the rationale column empty in the README table.

## Assumptions

- Archive artifacts (design.md, research.md) follow the templates defined in the opsx-enhanced schema. <!-- ASSUMPTION: Artifacts created by schema-driven workflow -->
- The ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` defines the expected output structure. <!-- ASSUMPTION: Template created as part of this change -->
