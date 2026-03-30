## MODIFIED Requirements

### Requirement: Generate Architecture Decision Records
The `/opsx:docs` command SHALL generate Architecture Decision Records (ADRs) from the `## Decisions` tables found in all archived `design.md` files at `openspec/changes/archive/*/design.md`. Each row in a Decisions table SHALL become one ADR file at `docs/decisions/adr-NNN-<slug>.md` where NNN is a zero-padded sequential number. The agent SHALL read the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` for the expected output format. ADR numbering SHALL be global and sequential across all archives, sorted chronologically by archive date prefix (`YYYY-MM-DD`). Within each archive, decisions SHALL be numbered in table row order. ADRs SHALL be fully regenerated on each run (not incremental). The `docs/decisions/` directory SHALL be created if it does not exist.

The agent SHALL NOT generate an ADR index at `docs/decisions/README.md`. ADR discovery is handled by inline links in the `docs/README.md` Key Design Decisions table. If `docs/decisions/README.md` exists from a previous run, the agent SHALL delete it.

Each ADR SHALL include:
- **Status**: "Accepted" with the archive date
- **Context**: From the `design.md` Context section, enriched with `research.md` Approaches and findings from the same archive where available. The Context section SHALL be at least 4-6 sentences. It SHALL include what motivated the decision (the problem being solved), what was investigated or researched, and key constraints or trade-offs that shaped the decision. The agent SHALL NOT write thin Context sections like "we chose X over Y because Z".
- **Decision**: From the Decisions table "Decision" column
- **Rationale**: From the Decisions table "Rationale" column
- **Alternatives Considered**: From the Decisions table "Alternatives" column, expanded into bullets
- **Consequences**: Split into two subsections:
  - **Positive**: Benefits of this decision, derived from the rationale, context, and positive outcomes
  - **Negative**: Drawbacks, risks, or trade-offs, derived from the `design.md` "Risks & Trade-offs" section filtered to relevance for this specific decision where possible
- **References**: Links to related resources including the relevant spec file (`../../openspec/specs/<capability>/spec.md`), related ADRs if the decision connects to other decisions, and the GitHub Issue if applicable

The slug SHALL be derived from the Decision column text: lowercased, spaces replaced with hyphens, truncated to 50 characters, trailing hyphens stripped.

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

#### Scenario: ADR includes references
- **GIVEN** an ADR generated for a decision about a specific capability
- **WHEN** the agent writes the ADR
- **THEN** the References section includes a link to the relevant spec file and any related ADRs

#### Scenario: Archive without design.md produces no ADRs
- **GIVEN** an archived change with no `design.md` file
- **WHEN** the developer runs `/opsx:docs`
- **THEN** no ADRs are generated for that archive and no errors are raised

#### Scenario: Stale ADR index deleted
- **GIVEN** `docs/decisions/README.md` exists from a previous run
- **WHEN** the agent runs `/opsx:docs`
- **THEN** the agent deletes `docs/decisions/README.md`

#### Scenario: Agent reads ADR template
- **GIVEN** an ADR template exists at `openspec/schemas/opsx-enhanced/templates/docs/adr.md`
- **WHEN** the agent generates an ADR
- **THEN** the agent reads the template and uses it as the structural format for the output

## Edge Cases

- **No archives with design.md**: The agent SHALL skip ADR generation entirely and create no `docs/decisions/` directory.
- **Decisions table format variants**: The agent SHALL handle both 3-column (`Decision | Rationale | Alternatives`) and 4-column (`# | Decision | Rationale | Alternatives Considered`) formats.
- **Empty Decisions table**: The agent SHALL skip that archive's design.md for ADR generation.
- **No negative consequences identifiable**: If the design.md Risks section has no content relevant to a specific decision, the agent SHALL write "No significant negative consequences identified" under the Negative subsection rather than leaving it empty.
- **No related specs identifiable**: If a decision is cross-cutting and not tied to a specific capability spec, the References section SHALL link to the constitution or the most relevant architectural spec.

## Assumptions

- Archive artifacts (design.md, research.md) follow the templates defined in the opsx-enhanced schema. <!-- ASSUMPTION: Artifacts created by schema-driven workflow -->
- The ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` defines the expected output structure. <!-- ASSUMPTION: Template created as part of this change -->
