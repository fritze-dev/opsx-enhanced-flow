## ADDED Requirements

### Requirement: Baseline Spec Exclusion from Implementation Scope

The system SHALL NOT include tasks that modify baseline spec files (`openspec/specs/`) in the generated task list. Baseline spec changes SHALL flow exclusively through delta specs and `/opsx:sync`. During task generation, the system SHALL exclude any edits to files matching `openspec/specs/**/*` from implementation tasks. During `/opsx:apply`, the system SHALL NOT modify any file under `openspec/specs/` as part of task implementation. If a task description references baseline spec edits, the system SHALL skip that edit and note that spec changes are handled by `/opsx:sync`.

**User Story:** As a developer I want baseline specs to only be updated via the sync pipeline, so that there is a single authoritative path for spec changes and delta specs remain meaningful.

#### Scenario: Task generation excludes baseline spec edits

- **GIVEN** a change with delta specs that modify existing capabilities
- **AND** the design includes both code changes and spec requirement changes
- **WHEN** the tasks artifact is generated
- **THEN** the generated tasks SHALL include implementation tasks for code, skills, docs, and other non-spec files
- **AND** the generated tasks SHALL NOT include tasks to edit files under `openspec/specs/`
- **AND** the tasks SHALL note that spec changes will be applied automatically during `/opsx:sync`

#### Scenario: Apply skips baseline spec edits encountered during implementation

- **GIVEN** a task list that references updating a baseline spec (e.g., from a manually edited tasks.md)
- **WHEN** the system encounters a task that would modify a file under `openspec/specs/`
- **THEN** the system SHALL skip the baseline spec edit
- **AND** SHALL log that spec changes are deferred to `/opsx:sync`
- **AND** SHALL continue with the next non-spec task

## Edge Cases

- **Change with only spec modifications (no code):** If a change modifies only specs and has no code implementation, the tasks list implementation sections may be empty. The QA loop alone is sufficient, and `/opsx:sync` handles the spec updates.
- **Delta spec files ARE in scope:** Tasks may reference delta spec files under `openspec/changes/<name>/specs/` — these are part of the change workspace and are distinct from baseline specs.

## Assumptions

No assumptions made.
