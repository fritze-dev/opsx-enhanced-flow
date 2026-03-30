## MODIFIED Requirements

### Requirement: Step-by-Step Generation
The system SHALL provide `/opsx:continue` as the command for generating one artifact at a time. When invoked, continue SHALL determine which artifact is next in the pipeline by querying the OpenSpec CLI for the current change status, then generate exactly that one artifact using the schema's instruction and template. After generation, continue SHALL report what was generated and what the next step is. If all artifacts are already complete, continue SHALL inform the user that the pipeline is finished and suggest proceeding to `/opsx:apply`. At routine transitions (research to proposal, proposal to specs, specs to design, preflight to tasks), continue SHALL auto-continue to the next artifact without pausing for confirmation. At mandatory-pause checkpoints (after design for user review, after preflight with warnings for acknowledgment), continue SHALL pause and wait for explicit user input before proceeding.

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

#### Scenario: Continue auto-continues through routine transitions
- **GIVEN** a change workspace where research.md has just been generated
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate research.md and immediately proceed to generate proposal.md without pausing for confirmation
- **AND** SHALL report both artifacts as generated

#### Scenario: Continue pauses at design review checkpoint
- **GIVEN** a change workspace where specs have been generated and design is the next artifact
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate design.md
- **AND** SHALL pause for user review before proceeding to preflight
- **AND** SHALL display the design for the user to evaluate

### Requirement: Fast-Forward Generation
The system SHALL provide `/opsx:ff` as the command for generating all remaining artifacts in dependency order. Fast-forward SHALL query the current pipeline status, identify all pending artifacts, and generate them sequentially following the schema's dependency chain. After completion, ff SHALL report a summary of all generated artifacts. If all artifacts are already complete, ff SHALL inform the user and suggest `/opsx:apply`. The design review checkpoint is governed by the project constitution convention, not by ff skill logic. If the preflight verdict is PASS WITH WARNINGS, ff SHALL pause and require explicit user acknowledgment of the warnings before generating the tasks artifact.

**User Story:** As a developer working on a straightforward change I want to generate all remaining artifacts in one command, so that I do not have to run continue repeatedly when I trust the AI to handle the full pipeline.

#### Scenario: Fast-forward from research to tasks
- **GIVEN** a change workspace where only research.md is complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate all 5 remaining artifacts in dependency order and report a summary

#### Scenario: Fast-forward with some artifacts already complete
- **GIVEN** a change workspace where research.md, proposal.md, and specs are complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate the remaining artifacts (design, preflight, tasks) in dependency order

#### Scenario: Fast-forward when pipeline is already complete
- **GIVEN** a change workspace where all 6 artifacts are complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL report that no artifacts remain and suggest running `/opsx:apply`

#### Scenario: Fast-forward respects dependency order
- **GIVEN** a change workspace with no artifacts generated
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate artifacts in strict order (research, proposal, specs, design, preflight, tasks) and not attempt parallel generation

#### Scenario: Design review checkpoint pauses after design (constitution-governed)
- **GIVEN** a change workspace where design has just been created or already exists but preflight does not
- **WHEN** an agent executes `/opsx:ff`
- **THEN** the agent SHALL pause for user alignment before proceeding to preflight, as required by the constitution's design review checkpoint convention

#### Scenario: Checkpoint skipped when resuming past design (constitution-governed)
- **GIVEN** a change workspace where preflight already exists
- **WHEN** an agent executes `/opsx:ff`
- **THEN** the agent SHALL skip the design review checkpoint and generate only remaining artifacts, since preflight existence implies prior design review

#### Scenario: Fast-forward pauses on preflight warnings
- **GIVEN** a change workspace where preflight has just been generated with verdict PASS WITH WARNINGS
- **WHEN** the agent is about to generate the tasks artifact
- **THEN** the agent SHALL pause and present the warnings to the user
- **AND** SHALL require explicit user acknowledgment before generating tasks
- **AND** SHALL NOT auto-accept warnings

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
- If the user provides feedback at the design review checkpoint indicating misalignment, the agent SHALL incorporate the feedback by regenerating affected artifacts before proceeding. This behavior is governed by the constitution convention, not by skill logic.
- If the user modifies an artifact file manually after generation, subsequent `/opsx:continue` calls SHALL treat that artifact as complete and move to the next stage, respecting the user's edits.
- If multiple capabilities are listed in the proposal, the specs stage SHALL generate one spec file per capability before marking the stage as complete.
- If preflight returns PASS WITH WARNINGS during ff, and the user rejects or wants to address a warning, the agent SHALL pause ff and allow the user to fix the issue before regenerating preflight and continuing.
