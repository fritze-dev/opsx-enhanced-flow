---
order: 5
category: change-workflow
---
## MODIFIED Requirements

### Requirement: Fast-Forward Generation
The system SHALL provide `/opsx:ff` as the sole command for generating pipeline artifacts. Fast-forward SHALL determine the current pipeline status by reading WORKFLOW.md and Smart Templates and checking file existence, identify all pending artifacts, and generate them sequentially following dependency order. After completion, ff SHALL report a summary of all generated artifacts. If all artifacts are already complete, ff SHALL inform the user and suggest `/opsx:apply`. The design review checkpoint is governed by the project constitution convention, not by ff skill logic. If the preflight verdict is PASS WITH WARNINGS, ff SHALL pause and require explicit user acknowledgment before generating tasks.

When invoked without a change name and existing changes are present, ff SHALL list active changes and use AskUserQuestion to let the user select which change to continue, showing the most recently modified change as recommended. When invoked with a description of what to build, ff SHALL derive a kebab-case name and create a new change.

**User Story:** As a developer I want a single command that generates all remaining artifacts, so that I can progress the pipeline efficiently whether starting a new change or continuing an existing one.

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
- **THEN** the system SHALL generate artifacts in strict order (research, proposal, specs, design, preflight, tasks)

#### Scenario: Design review checkpoint pauses after design (constitution-governed)
- **GIVEN** a change workspace where design has just been created or already exists but preflight does not
- **WHEN** an agent executes `/opsx:ff`
- **THEN** the agent SHALL pause for user alignment before proceeding to preflight

#### Scenario: Checkpoint skipped when resuming past design (constitution-governed)
- **GIVEN** a change workspace where preflight already exists
- **WHEN** an agent executes `/opsx:ff`
- **THEN** the agent SHALL skip the design review checkpoint and generate only remaining artifacts

#### Scenario: Fast-forward pauses on preflight warnings
- **GIVEN** a change workspace where preflight has just been generated with verdict PASS WITH WARNINGS
- **WHEN** the agent is about to generate the tasks artifact
- **THEN** the agent SHALL pause, present warnings, and require explicit acknowledgment before generating tasks

#### Scenario: Change selection for existing changes
- **GIVEN** existing changes under `openspec/changes/` and the user invokes `/opsx:ff` without specifying a name
- **WHEN** the skill detects active changes
- **THEN** it SHALL present a list of active changes using AskUserQuestion
- **AND** SHALL mark the most recently modified change as recommended

#### Scenario: New change creation via description
- **GIVEN** the user invokes `/opsx:ff` with a description like "add user authentication"
- **AND** no change with a matching name exists
- **WHEN** the skill processes the input
- **THEN** it SHALL derive a kebab-case name (e.g., `add-user-auth`) and create a new change directory

### Requirement: Skill Delivery for Generation Command
`/opsx:ff` SHALL be delivered as a plugin SKILL.md file located at `skills/ff/SKILL.md`. The skill file SHALL read `openspec/WORKFLOW.md` for pipeline configuration and Smart Templates for artifact definitions, instructions, and output structure. The skill SHALL be model-invocable. The skill SHALL reference Smart Template instructions by reading template frontmatter at runtime rather than duplicating instruction content.

**User Story:** As a plugin maintainer I want ff to read WORKFLOW.md and Smart Templates directly, so that updating the workflow or templates automatically updates generation behavior without changing the skill file.

#### Scenario: FF skill reads WORKFLOW.md and Smart Templates
- **GIVEN** the `skills/ff/SKILL.md` file
- **WHEN** its content is inspected
- **THEN** it SHALL contain instructions to read WORKFLOW.md for pipeline configuration and Smart Templates for artifact definitions

#### Scenario: FF skill is model-invocable
- **GIVEN** the `skills/ff/SKILL.md` file
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL have `disable-model-invocation` set to `false` or absent

## REMOVED Requirements

### Requirement: Step-by-Step Generation
**Reason**: `/opsx:continue` is merged into `/opsx:ff`. FF already has the same checkpoint model (auto-continue at routine transitions, mandatory pause at design review and preflight warnings). The step-by-step mode provided no additional value over FF's checkpoint pauses.
**Migration**: Use `/opsx:ff` instead. FF pauses at the same critical checkpoints (design review, preflight warnings).

### Requirement: Unified Skill Delivery for Generation Commands
**Reason**: With continue removed, there is only one generation skill (ff). The "unified delivery" requirement for two skills is no longer applicable.
**Migration**: The ff skill delivery requirement above covers the single remaining skill.

## Edge Cases

- If WORKFLOW.md is unreadable or missing, the skill SHALL report the error and suggest `/opsx:setup`.
- If `/opsx:ff` is run when no active change exists and no description provided, the skill SHALL ask the user what they want to build.
- If `/opsx:ff` encounters an error mid-pipeline, it SHALL stop, report the error and last successful artifact, and not attempt subsequent stages.
- If the user provides feedback at the design review checkpoint indicating misalignment, the agent SHALL incorporate feedback by regenerating affected artifacts.
- If the user modifies an artifact file manually after generation, subsequent `/opsx:ff` calls SHALL treat that artifact as complete.
- If multiple capabilities are listed in the proposal, the specs stage SHALL generate one spec file per capability before marking the stage as complete.
- If the proposal has no Consolidation Check section (legacy), the ff skill SHALL proceed without consolidation verification and rely on the specs instruction's overlap verification instead.

## Assumptions

- Skills can read and interpret YAML frontmatter natively because they are executed by Claude. <!-- ASSUMPTION: Claude YAML comprehension -->
- Artifact completion is determined by file existence and non-empty content. <!-- ASSUMPTION: File-existence-based completion -->
No further assumptions beyond those marked above.
