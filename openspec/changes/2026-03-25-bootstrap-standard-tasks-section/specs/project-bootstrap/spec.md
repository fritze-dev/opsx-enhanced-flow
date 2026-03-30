## MODIFIED Requirements

### Requirement: Constitution Generation
The `/opsx:bootstrap` command SHALL generate a `constitution.md` file based on the observed patterns from the codebase scan. The constitution SHALL include Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and Standard Tasks sections. The Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections SHALL be populated with project-specific values from the scan. The Standard Tasks section SHALL be generated empty with an HTML comment explaining its purpose, so that new projects are aware of the feature and know where to define project-specific post-implementation steps.

**User Story:** As a developer I want the constitution to be auto-generated from my codebase, so that it accurately captures my project's existing patterns rather than requiring me to write it from scratch.

#### Scenario: Constitution generated from scan results
- **GIVEN** the codebase scan has completed and identified TypeScript, React, and Jest as the primary technologies
- **WHEN** the constitution generation phase runs
- **THEN** the system SHALL create `openspec/constitution.md` with Tech Stack listing TypeScript, React, and Jest, along with Architecture Rules, Code Style, Constraints, Conventions, and an empty Standard Tasks section reflecting the observed patterns

#### Scenario: Constitution respects existing conventions
- **GIVEN** a project using 4-space indentation, camelCase variables, and conventional commits
- **WHEN** the constitution is generated
- **THEN** the Code Style section SHALL reflect the 4-space indentation and camelCase convention, and the Conventions section SHALL reference the conventional commits format

#### Scenario: Standard Tasks section present but empty on first run
- **GIVEN** a new project being bootstrapped for the first time
- **WHEN** the constitution generation phase runs
- **THEN** the generated constitution SHALL contain a `## Standard Tasks` section
- **AND** the section SHALL be empty except for an HTML comment explaining that project-specific extras can be added here to appear in every tasks.md after the universal standard tasks

## Edge Cases

- If a project already has a constitution with a `## Standard Tasks` section (e.g., from manual addition), recovery mode SHALL preserve it as-is.

## Assumptions

No assumptions made.
