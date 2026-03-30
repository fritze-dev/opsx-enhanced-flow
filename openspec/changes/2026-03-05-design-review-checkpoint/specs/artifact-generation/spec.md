## MODIFIED Requirements

### Requirement: Fast-Forward Generation
The system SHALL provide `/opsx:ff` as the command for generating all remaining artifacts in dependency order. Fast-forward SHALL query the current pipeline status, identify all pending artifacts, and generate them in two phases: (1) planning artifacts up to and including design, then (2) a mandatory review checkpoint where the user reviews specs and design and confirms alignment, then (3) execution artifacts (preflight and tasks) after user confirmation. After completion, ff SHALL report a summary of all generated artifacts. If all artifacts are already complete, ff SHALL inform the user and suggest `/opsx:apply`. If the user resumes ff when preflight is already complete, the review checkpoint SHALL be skipped since the user has already reviewed past the design phase.

**User Story:** As a developer working on a straightforward change I want to generate all remaining artifacts in one command, so that I do not have to run continue repeatedly when I trust the AI to handle the full pipeline — while still getting a chance to review the approach after design before the system proceeds to quality checks and task creation.

#### Scenario: Fast-forward from research to tasks
- **GIVEN** a change workspace where only research.md is complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate proposal, specs, and design in order, then pause for user review
- **AND** after user confirms alignment, the system SHALL generate preflight and tasks, then report a summary listing all 5 generated artifacts

#### Scenario: Fast-forward with some artifacts already complete
- **GIVEN** a change workspace where research.md, proposal.md, and specs are complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate design, then pause for user review
- **AND** after user confirms alignment, the system SHALL generate preflight and tasks

#### Scenario: Fast-forward when pipeline is already complete
- **GIVEN** a change workspace where all 6 artifacts are complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL report that no artifacts remain and suggest running `/opsx:apply`

#### Scenario: Fast-forward respects dependency order
- **GIVEN** a change workspace with no artifacts generated
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate artifacts in strict order (research, proposal, specs, design, preflight, tasks) and not attempt parallel generation

#### Scenario: Review checkpoint pauses after design
- **GIVEN** a change workspace where research, proposal, specs, and design are complete but preflight is not
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL present the review checkpoint summarizing the existing planning artifacts and ask for user alignment before proceeding to preflight

#### Scenario: Checkpoint skipped when resuming past design
- **GIVEN** a change workspace where research, proposal, specs, design, and preflight are all complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate only tasks without presenting a review checkpoint, since the user has already reviewed past the design phase

## Edge Cases

- If the user provides feedback at the review checkpoint indicating misalignment, the system SHALL incorporate the feedback by regenerating affected artifacts before re-presenting the checkpoint.
- If `/opsx:ff` is interrupted before reaching the design artifact (e.g., error on specs), the checkpoint does not apply — standard error handling takes precedence.
- If only tasks remain (preflight already done), no checkpoint is needed — the user has implicitly approved past the design phase by having preflight complete.

## Assumptions

No assumptions made.
