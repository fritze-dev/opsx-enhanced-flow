## MODIFIED Requirements

### Requirement: Fast-Forward Generation

The system SHALL provide `/opsx:ff` as the sole command for generating pipeline artifacts. Fast-forward SHALL determine the current pipeline status by reading WORKFLOW.md and Smart Templates and checking file existence, identify all pending artifacts, and generate them sequentially following dependency order. During the **specs stage**, the agent SHALL edit baseline specs directly at `openspec/specs/<capability>/spec.md` rather than creating delta spec files. For new capabilities, the agent SHALL create new spec files at `openspec/specs/<capability>/spec.md`. For modified capabilities, the agent SHALL edit the existing spec file in place. After completion, ff SHALL report a summary of all generated artifacts. If all artifacts are already complete, ff SHALL inform the user and suggest `/opsx:apply`. The design review checkpoint is governed by the project constitution convention. If the preflight verdict is PASS WITH WARNINGS, ff SHALL pause and require explicit user acknowledgment before generating tasks.

**User Story:** As a developer I want a single command that generates all remaining artifacts and edits specs directly, so that I can progress the pipeline efficiently without dealing with delta formats or sync steps.

#### Scenario: Fast-forward edits specs directly

- **GIVEN** a change workspace where research.md and proposal.md are complete
- **AND** the proposal lists capabilities `user-auth` (new) and `quality-gates` (modified)
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL create `openspec/specs/user-auth/spec.md` as a new file
- **AND** SHALL edit `openspec/specs/quality-gates/spec.md` in place
- **AND** SHALL NOT create any files under `openspec/changes/<name>/specs/`

#### Scenario: Fast-forward from research to tasks

- **GIVEN** a change workspace where only research.md is complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate all 5 remaining artifacts in dependency order and report a summary
- **AND** spec edits SHALL be made directly to `openspec/specs/`

#### Scenario: Fast-forward with some artifacts already complete

- **GIVEN** a change workspace where research.md, proposal.md, and specs stage is complete
- **WHEN** the user runs `/opsx:ff`
- **THEN** the system SHALL generate the remaining artifacts (design, preflight, tasks) in dependency order

#### Scenario: Change selection for existing changes

- **GIVEN** existing changes under `openspec/changes/` and the user invokes `/opsx:ff` without specifying a name
- **WHEN** the skill detects active changes (with unchecked tasks or missing artifacts)
- **THEN** it SHALL present a list of active changes using AskUserQuestion
- **AND** SHALL mark the most recently modified change as recommended

## Edge Cases

- If WORKFLOW.md is unreadable or missing, the skill SHALL report the error and suggest `/opsx:setup`.
- If the user modifies a spec file manually after generation, subsequent `/opsx:ff` calls SHALL treat the specs stage as complete.
- If multiple capabilities are listed in the proposal, the specs stage SHALL edit/create all spec files before marking the stage as complete.

## Assumptions

- Skills can read and interpret YAML frontmatter natively because they are executed by Claude. <!-- ASSUMPTION: Claude YAML comprehension -->
No further assumptions beyond those marked above.
