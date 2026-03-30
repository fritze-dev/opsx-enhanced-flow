## MODIFIED Requirements

### Requirement: Generate Architecture Overview
The `/opsx:docs` command SHALL generate a cross-cutting architecture overview as part of the consolidated `docs/README.md` file. The overview content SHALL be synthesized from the project constitution (`openspec/constitution.md`), the three-layer-architecture spec (`openspec/specs/three-layer-architecture/spec.md`), and all `## Decisions` tables found across archived `design.md` files in `openspec/changes/archive/*/design.md`. The architecture overview SHALL include: a "System Architecture" section describing the three-layer model, a "Tech Stack" section from the constitution, a "Key Design Decisions" section aggregating notable decisions across all changes (deduplicated), and a "Conventions" section from the constitution. The Key Design Decisions table SHALL include an "ADR" column linking directly to the corresponding ADR file (e.g., `[ADR-001](decisions/adr-001-slug.md)`) instead of a "Source" column. The table SHALL include all decisions from archived design.md files. Additionally, the table SHALL include manual ADRs matching `docs/decisions/adr-M*.md`, listed after all generated ADRs, with links like `[ADR-M001](decisions/adr-M001-init-model-invocable.md)`. The agent SHALL extract the Decision and Rationale from the manual ADR's `## Decision` and `## Rationale` sections for the table. The overview SHALL surface notable trade-offs from ADR Consequences sections — if a decision has a significant negative consequence, it SHALL be mentioned as a brief note in the table or in a "Notable Trade-offs" subsection below the table. The Notable Trade-offs subsection SHALL include trade-offs that affect documentation consumers or represent meaningful constraints. Every ADR with a substantive negative consequence SHOULD be represented. The document SHALL be written in user-facing language. The agent SHALL read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format.

**Conditional regeneration:** The `docs/README.md` SHALL be regenerated only when at least one of the following conditions is met during the current `/opsx:docs` run:
1. Any capability doc was created or updated (written to disk) in this run.
2. Any ADR was created in this run.
3. No `docs/README.md` exists yet (first run).
4. The content of `openspec/constitution.md` (Tech Stack, Architecture Rules, Conventions sections) has diverged from the corresponding sections in the existing `docs/README.md`. The agent SHALL read the constitution and compare its key content against the README to detect drift.

If none of these conditions are met, the agent SHALL skip README regeneration and report "README is up-to-date — no capability or ADR changes detected."

The agent SHALL NOT generate `docs/architecture-overview.md` as a separate file. If this file exists from a previous run, the agent SHALL delete it.

**User Story:** As a developer or contributor I want a single document that explains the system architecture and key decisions with direct links to ADRs and visible trade-offs, so that I can understand the project structure and the reasoning behind it without navigating multiple files.

#### Scenario: Architecture overview generated as part of consolidated README
- **GIVEN** a constitution at `openspec/constitution.md` with Tech Stack and Architecture Rules sections
- **AND** archived changes with `design.md` files containing Decisions tables
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent writes architecture overview content (System Architecture, Tech Stack, Key Design Decisions, Conventions) into `docs/README.md`

#### Scenario: Architecture overview with no archived design artifacts
- **GIVEN** a constitution exists but no archived changes have `design.md` files
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent generates architecture content in `docs/README.md` with System Architecture, Tech Stack, and Conventions sections, omitting Key Design Decisions

#### Scenario: Design decisions table includes ADR links
- **GIVEN** archived design.md files with Decisions tables
- **AND** ADR files generated at `docs/decisions/adr-NNN-slug.md`
- **WHEN** the agent generates the Key Design Decisions table
- **THEN** each row includes an ADR link column pointing to the corresponding ADR file

#### Scenario: Manual ADRs included in design decisions table
- **GIVEN** `docs/decisions/adr-M001-init-model-invocable.md` exists with `## Decision` and `## Rationale` sections
- **AND** generated ADRs exist at `docs/decisions/adr-001-*.md` through `adr-033-*.md`
- **WHEN** the agent generates the Key Design Decisions table
- **THEN** ADR-M001 appears as a row after all generated ADRs, with the decision text, rationale, and a link to the file

#### Scenario: Trade-offs surfaced comprehensively from ADR consequences
- **GIVEN** ADR Consequences sections contain significant negative consequences across multiple ADRs
- **WHEN** the agent generates the Key Design Decisions section
- **THEN** the Notable Trade-offs subsection includes trade-offs that affect documentation consumers or represent meaningful constraints — every ADR with a substantive negative consequence is represented

#### Scenario: Stale architecture-overview.md deleted
- **GIVEN** `docs/architecture-overview.md` exists from a previous run
- **WHEN** the agent runs `/opsx:docs`
- **THEN** the agent deletes `docs/architecture-overview.md`

#### Scenario: README skipped when no changes detected
- **GIVEN** no capability docs were created or updated in this run
- **AND** no ADRs were created in this run
- **AND** `docs/README.md` already exists
- **WHEN** the agent reaches the README generation step
- **THEN** the agent skips README regeneration and reports "README is up-to-date"

#### Scenario: README regenerated when new capability doc written
- **GIVEN** one capability doc was updated in this run
- **AND** `docs/README.md` already exists
- **WHEN** the agent reaches the README generation step
- **THEN** the agent regenerates `docs/README.md` to reflect the updated capability

#### Scenario: README regenerated on first run
- **GIVEN** no `docs/README.md` exists
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent generates `docs/README.md`

#### Scenario: README regenerated when constitution content drifted
- **GIVEN** no capability docs or ADRs were changed in this run
- **AND** `docs/README.md` already exists
- **AND** `openspec/constitution.md` (Tech Stack, Architecture Rules, or Conventions) has been updated since the last README generation
- **WHEN** the agent reaches the README generation step
- **THEN** the agent regenerates `docs/README.md` to reflect the updated constitution content

### Requirement: Generate Documentation Table of Contents
The `/opsx:docs` command SHALL create or update `docs/README.md` as the single entry point for all generated documentation. The README SHALL include the architecture overview content (System Architecture, Tech Stack, Key Design Decisions with ADR links, Conventions) followed by a capabilities section. The capabilities section SHALL be grouped by the `category` frontmatter field from baseline specs, rendered as category group headers (title-case). Within each category group, capabilities SHALL be ordered by the `order` frontmatter field (lower first). The Key Design Decisions table SHALL include an "ADR" column linking directly to the corresponding ADR file instead of a "Source" column. The README SHALL surface notable trade-offs from ADR Consequences for the most significant decisions. The `docs/README.md` SHALL be regenerated when capability docs or ADRs change, as specified by the conditional regeneration logic in the "Generate Architecture Overview" requirement. The agent SHALL read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format. Capability descriptions in the capabilities table SHALL be concise: max 80 characters or 15 words. Each description SHALL be one short phrase, not a multi-clause sentence.

The agent SHALL NOT generate a separate `docs/architecture-overview.md` file. The agent SHALL NOT generate a separate `docs/decisions/README.md` file. If either file exists from a previous run, the agent SHALL delete it.

**User Story:** As a user I want a single documentation entry point that gives me the architecture overview, lists all capabilities grouped by workflow phase, and links to ADRs inline, so that I don't have to navigate between multiple index files.

#### Scenario: Consolidated README generated
- **GIVEN** the agent has generated capability docs and ADR files
- **WHEN** the agent updates `docs/README.md`
- **THEN** the README contains System Architecture, Tech Stack, Key Design Decisions (with ADR links), Conventions, and a category-grouped capabilities section — all in one file

#### Scenario: Stale files cleaned up
- **GIVEN** `docs/architecture-overview.md` and `docs/decisions/README.md` exist from a previous run
- **WHEN** the agent generates `docs/README.md`
- **THEN** the agent deletes `docs/architecture-overview.md` and `docs/decisions/README.md`

#### Scenario: Capabilities grouped by category
- **GIVEN** baseline specs with `category` frontmatter values like `setup`, `change-workflow`, `development`
- **WHEN** the agent generates the capabilities section
- **THEN** capabilities appear under category group headers (e.g., "### Setup", "### Change Workflow"), ordered by `order` within each group

#### Scenario: Capabilities without category appear in Other group
- **GIVEN** a baseline spec with no `category` frontmatter
- **WHEN** the agent generates the capabilities section
- **THEN** the capability appears under an "Other" group header

#### Scenario: Capability descriptions are concise
- **GIVEN** baseline specs with varying description lengths
- **WHEN** the agent generates the capabilities table
- **THEN** each description is at most 80 characters or 15 words — one short phrase, not a multi-clause sentence

#### Scenario: Design decisions table includes ADR links
- **GIVEN** ADR files have been generated at `docs/decisions/adr-NNN-slug.md`
- **WHEN** the agent generates the Key Design Decisions table
- **THEN** each row includes an ADR link column pointing to the corresponding ADR file

#### Scenario: Notable trade-offs surfaced
- **GIVEN** ADR Consequences sections contain significant negative consequences
- **WHEN** the agent generates the Key Design Decisions section
- **THEN** notable trade-offs are surfaced as brief notes in the table or a subsection

## Edge Cases

- **Constitution content in English**: The constitution is always in English. The agent translates when generating the overview, not the constitution itself.
- **No constitution found**: The agent SHALL warn the user and skip architecture overview generation.
- **No three-layer-architecture spec**: The agent SHALL generate a minimal System Architecture section from constitution Architecture Rules only.
- **ADR not yet generated for a decision**: If ADR generation runs after overview generation within the same `/opsx:docs` run, the agent SHALL generate ADRs first, then reference them in the overview. The SKILL.md step ordering ensures this.
- **Manual ADR with missing sections**: If a manual ADR lacks `## Decision` or `## Rationale`, the agent SHALL use the ADR title as the decision text and leave the rationale column empty.
- **Stale file cleanup regardless of regeneration**: The agent SHALL delete `docs/architecture-overview.md` and `docs/decisions/README.md` if they exist, even when README regeneration is skipped (cleanup is independent of conditional regeneration).

## Assumptions

- The constitution at `openspec/constitution.md` is the source of truth for tech stack and conventions. <!-- ASSUMPTION: Constitution maintained by archive workflow -->
- The consolidated README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` defines the expected output structure. <!-- ASSUMPTION: Template created as part of doc-ecosystem change -->
