## ADDED Requirements

### Requirement: Step-by-Step Generation
The system SHALL provide `/opsx:continue` as the command for generating one artifact at a time. When invoked, continue SHALL determine which artifact is next in the pipeline by querying the OpenSpec CLI for the current change status, then generate exactly that one artifact using the schema's instruction and template. After generation, continue SHALL report what was generated and what the next step is. If all artifacts are already complete, continue SHALL inform the user that the pipeline is finished and suggest proceeding to `/opsx:apply`.

**User Story:** As a developer I want to advance the pipeline one step at a time, so that I can review each artifact and provide feedback before moving to the next stage.

#### Scenario: Generate next artifact in sequence
- **GIVEN** a change workspace where research.md and proposal.md are complete
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate the specs artifact(s) as the next pending stage, then report completion and indicate design as the next step

#### Scenario: All artifacts already complete
- **GIVEN** a change workspace where all 6 pipeline artifacts have been generated
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL report that all artifacts are complete and suggest running `/opsx:apply` to begin implementation

#### Scenario: Continue respects dependency gating
- **GIVEN** a change workspace where research.md is complete but proposal.md is missing (e.g., manually deleted)
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate proposal.md as the next required artifact, not skip ahead to specs

### Requirement: Fast-Forward Generation
The system SHALL provide `/opsx:ff` as the command for generating all remaining artifacts in dependency order without pausing between stages. Fast-forward SHALL query the current pipeline status, identify all pending artifacts, and generate each one sequentially in dependency order. After completion, ff SHALL report a summary of all generated artifacts. If all artifacts are already complete, ff SHALL inform the user and suggest `/opsx:apply`.

**User Story:** As a developer working on a straightforward change I want to generate all remaining artifacts in one command, so that I do not have to run continue repeatedly when I trust the AI to handle the full pipeline.

#### Scenario: Fast-forward from research to tasks
- **GIVEN** a change workspace where only research.md is complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate proposal, specs, design, preflight, and tasks in order, then report a summary listing all 5 generated artifacts

#### Scenario: Fast-forward with some artifacts already complete
- **GIVEN** a change workspace where research.md, proposal.md, and specs are complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate only design, preflight, and tasks (the remaining artifacts), skipping already-completed stages

#### Scenario: Fast-forward when pipeline is already complete
- **GIVEN** a change workspace where all 6 artifacts are complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL report that no artifacts remain and suggest running `/opsx:apply`

#### Scenario: Fast-forward respects dependency order
- **GIVEN** a change workspace with no artifacts generated
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate artifacts in strict order (research, proposal, specs, design, preflight, tasks) and not attempt parallel generation

### Requirement: Unified Skill Delivery for Generation Commands
Both `/opsx:continue` and `/opsx:ff` SHALL be delivered as plugin SKILL.md files located at `skills/continue/SKILL.md` and `skills/ff/SKILL.md` respectively. These skill files SHALL wrap the OpenSpec CLI by invoking CLI commands for status checking and artifact instruction retrieval. Both skills SHALL be model-invocable (not user-only). The skill files SHALL reference the schema's artifact instructions via the CLI rather than duplicating instruction content.

**User Story:** As a plugin maintainer I want continue and ff to be thin wrappers around the OpenSpec CLI, so that updating the schema automatically updates the generation behavior without changing skill files.

#### Scenario: Continue skill wraps OpenSpec CLI
- **GIVEN** the `skills/continue/SKILL.md` file
- **WHEN** its content is inspected
- **THEN** it SHALL contain instructions to query the OpenSpec CLI for current status and next artifact instructions, rather than embedding pipeline logic directly

#### Scenario: FF skill wraps OpenSpec CLI
- **GIVEN** the `skills/ff/SKILL.md` file
- **WHEN** its content is inspected
- **THEN** it SHALL contain instructions to iterate over remaining artifacts using the OpenSpec CLI, rather than hardcoding artifact names or instructions

#### Scenario: Both skills are model-invocable
- **GIVEN** the SKILL.md files for continue and ff
- **WHEN** their YAML frontmatter is inspected
- **THEN** both SHALL have `disable-model-invocation` set to `false` or absent (defaulting to model-invocable)

## Edge Cases

- If the OpenSpec CLI returns an error during generation (e.g., schema not found), the skill SHALL report the error to the user and halt rather than producing a malformed artifact.
- If `/opsx:continue` is run when no active change exists, the system SHALL instruct the user to create a change first via `/opsx:new`.
- If `/opsx:ff` encounters an error mid-pipeline (e.g., fails on the design artifact), it SHALL stop, report the error and the last successfully generated artifact, and not attempt subsequent stages.
- If the user modifies an artifact file manually after generation, subsequent `/opsx:continue` calls SHALL treat that artifact as complete and move to the next stage, respecting the user's edits.
- If multiple capabilities are listed in the proposal, the specs stage SHALL generate one spec file per capability before marking the stage as complete.

## Assumptions

<!-- ASSUMPTION: The OpenSpec CLI provides commands to query change status (`openspec status`) and retrieve artifact instructions (`openspec instructions`) that the skills can invoke. -->
<!-- ASSUMPTION: The OpenSpec CLI determines artifact completion by checking file existence in the change workspace directory. -->
No further assumptions beyond those marked above.
