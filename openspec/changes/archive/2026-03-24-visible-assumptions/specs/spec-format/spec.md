## ADDED Requirements

### Requirement: Assumption Marker Format

Specs and design artifacts SHALL mark assumptions as a visible list item describing the assumption, followed by an HTML comment tag for machine parsing. The format SHALL be: `- Visible assumption text. <!-- ASSUMPTION: short tag -->`. The visible text SHALL be a complete, readable statement of the assumption. The HTML comment tag SHALL be a brief identifier for preflight grep.

Assumptions written entirely inside an HTML comment with no visible text (e.g., `<!-- ASSUMPTION: full text here -->`) are invisible in Markdown preview and SHALL be flagged as format violations during preflight.

The `## Assumptions` section at the end of specs and design documents SHALL collect all assumptions using this format. If no assumptions were made, the section SHALL state "No assumptions made."

**User Story:** As a reviewer I want assumptions to be visible in Markdown preview, so that I can audit them during review without reading raw source.

#### Scenario: Assumption written in correct format
- **GIVEN** a spec author documenting an assumption about external API behavior
- **WHEN** they write the assumption in the `## Assumptions` section
- **THEN** it SHALL use the format `- External API returns paginated results. <!-- ASSUMPTION: Pagination support -->`
- **AND** the text "External API returns paginated results." SHALL be visible in GitHub and IDE Markdown preview

#### Scenario: Invisible assumption is flagged as format violation
- **GIVEN** a spec containing only `<!-- ASSUMPTION: External API returns paginated results -->`
- **AND** no visible list item accompanies the HTML comment tag
- **WHEN** the spec is reviewed during preflight
- **THEN** the preflight check SHALL flag the invisible assumption as a format violation

#### Scenario: No assumptions section states explicitly
- **GIVEN** a spec where the author made no assumptions
- **WHEN** the `## Assumptions` section is written
- **THEN** it SHALL contain the text "No assumptions made." instead of being left empty

## Assumptions

- The OpenSpec CLI's programmatic archive merge expects baseline specs to use `## Purpose` + `## Requirements` format. <!-- ASSUMPTION: CLI merge format expectation -->
- The sync process (`/opsx:sync`) is agent-driven and performs intelligent merging, so it can handle the delta operation semantics described here without requiring exact programmatic parsing. <!-- ASSUMPTION: Agent-driven sync -->
- YAML frontmatter parsing in markdown is supported by the agent reading the spec file. <!-- ASSUMPTION: Standard markdown convention, widely supported -->
- The `/opsx:sync` agent can handle frontmatter blocks when merging delta specs into baselines. <!-- ASSUMPTION: Agent-driven sync is intelligent enough to preserve/merge frontmatter -->
No further assumptions beyond those marked above.
