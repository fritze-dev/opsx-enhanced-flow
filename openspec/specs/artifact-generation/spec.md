---
order: 5
category: change-workflow
status: draft
version: 1
lastModified: 2026-04-09
change: 2026-04-09-skill-consolidation
---
## Purpose

Provides the `/opsx:propose` command for full lifecycle execution of the 7-stage artifact pipeline. Propose creates a workspace if needed, traverses the full pipeline (research, proposal, specs, design, preflight, tasks), supports checkpoint/resume, and is delivered as an action within the router that reads WORKFLOW.md and Smart Templates directly.

## Requirements

### Requirement: Propose — Full Lifecycle Execution
The system SHALL provide `/opsx:propose` as the sole command for creating workspaces and generating pipeline artifacts. When invoked with a description or name and no existing change matches, propose SHALL create a new change workspace (with worktree if enabled). Propose SHALL determine the current pipeline status by reading WORKFLOW.md and Smart Templates and checking file existence, identify all pending artifacts, and generate them sequentially following dependency order. During the **specs stage**, the agent SHALL edit specs directly at `openspec/specs/<capability>/spec.md` and SHALL update spec frontmatter tracking fields: set `status: draft`, `change: <change-directory-name>`, and `lastModified: <current-date-YYYY-MM-DD>`. For new specs, the agent SHALL also set `version: 1`. For existing specs, the agent SHALL preserve the current `version` value (version is only bumped during verify completion). Before editing a spec, the agent SHALL check the spec's `status` and `change` fields — if `status: draft` and `change` references a different change, the agent SHALL warn the user about the collision and ask for confirmation before proceeding. After completion, propose SHALL report a summary of all generated artifacts. If all artifacts are already complete, propose SHALL inform the user and suggest `/opsx:apply`. The design review checkpoint is governed by the project constitution convention, not by propose action logic. If the preflight verdict is PASS WITH WARNINGS, propose SHALL pause and require explicit user acknowledgment before generating tasks.

When invoked without a change name and existing changes are present, propose SHALL list active changes and use AskUserQuestion to let the user select which change to continue, showing the most recently modified change as recommended. When invoked with a description of what to build, propose SHALL derive a kebab-case name and create a new change.

**User Story:** As a developer I want a single command that generates all remaining artifacts, so that I can progress the pipeline efficiently whether starting a new change or continuing an existing one.

#### Scenario: Propose sets spec tracking frontmatter
- **GIVEN** a stable spec at `openspec/specs/user-auth/spec.md` with `status: stable`, `version: 2`
- **WHEN** `/opsx:propose` reaches the specs stage and edits this spec
- **THEN** the spec frontmatter SHALL be updated to `status: draft`, `change: <change-dir>`, `lastModified: <today>`
- **AND** `version` SHALL remain `2`

#### Scenario: Propose detects spec collision
- **GIVEN** a spec at `openspec/specs/quality-gates/spec.md` with `status: draft` and `change: 2026-04-01-other-change`
- **WHEN** `/opsx:propose` for change `2026-04-08-my-change` reaches the specs stage and needs to edit this spec
- **THEN** the agent SHALL warn the user that `quality-gates` is currently being edited by `2026-04-01-other-change`
- **AND** SHALL ask for confirmation before proceeding

#### Scenario: Propose from research to tasks
- **GIVEN** a change workspace where only research.md is complete
- **WHEN** the user runs `/opsx:propose`
- **THEN** the system SHALL generate all 5 remaining artifacts in dependency order and report a summary

#### Scenario: Propose with some artifacts already complete
- **GIVEN** a change workspace where research.md, proposal.md, and specs are complete
- **WHEN** the user runs `/opsx:propose`
- **THEN** the system SHALL generate the remaining artifacts (design, preflight, tasks) in dependency order

#### Scenario: Propose when pipeline is already complete
- **GIVEN** a change workspace where all 6 artifacts are complete
- **WHEN** the user runs `/opsx:propose`
- **THEN** the system SHALL report that no artifacts remain and suggest running `/opsx:apply`

#### Scenario: Propose respects dependency order
- **GIVEN** a change workspace with no artifacts generated
- **WHEN** the user runs `/opsx:propose`
- **THEN** the system SHALL generate artifacts in strict order (research, proposal, specs, design, preflight, tasks)

#### Scenario: Design review checkpoint pauses after design (constitution-governed)
- **GIVEN** a change workspace where design has just been created or already exists but preflight does not
- **WHEN** an agent executes `/opsx:propose`
- **THEN** the agent SHALL pause for user alignment before proceeding to preflight

#### Scenario: Checkpoint skipped when resuming past design (constitution-governed)
- **GIVEN** a change workspace where preflight already exists
- **WHEN** an agent executes `/opsx:propose`
- **THEN** the agent SHALL skip the design review checkpoint and generate only remaining artifacts

#### Scenario: Propose pauses on preflight warnings
- **GIVEN** a change workspace where preflight has just been generated with verdict PASS WITH WARNINGS
- **WHEN** the agent is about to generate the tasks artifact
- **THEN** the agent SHALL pause, present warnings, and require explicit acknowledgment before generating tasks

#### Scenario: Change selection for existing changes
- **GIVEN** existing changes under `openspec/changes/` and the user invokes `/opsx:propose` without specifying a name
- **WHEN** the action detects active changes
- **THEN** it SHALL present a list of active changes using AskUserQuestion
- **AND** SHALL mark the most recently modified change as recommended

#### Scenario: New change creation via description
- **GIVEN** the user invokes `/opsx:propose` with a description like "add user authentication"
- **AND** no change with a matching name exists
- **WHEN** the action processes the input
- **THEN** it SHALL derive a kebab-case name (e.g., `add-user-auth`) and create a new change directory

### Requirement: Action Delivery for Propose Command
`/opsx:propose` SHALL be delivered as an inline action defined in WORKFLOW.md, dispatched by the router. The action SHALL read `openspec/WORKFLOW.md` for pipeline configuration and Smart Templates for artifact definitions, instructions, and output structure. The action SHALL be model-invocable. The action SHALL reference Smart Template instructions by reading template frontmatter at runtime rather than duplicating instruction content.

**User Story:** As a plugin maintainer I want propose to read WORKFLOW.md and Smart Templates directly, so that updating the workflow or templates automatically updates generation behavior without changing the action definition.

#### Scenario: Propose action reads WORKFLOW.md and Smart Templates
- **GIVEN** the propose action definition in WORKFLOW.md
- **WHEN** its content is inspected
- **THEN** it SHALL contain instructions to read WORKFLOW.md for pipeline configuration and Smart Templates for artifact definitions

#### Scenario: Propose action is model-invocable
- **GIVEN** the propose action definition in WORKFLOW.md
- **WHEN** its configuration is inspected
- **THEN** it SHALL be invocable by the model through the router

## Edge Cases

- If WORKFLOW.md is unreadable or missing, the action SHALL report the error and suggest `/opsx:init`.
- If `/opsx:propose` is run when no active change exists and no description provided, the action SHALL ask the user what they want to build.
- If `/opsx:propose` encounters an error mid-pipeline, it SHALL stop, report the error and last successful artifact, and not attempt subsequent stages.
- If the user provides feedback at the design review checkpoint indicating misalignment, the agent SHALL incorporate feedback by regenerating affected artifacts.
- If the user modifies an artifact file manually after generation, subsequent `/opsx:propose` calls SHALL treat that artifact as complete.
- If multiple capabilities are listed in the proposal, the specs stage SHALL generate one spec file per capability before marking the stage as complete.
- If the proposal has no Consolidation Check section (legacy), the propose action SHALL proceed without consolidation verification and rely on the specs instruction's overlap verification instead.

## Assumptions

- Skills can read and interpret YAML frontmatter natively because they are executed by Claude. <!-- ASSUMPTION: Claude YAML comprehension -->
- Artifact completion is determined by file existence and non-empty content. <!-- ASSUMPTION: File-existence-based completion -->
No further assumptions beyond those marked above.
