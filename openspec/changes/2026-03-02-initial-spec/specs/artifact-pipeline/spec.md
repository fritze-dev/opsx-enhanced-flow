## ADDED Requirements

### Requirement: Six-Stage Pipeline
The system SHALL define a 6-stage artifact pipeline with the following stages in order: research, proposal, specs, design, preflight, and tasks. Each stage SHALL produce a verifiable artifact file. The pipeline stages SHALL execute in strict dependency order: research has no dependencies, proposal requires research, specs requires proposal, design requires specs, preflight requires design, and tasks requires preflight. No stage SHALL be skippable; each MUST complete before the next can begin.

**User Story:** As a developer I want a structured pipeline that guides me from research through to implementation tasks, so that no critical thinking step is skipped and every decision is documented.

#### Scenario: Pipeline stages execute in dependency order
- **GIVEN** a new change workspace with no artifacts generated
- **WHEN** the user progresses through the pipeline
- **THEN** the system SHALL enforce the order: research first, then proposal, then specs, then design, then preflight, then tasks

#### Scenario: Skipping a stage is prevented
- **GIVEN** a change workspace where only research.md has been generated
- **WHEN** a user or agent attempts to generate specs (skipping proposal)
- **THEN** the system SHALL reject the attempt and report that the proposal artifact must be completed first

#### Scenario: All stages produce verifiable artifacts
- **GIVEN** a completed pipeline run
- **WHEN** the change workspace is inspected
- **THEN** it SHALL contain research.md, proposal.md, one or more `specs/<capability>/spec.md` files, design.md, preflight.md, and tasks.md

### Requirement: Artifact Dependencies
Each artifact in the pipeline SHALL declare its dependencies explicitly in the schema. The dependency declaration SHALL list which preceding artifacts MUST be complete before the artifact can be generated. The OpenSpec CLI SHALL enforce these dependencies by checking artifact completion status before allowing generation of a dependent artifact. An artifact SHALL be considered complete when its corresponding file exists and is non-empty in the change workspace.

**User Story:** As a developer I want the system to enforce artifact dependencies automatically, so that I cannot accidentally generate a design before the specs are written.

#### Scenario: Dependency check passes
- **GIVEN** a change workspace with completed research.md and proposal.md
- **WHEN** the system checks dependencies for the specs artifact
- **THEN** the dependency check SHALL pass because both research and proposal (the transitive chain) are complete

#### Scenario: Dependency check fails
- **GIVEN** a change workspace with only research.md completed
- **WHEN** the system checks dependencies for the design artifact
- **THEN** the dependency check SHALL fail and report that proposal and specs must be completed first

#### Scenario: Schema declares dependencies explicitly
- **GIVEN** the `schema.yaml` file
- **WHEN** the artifact definitions are inspected
- **THEN** each artifact SHALL have a `requires` field listing its direct dependencies by artifact ID

### Requirement: Apply Gate
Implementation (the apply phase) SHALL be gated by completion of the tasks artifact. The apply phase SHALL NOT begin until tasks.md exists and is non-empty. The apply phase SHALL track progress against the task checklist in tasks.md, marking items complete as implementation proceeds. The schema SHALL declare this gate via the `apply.requires` field referencing the tasks artifact.

**User Story:** As a project lead I want implementation to be gated by task completion in the pipeline, so that developers cannot start coding before the full analysis and planning cycle is done.

#### Scenario: Apply is blocked without tasks
- **GIVEN** a change workspace where preflight.md is the latest completed artifact and tasks.md does not exist
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL reject the apply attempt and report that tasks.md must be generated first

#### Scenario: Apply proceeds after tasks completion
- **GIVEN** a change workspace with all 6 artifacts completed including tasks.md
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL begin implementation, reading the task checklist from tasks.md and working through items sequentially

#### Scenario: Apply tracks progress in tasks.md
- **GIVEN** the apply phase is active and tasks.md contains 10 unchecked task items
- **WHEN** the agent completes a task item
- **THEN** the system SHALL mark the corresponding `- [ ]` checkbox as `- [x]` in tasks.md

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system SHALL treat it as incomplete and not satisfy dependency checks.
- If a user manually deletes an artifact file mid-pipeline, the system SHALL detect the gap and require regeneration before proceeding.
- If the schema is modified to add a new artifact stage while a change is in progress, the system SHALL apply the new schema to new changes only; in-progress changes continue with the schema version active when they were created.
- If tasks.md contains no checkbox items (e.g., documentation-only change), the apply phase SHALL still be gated by tasks.md existence but will report that there are no implementation tasks to execute.
- If multiple spec files are required (one per capability), the specs stage SHALL not be considered complete until all capability specs listed in the proposal have been generated.

## Assumptions

<!-- ASSUMPTION: The OpenSpec CLI enforces artifact dependency checks before generation. If the CLI does not enforce this natively, skills must implement the checks. -->
<!-- ASSUMPTION: Artifact completion is determined by file existence and non-empty content, not by content validation or quality assessment. -->
No further assumptions beyond those marked above.
