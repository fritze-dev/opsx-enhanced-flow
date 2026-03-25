## MODIFIED Requirements

### Requirement: Generate Architecture Overview
The `/opsx:docs` command SHALL generate a cross-cutting architecture overview as a standalone file at `docs/architecture.md` (not as part of `docs/README.md`). The overview content SHALL be synthesized from the project constitution (`openspec/constitution.md`), the three-layer-architecture spec (`openspec/specs/three-layer-architecture/spec.md`), and all generated ADR files at `docs/decisions/adr-*.md`. The architecture overview SHALL include: a "System Architecture" section describing the three-layer model, a "Tech Stack" section from the constitution, and a "Conventions" section from the constitution.

The agent SHALL read the architecture template at `openspec/schemas/opsx-enhanced/templates/docs/architecture.md` for the expected output format.

**Conditional regeneration:** The `docs/architecture.md` SHALL be regenerated only when at least one of the following conditions is met during the current `/opsx:docs` run:
1. No `docs/architecture.md` exists yet (first run).
2. The content of `openspec/constitution.md` (Tech Stack, Architecture Rules, Conventions sections) has diverged from the corresponding sections in the existing `docs/architecture.md`. The agent SHALL read the constitution and compare its key content against the file to detect drift.

If none of these conditions are met, the agent SHALL skip architecture file regeneration and report "architecture.md is up-to-date — no constitution changes detected."

The agent SHALL NOT generate `docs/architecture-overview.md` as a separate file. If this file exists from a previous run, the agent SHALL delete it.

**User Story:** As a developer or contributor I want a focused architecture document that explains the system structure, tech stack, and conventions without being cluttered by decision tables and trade-offs, so that I can quickly understand the project's technical foundation.

#### Scenario: Architecture overview generated as standalone file
- **GIVEN** a constitution at `openspec/constitution.md` with Tech Stack, Architecture Rules, and Conventions sections
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent writes architecture overview content (System Architecture, Tech Stack, Conventions) into `docs/architecture.md`

#### Scenario: Architecture file skipped when no constitution drift
- **GIVEN** `docs/architecture.md` already exists
- **AND** `openspec/constitution.md` has not changed since the last generation
- **WHEN** the agent reaches the architecture generation step
- **THEN** the agent skips regeneration and reports "architecture.md is up-to-date"

#### Scenario: Architecture file regenerated when constitution drifts
- **GIVEN** `docs/architecture.md` already exists
- **AND** `openspec/constitution.md` (Tech Stack, Architecture Rules, or Conventions) has been updated since the last generation
- **WHEN** the agent reaches the architecture generation step
- **THEN** the agent regenerates `docs/architecture.md` to reflect the updated constitution content

#### Scenario: Architecture overview with no three-layer-architecture spec
- **GIVEN** a constitution exists but `openspec/specs/three-layer-architecture/spec.md` does not exist
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent generates a minimal System Architecture section from constitution Architecture Rules only

### Requirement: Generate Decisions Index
The `/opsx:docs` command SHALL generate a decisions index file at `docs/decisions.md` containing the Key Design Decisions table and Notable Trade-offs subsection. The content SHALL be sourced exclusively from ADR files in `docs/decisions/`.

**Key Design Decisions table — ADR-sourced:** The table SHALL be built by reading all ADR files in `docs/decisions/` (both generated `adr-NNN-*.md` and manual `adr-M*.md`). For each ADR, the agent SHALL extract:
- **Decision**: A summary derived from the `## Decision` section content. For consolidated ADRs with numbered sub-decisions, summarize the overarching decision. For single-decision ADRs, use the inline decision text.
- **Rationale**: For generated ADRs, extract the inline rationale from the Decision section (the text after the em-dash `—`). For manual ADRs, extract from the `## Rationale` section if present.
- **ADR link**: Link directly to the ADR file (e.g., `[ADR-001](decisions/adr-001-slug.md)`).

The table SHALL list generated ADRs first (ordered by number), followed by manual ADRs (ordered by M-number). The agent SHALL NOT read `design.md` archives for the Key Design Decisions table — ADR files are the single canonical source. Surface notable trade-offs from ADR Negative Consequences — add a "Notable Trade-offs" subsection if any decisions have significant negative consequences. Include trade-offs that affect documentation consumers or represent meaningful constraints — every ADR with a substantive negative consequence should be represented.

The agent SHALL read the decisions template at `openspec/schemas/opsx-enhanced/templates/docs/decisions.md` for the expected output format.

**Conditional regeneration:** The `docs/decisions.md` SHALL be regenerated only when at least one of the following conditions is met during the current `/opsx:docs` run:
1. Any ADR was created in this run.
2. No `docs/decisions.md` exists yet (first run).

If none of these conditions are met, the agent SHALL skip decisions file regeneration and report "decisions.md is up-to-date — no ADR changes detected."

**User Story:** As a developer I want a dedicated decisions index that lists all architectural decisions with rationale and trade-offs, so that I can quickly review the project's decision history without scrolling through the main README.

#### Scenario: Decisions index generated from ADR files
- **GIVEN** ADR files exist at `docs/decisions/adr-001-*.md` through `adr-026-*.md`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent writes `docs/decisions.md` with a Key Design Decisions table and Notable Trade-offs subsection

#### Scenario: Decisions index includes manual ADRs
- **GIVEN** `docs/decisions/adr-M001-init-model-invocable.md` exists
- **AND** generated ADRs exist
- **WHEN** the agent generates `docs/decisions.md`
- **THEN** ADR-M001 appears after all generated ADRs in the table

#### Scenario: Decisions index skipped when no new ADRs
- **GIVEN** `docs/decisions.md` already exists
- **AND** no ADRs were created in this run
- **WHEN** the agent reaches the decisions generation step
- **THEN** the agent skips regeneration and reports "decisions.md is up-to-date"

#### Scenario: No ADR files found
- **GIVEN** no ADR files exist in `docs/decisions/`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent omits `docs/decisions.md` entirely

### Requirement: Generate Documentation Table of Contents
The `/opsx:docs` command SHALL create or update `docs/README.md` as a compact hub/index for all generated documentation. The README SHALL include a brief project description, navigation links to `docs/architecture.md` and `docs/decisions.md`, and a capabilities section. The capabilities section SHALL be grouped by the `category` frontmatter field from baseline specs, rendered as category group headers (title-case). Within each category group, capabilities SHALL be ordered by the `order` frontmatter field (lower first). Capability descriptions in the capabilities table SHALL be concise: max 80 characters or 15 words. Each description SHALL be one short phrase, not a multi-clause sentence.

The agent SHALL read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format.

**Conditional regeneration:** The `docs/README.md` SHALL be regenerated only when at least one of the following conditions is met during the current `/opsx:docs` run:
1. Any capability doc was created or updated (written to disk) in this run.
2. `docs/architecture.md` or `docs/decisions.md` was created or updated in this run.
3. No `docs/README.md` exists yet (first run).

If none of these conditions are met, the agent SHALL skip README regeneration and report "README is up-to-date — no changes detected."

The agent SHALL NOT generate a separate `docs/architecture-overview.md` file. If this file exists from a previous run, the agent SHALL delete it.

**User Story:** As a user I want a compact documentation hub that gives me quick navigation to architecture details, design decisions, and capability docs, so that I can find what I need without scrolling through a monolithic document.

#### Scenario: Compact README hub generated
- **GIVEN** the agent has generated capability docs, `docs/architecture.md`, and `docs/decisions.md`
- **WHEN** the agent updates `docs/README.md`
- **THEN** the README contains navigation links to architecture.md and decisions.md, and a category-grouped capabilities section

#### Scenario: Capabilities grouped by category
- **GIVEN** baseline specs with `category` frontmatter values like `setup`, `change-workflow`, `development`
- **WHEN** the agent generates the capabilities section
- **THEN** capabilities appear under category group headers (e.g., "### Setup", "### Change Workflow"), ordered by `order` within each group

#### Scenario: README regenerated when capability doc written
- **GIVEN** one capability doc was updated in this run
- **AND** `docs/README.md` already exists
- **WHEN** the agent reaches the README generation step
- **THEN** the agent regenerates `docs/README.md`

#### Scenario: README regenerated when sub-files change
- **GIVEN** `docs/decisions.md` was regenerated in this run
- **AND** no capability docs changed
- **WHEN** the agent reaches the README generation step
- **THEN** the agent regenerates `docs/README.md`

#### Scenario: README skipped when no changes detected
- **GIVEN** no capability docs were created or updated
- **AND** neither `docs/architecture.md` nor `docs/decisions.md` was changed
- **AND** `docs/README.md` already exists
- **WHEN** the agent reaches the README generation step
- **THEN** the agent skips README regeneration and reports "README is up-to-date"

#### Scenario: Stale files cleaned up
- **GIVEN** `docs/architecture-overview.md` exists from a previous run
- **WHEN** the agent runs `/opsx:docs`
- **THEN** the agent deletes `docs/architecture-overview.md`

### Requirement: Language-Aware Architecture Overview
The architecture overview content generated at `docs/architecture.md` by `/opsx:docs` SHALL respect the `docs_language` setting from `openspec/config.yaml`. When a non-English language is configured, all section headings (e.g., "System Architecture", "Tech Stack", "Conventions") and descriptive content SHALL be translated to the target language. Product names, commands, and file paths SHALL remain in English.

The decisions index at `docs/decisions.md` SHALL also respect the `docs_language` setting. Table column headers in the Key Design Decisions table SHALL be translated. The README hub navigation text SHALL be translated.

**User Story:** As a non-English-speaking team I want the architecture overview, decisions index, and README hub in my language, so that the full documentation entry point is accessible to my team.

#### Scenario: Architecture overview in configured language
- **GIVEN** `openspec/config.yaml` contains `docs_language: German`
- **AND** a constitution exists
- **WHEN** the developer runs `/opsx:docs`
- **THEN** `docs/architecture.md` SHALL have German headings (e.g., "Systemarchitektur", "Technologie-Stack") and German content
- **AND** product names (OpenSpec, Claude Code) and file paths SHALL remain in English

#### Scenario: Decisions index translated
- **GIVEN** `docs_language: French`
- **WHEN** the agent generates `docs/decisions.md`
- **THEN** column headers SHALL be in French (e.g., "Décision", "Justification")
- **AND** ADR link text (e.g., "ADR-001") SHALL remain in English

## Edge Cases

- **Constitution content in English**: The constitution is always in English. The agent translates when generating the overview, not the constitution itself.
- **No constitution found**: The agent SHALL warn the user and skip architecture overview generation.
- **No three-layer-architecture spec**: The agent SHALL generate a minimal System Architecture section from constitution Architecture Rules only.
- **ADR not yet generated for a decision**: The SKILL.md step ordering ensures ADRs are generated before decisions.md.
- **Manual ADR with missing sections**: If a manual ADR lacks `## Decision` or `## Rationale`, the agent SHALL use the ADR title as the decision text and leave the rationale column empty.
- **Stale file cleanup regardless of regeneration**: The agent SHALL delete `docs/architecture-overview.md` if it exists, even when regeneration is skipped.
- **Generated ADR with inline rationale extraction**: For generated ADRs using the inline-rationale em-dash pattern, the agent SHALL extract the rationale by parsing the text after `—` in each decision item.
- **Old monolithic README**: On first run after this change, the existing monolithic `docs/README.md` is overwritten with the new hub format. Architecture and decisions content moves to their respective files.

## Assumptions

- The constitution at `openspec/constitution.md` is the source of truth for tech stack and conventions. <!-- ASSUMPTION: Constitution maintained by archive workflow -->
- ADR files are always generated before decisions.md generation within a single `/opsx:docs` run (Step 4 before Step 5). <!-- ASSUMPTION: SKILL.md step ordering guarantees this -->
- The new templates at `openspec/schemas/opsx-enhanced/templates/docs/architecture.md` and `templates/docs/decisions.md` define the expected output structures. <!-- ASSUMPTION: Templates created as part of this change -->
