## ADDED Requirements

### Requirement: ADR Archive Backlinks
Each generated ADR SHALL include a link to its source archive directory in the References section. The link SHALL use the format `[Archive: <archive-name>](../../openspec/changes/archive/<archive-dir>/)` where `<archive-name>` is the archive directory name without the date prefix (e.g., `improve-docs-quality` from `2026-03-05-improve-docs-quality`). The archive link SHALL appear as the first reference, before spec links and related ADR links.

**User Story:** As a developer I want ADRs to link back to their source archive, so that I can trace a decision to the full research, proposal, and design context that produced it.

#### Scenario: ADR includes archive backlink
- **GIVEN** an ADR generated from archive `2026-03-05-improve-docs-quality`
- **WHEN** the agent writes the References section
- **THEN** the References section includes `[Archive: improve-docs-quality](../../openspec/changes/archive/2026-03-05-improve-docs-quality/)` as the first reference

#### Scenario: Archive backlink uses short name without date prefix
- **GIVEN** an archive directory named `2026-03-04-release-workflow`
- **WHEN** the agent generates the archive backlink
- **THEN** the link text is `Archive: release-workflow`, not `Archive: 2026-03-04-release-workflow`

### Requirement: ADR Consolidation for Related Decisions
When multiple decisions from the same archive share the same context and motivation, the agent SHALL consolidate them into a single ADR with numbered sub-decisions in the Decision section, rather than generating one ADR per table row.

**Consolidation heuristics:** The agent SHALL apply these rules to determine whether decisions should be consolidated:
1. Decisions MUST come from the same archive's `design.md` Decisions table.
2. Decisions SHALL be consolidated when they share the same primary motivation — i.e., they are sub-parts of a single architectural choice rather than independent decisions.
3. When an archive represents a single-topic change (e.g., a rename, a single feature addition) and its Decisions table has 3 or more rows, the agent SHALL consolidate all decisions into one ADR by default.
4. When decisions within an archive address clearly different concerns (e.g., one about naming, another about data migration), they SHALL remain separate ADRs.

**Consolidated ADR format:** The consolidated ADR SHALL:
- Use the overarching decision as the title (derived from the archive name or the most significant decision row)
- List individual sub-decisions as a numbered list in the Decision section
- Include rationale for each sub-decision inline
- Combine alternatives from all consolidated rows into one Alternatives Considered section
- Merge consequences across all consolidated decisions

**Numbering impact:** Consolidated ADRs reduce the total ADR count. Each consolidated group gets one sequential number instead of one per row. This means ADR numbers will change when consolidation is first applied — a one-time full regeneration is required.

**User Story:** As a reader of ADRs I want related sub-decisions grouped into a single record, so that I see one coherent decision rather than five fragments that share the same context.

#### Scenario: Single-topic archive with 5 decisions consolidated into 1 ADR
- **GIVEN** an archive `2026-03-23-rename-init-to-setup` with a Decisions table containing 5 rows: "Use setup as new name", "Leave archives unchanged", "Leave CHANGELOG unchanged", "Leave ADRs unchanged", "git mv for directory rename"
- **WHEN** the agent generates ADRs
- **THEN** the agent produces 1 ADR titled "Rename init skill to setup" with 5 numbered sub-decisions in the Decision section

#### Scenario: Mixed-concern archive keeps separate ADRs
- **GIVEN** an archive with decisions about both "use YAML for config" and "add rate limiting to API"
- **WHEN** the agent generates ADRs
- **THEN** the agent produces 2 separate ADRs because the decisions address different concerns

#### Scenario: Archive with 2 decisions remains unconsolidated
- **GIVEN** an archive with a Decisions table containing exactly 2 rows
- **WHEN** the agent generates ADRs
- **THEN** the agent generates 2 separate ADRs (the 3+ row threshold for auto-consolidation is not met)
- **AND** the agent MAY still consolidate if the 2 decisions clearly share the same topic

## MODIFIED Requirements

### Requirement: Generate Architecture Decision Records
The `/opsx:docs` command SHALL generate Architecture Decision Records (ADRs) from the `## Decisions` tables found in all archived `design.md` files at `openspec/changes/archive/*/design.md`. Each row in a Decisions table SHALL become one ADR file at `docs/decisions/adr-NNN-<slug>.md` where NNN is a zero-padded sequential number, unless consolidated with related decisions from the same archive (see "ADR Consolidation for Related Decisions" requirement). The agent SHALL read the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` for the expected output format. ADR numbering SHALL be global and sequential across all archives, sorted chronologically by archive date prefix (`YYYY-MM-DD`). Within each archive, decisions SHALL be numbered in table row order (or consolidated group order). The `docs/decisions/` directory SHALL be created if it does not exist. When regenerating, the agent SHALL NOT delete files matching `adr-M*.md` — these are manual ADRs (see below).

**Incremental ADR generation:** The agent SHALL support incremental ADR generation by default. Before generating ADRs, the agent SHALL:
1. Glob `docs/decisions/adr-[0-9]*.md` to find existing generated ADR files (excluding manual `adr-M*.md`).
2. Determine the highest existing ADR number from the filenames.
3. Glob `openspec/changes/archive/*/design.md` and sort archives chronologically.
4. Identify which archives produced existing ADRs by checking if ADR files reference each archive (via the archive backlink in References).
5. For archives that have NOT yet produced ADRs, check if they contain valid Decisions tables.
6. If new archives with valid Decisions tables exist, generate new ADR files starting from the next sequential number after the highest existing.
7. If no new archives with Decisions tables exist, skip ADR generation entirely.

**First run:** When no ADR files exist yet, all archives with valid Decisions tables SHALL be processed (equivalent to full generation).

The agent SHALL NOT generate an ADR index at `docs/decisions/README.md`. ADR discovery is handled by inline links in the `docs/README.md` Key Design Decisions table. If `docs/decisions/README.md` exists from a previous run, the agent SHALL delete it.

**Skip rule for invalid Decisions sections:** After reading each `design.md`, the agent SHALL verify that a markdown table with pipe delimiters exists under a heading containing "Decisions" (e.g., `## Decisions` or `## Architecture Decisions`). A valid Decisions table MUST have columns that include "Decision" and "Rationale". If the section contains only prose (e.g., "No architectural changes"), a non-Decisions table (e.g., Success Metrics), or no table at all, the agent SHALL skip that archive for ADR generation.

**Enrichment:** For each archive, the agent SHALL read the FULL `design.md` — not just the Decisions table. The agent SHALL read the `## Context`, `## Architecture & Components`, and `## Risks & Trade-offs` sections to provide rich source material for ADR Context and Consequences sections. Additionally, the agent SHALL read `research.md` (Sections 2 and 3: External Research and Approaches) and `proposal.md` (`## Why`) from the same archive if they exist. The agent SHALL NOT rely on data loaded during earlier steps (e.g., Step 2) — ADR generation must independently read all source materials.

Each ADR SHALL include:
- **Status**: "Accepted" with the archive date
- **Context**: From the `design.md` Context section, enriched with `research.md` Approaches and findings from the same archive where available. The Context section SHALL be at least 4-6 sentences. It SHALL include what motivated the decision (the problem being solved), what was investigated or researched, and key constraints or trade-offs that shaped the decision. The agent SHALL NOT write thin Context sections like "we chose X over Y because Z".
- **Decision**: From the Decisions table "Decision" column (or consolidated sub-decisions list)
- **Rationale**: From the Decisions table "Rationale" column
- **Alternatives Considered**: From the Decisions table "Alternatives" column, expanded into bullets
- **Consequences**: Split into two subsections:
  - **Positive**: Benefits of this decision, derived from the rationale, context, and positive outcomes
  - **Negative**: Drawbacks, risks, or trade-offs, derived from the `design.md` "Risks & Trade-offs" section filtered to relevance for this specific decision where possible
- **References**: Links to related resources using semantic link text. The first reference SHALL be the source archive backlink (see "ADR Archive Backlinks" requirement). The agent SHALL use descriptive text like `[Spec: three-layer-architecture](path)`, NOT raw file paths as link text like `[../../openspec/specs/three-layer-architecture/spec.md](path)`. Include the relevant spec file, related ADRs if the decision connects to other decisions, and the GitHub Issue if applicable.

**References determination:** The agent SHALL determine which specs are relevant to each decision by checking the archive's `specs/` subdirectory to find which capabilities were affected. The agent SHALL link to those baseline specs using semantic link text: `[Spec: capability-name](../../openspec/specs/capability/spec.md)`. The agent SHALL cross-reference other ADRs from the same archive when decisions are related. If the `design.md` or `research.md` references GitHub Issues, the agent SHALL include those links too.

The slug SHALL be derived from the Decision column text using this deterministic algorithm:
1. Lowercase the entire string
2. Replace any character that is NOT in `[a-z0-9]` with a hyphen
3. Collapse consecutive hyphens into a single hyphen
4. Trim leading and trailing hyphens
5. Truncate to 50 characters
6. Trim trailing hyphens again (in case truncation split a word)

For consolidated ADRs, the slug SHALL be derived from the overarching decision title (e.g., "Rename init skill to setup" → `rename-init-skill-to-setup`), not from individual sub-decision texts.

**Step independence:** ADR generation SHALL read its own source materials independently. The agent SHALL NOT assume that data loaded during an earlier step (e.g., archive enrichment in Step 2) is still available — steps may execute in separate contexts. This is especially critical for ADR generation, which needs full archive data (design.md, research.md, proposal.md) independently of capability doc generation.

**User Story:** As a developer or contributor I want formal decision records with clear positive and negative consequences and links to related specs, so that I can understand why architectural choices were made, what trade-offs were accepted, and where to find more context.

#### Scenario: ADRs generated from single archive with Decisions table
- **GIVEN** an archived change at `openspec/changes/archive/2026-03-04-release-workflow/` with a `design.md` containing a Decisions table with 4 rows
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent creates ADR files under `docs/decisions/` with split Consequences and References sections (number of files depends on consolidation)

#### Scenario: ADR numbering across multiple archives
- **GIVEN** two archived changes: `2026-03-02-initial-spec` with 3 decisions and `2026-03-04-release-workflow` with 4 decisions (no consolidation applicable)
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the initial-spec decisions are numbered ADR-001 through ADR-003 and the release-workflow decisions are numbered ADR-004 through ADR-007

#### Scenario: Incremental ADR generation for new archive
- **GIVEN** existing ADR files `adr-001` through `adr-049` from previously processed archives
- **AND** a new archive `2026-03-23-improve-docs-efficiency` contains a `design.md` with 3 decisions
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent generates only the new ADR files starting from ADR-050 (or higher, accounting for consolidation)
- **AND** existing ADR files are NOT regenerated or modified

#### Scenario: No new archives skips ADR generation
- **GIVEN** existing ADR files cover all archives with Decisions tables
- **AND** no new archives have been added since the last run
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent skips ADR generation entirely and reports "ADRs are up-to-date"

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

- **Incremental detection ambiguity**: If the agent cannot determine which archives produced existing ADRs (e.g., no archive backlink in older ADR files), it SHALL fall back to full ADR regeneration for that run.
- **Consolidation changes numbering on first run**: When consolidation logic is first applied, existing ADR numbers change. The agent SHALL perform a full ADR regeneration on the first run that applies consolidation (detected by comparing expected consolidated count vs. existing file count).
- **Slug derivation for consolidated ADRs**: The slug is derived from the overarching title, not individual sub-decisions. If the title exceeds 50 characters after slug conversion, it is truncated per the standard algorithm.
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
- Archives are immutable after archiving — existing archive content does not change, ensuring stable ADR numbering for incremental generation. <!-- ASSUMPTION: Core architectural guarantee from archive workflow -->
