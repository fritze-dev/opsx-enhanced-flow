## MODIFIED Requirements

### Requirement: Generate Architecture Decision Records
The `/opsx:docs` command SHALL generate Architecture Decision Records (ADRs) from the `## Decisions` tables found in all archived `design.md` files at `openspec/changes/archive/*/design.md`. Each row in a Decisions table SHALL become one ADR file at `docs/decisions/adr-NNN-<slug>.md` where NNN is a zero-padded sequential number. The agent SHALL read the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` for the expected output format. ADR numbering SHALL be global and sequential across all archives, sorted chronologically by archive date prefix (`YYYY-MM-DD`). Within each archive, decisions SHALL be numbered in table row order. ADRs SHALL be fully regenerated on each run (not incremental). The `docs/decisions/` directory SHALL be created if it does not exist. When regenerating, the agent SHALL NOT delete files matching `adr-M*.md` — these are manual ADRs (see below).

The agent SHALL NOT generate an ADR index at `docs/decisions/README.md`. ADR discovery is handled by inline links in the `docs/README.md` Key Design Decisions table. If `docs/decisions/README.md` exists from a previous run, the agent SHALL delete it.

**Skip rule for invalid Decisions sections:** After reading each `design.md`, the agent SHALL verify that a markdown table with pipe delimiters exists under a heading containing "Decisions" (e.g., `## Decisions` or `## Architecture Decisions`). A valid Decisions table MUST have columns that include "Decision" and "Rationale". If the section contains only prose (e.g., "No architectural changes"), a non-Decisions table (e.g., Success Metrics), or no table at all, the agent SHALL skip that archive for ADR generation.

**Enrichment:** For each archive, the agent SHALL read the FULL `design.md` — not just the Decisions table. The agent SHALL read the `## Context`, `## Architecture & Components`, and `## Risks & Trade-offs` sections to provide rich source material for ADR Context and Consequences sections. Additionally, the agent SHALL read `research.md` (Sections 2 and 3: External Research and Approaches) and `proposal.md` (`## Why`) from the same archive if they exist. The agent SHALL NOT rely on data loaded during earlier steps (e.g., Step 2) — ADR generation must independently read all source materials.

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

**References determination:** The agent SHALL determine which specs are relevant to each decision by checking the archive's `specs/` subdirectory to find which capabilities were affected. The agent SHALL link to those baseline specs using semantic link text: `[Spec: capability-name](../../openspec/specs/capability/spec.md)`. The agent SHALL cross-reference other ADRs from the same archive when decisions are related. If the `design.md` or `research.md` references GitHub Issues, the agent SHALL include those links too.

The slug SHALL be derived from the Decision column text using this deterministic algorithm:
1. Lowercase the entire string
2. Replace any character that is NOT in `[a-z0-9]` with a hyphen
3. Collapse consecutive hyphens into a single hyphen
4. Trim leading and trailing hyphens
5. Truncate to 50 characters
6. Trim trailing hyphens again (in case truncation split a word)

**Step independence:** ADR generation SHALL read its own source materials independently. The agent SHALL NOT assume that data loaded during an earlier step (e.g., archive enrichment in Step 2) is still available — steps may execute in separate contexts. This is especially critical for ADR generation, which needs full archive data (design.md, research.md, proposal.md) independently of capability doc generation.

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

#### Scenario: ADR enrichment reads are self-contained
- **GIVEN** an archived change with `design.md`, `research.md`, and `proposal.md`
- **WHEN** ADR generation runs in a separate context (e.g., delegated to a subagent)
- **THEN** the agent independently reads all three files from the archive
- **AND** the ADR Context section has the same depth and detail as when running in the main context

#### Scenario: References determined from archive specs directory
- **GIVEN** an archived change at `openspec/changes/archive/2026-03-04-release-workflow/` with `specs/release-workflow/` and `specs/user-docs/` subdirectories
- **WHEN** the agent generates ADRs for decisions from that archive
- **THEN** the References section includes `[Spec: release-workflow]` and `[Spec: user-docs]` links pointing to the baseline specs

## Edge Cases

- **Slug derivation**: The slug is always derived from the original English Decision column text in design.md, never from translated content. This ensures stable file names across language changes.
- **No archives with design.md**: The agent SHALL skip ADR generation entirely and create no `docs/decisions/` directory.
- **Decisions table format variants**: The agent SHALL handle both 3-column (`Decision | Rationale | Alternatives`) and 4-column (`# | Decision | Rationale | Alternatives Considered`) formats.
- **Empty Decisions table**: The agent SHALL skip that archive's design.md for ADR generation.
- **Prose-only Decisions section**: If `## Decisions` or `## Architecture Decisions` contains only prose with no pipe-delimited table, the agent SHALL skip that archive entirely — even if other tables exist elsewhere in the same design.md.
- **No negative consequences identifiable**: If the design.md Risks section has no content relevant to a specific decision, the agent SHALL write "No significant negative consequences identified" under the Negative subsection rather than leaving it empty.
- **No related specs identifiable**: If a decision is cross-cutting and not tied to a specific capability spec, the References section SHALL link to the constitution or the most relevant architectural spec.
- **Manual ADR with missing sections**: If a manual ADR lacks `## Decision` or `## Rationale`, the agent SHALL use the ADR title (from `# ADR-MNNN:` heading) as the decision text and leave the rationale column empty in the README table.
- **Archive without research.md or proposal.md**: The agent SHALL still generate ADRs using only `design.md` data. Missing enrichment files reduce Context depth but do not prevent generation.

## Assumptions

- Archive artifacts (design.md, research.md, proposal.md) follow the templates defined in the opsx-enhanced schema. <!-- ASSUMPTION: Artifacts created by schema-driven workflow -->
- The ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` defines the expected output structure. <!-- ASSUMPTION: Template created as part of doc-ecosystem change -->
