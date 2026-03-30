## MODIFIED Requirements

### Requirement: Generate Architecture Overview
The `/opsx:docs` command SHALL generate a cross-cutting architecture overview as part of the consolidated `docs/README.md` file. The overview content SHALL be synthesized from the project constitution (`openspec/constitution.md`), the three-layer-architecture spec (`openspec/specs/three-layer-architecture/spec.md`), and all `## Decisions` tables found across archived `design.md` files in `openspec/changes/archive/*/design.md`. The architecture overview SHALL include: a "System Architecture" section describing the three-layer model, a "Tech Stack" section from the constitution, a "Key Design Decisions" section aggregating notable decisions across all changes (deduplicated), and a "Conventions" section from the constitution. The Key Design Decisions table SHALL include an "ADR" column linking directly to the corresponding ADR file (e.g., `[ADR-001](decisions/adr-001-slug.md)`) instead of a "Source" column. The table SHALL include all decisions from archived design.md files. The overview SHALL surface notable trade-offs from ADR Consequences sections — if a decision has a significant negative consequence, it SHALL be mentioned as a brief note in the table or in a "Notable Trade-offs" subsection below the table. The document SHALL be written in user-facing language. The content SHALL be regenerated fully on each run of `/opsx:docs`. The agent SHALL read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format.

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
- **THEN** each row includes an "ADR" column with a link to the corresponding ADR file

#### Scenario: Trade-offs surfaced from ADR consequences
- **GIVEN** an ADR with a significant negative consequence (e.g., "reduced defense-in-depth")
- **WHEN** the agent generates the Key Design Decisions section
- **THEN** the trade-off is mentioned either as a note in the table row or in a "Notable Trade-offs" subsection

#### Scenario: Stale architecture-overview.md deleted
- **GIVEN** `docs/architecture-overview.md` exists from a previous run
- **WHEN** the agent runs `/opsx:docs`
- **THEN** the agent deletes `docs/architecture-overview.md`

## Edge Cases

- **No constitution found**: The agent SHALL warn the user and skip architecture overview generation.
- **No three-layer-architecture spec**: The agent SHALL generate a minimal System Architecture section from constitution Architecture Rules only.
- **ADR not yet generated for a decision**: If ADR generation runs after overview generation within the same `/opsx:docs` run, the agent SHALL generate ADRs first, then reference them in the overview. The SKILL.md step ordering ensures this.

## Assumptions

- The constitution at `openspec/constitution.md` is the source of truth for tech stack and conventions. <!-- ASSUMPTION: Constitution maintained by archive workflow -->
- The consolidated README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` defines the expected output structure. <!-- ASSUMPTION: Template created as part of this change -->
