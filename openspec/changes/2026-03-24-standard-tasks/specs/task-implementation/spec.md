## ADDED Requirements

### Requirement: Standard Tasks Exclusion from Apply Scope

The system SHALL distinguish between implementation tasks (Foundation, Implementation, QA Loop sections) and standard tasks (Post-Implementation section) in the generated `tasks.md`. During `/opsx:apply`, the system SHALL only process tasks in the implementation and QA sections. Standard tasks in the Post-Implementation section SHALL NOT be executed by the apply phase. Standard tasks SHALL remain as unchecked `- [ ]` items after apply completes. The standard tasks section SHALL be included in the total checkbox count for progress reporting, reflecting the full workflow completion state. The `/opsx:archive` incomplete-task check SHALL detect unchecked standard tasks, providing a safety net against forgotten post-implementation steps.

**User Story:** As a developer I want post-implementation workflow steps tracked as checkboxes in my task list but not executed by apply, so that I have a visible, auditable checklist for post-apply steps without conflating them with implementation work.

#### Scenario: Apply skips standard tasks section

- **GIVEN** a tasks.md with sections 1-3 (Foundation, Implementation, QA Loop) and section 4 (Standard Tasks Post-Implementation) containing 3 unchecked items
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL work through pending tasks in sections 1-3 only
- **AND** SHALL NOT attempt to execute tasks in section 4
- **AND** section 4 items SHALL remain as `- [ ]` after apply completes

#### Scenario: Progress count includes standard tasks

- **GIVEN** a tasks.md with 5 implementation tasks (all complete) and 3 standard tasks (all unchecked)
- **WHEN** the system reports progress
- **THEN** the system SHALL display "5/8 tasks complete"
- **AND** SHALL indicate that standard tasks remain for post-apply workflow

#### Scenario: Archive warns on unchecked standard tasks

- **GIVEN** a tasks.md with all implementation tasks complete but 2 standard tasks unchecked
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL warn that 2 tasks remain incomplete
- **AND** SHALL list the unchecked standard tasks

## MODIFIED Requirements

### Requirement: Baseline Spec Exclusion from Implementation Scope

The system SHALL NOT include tasks that modify baseline spec files (`openspec/specs/`) in the generated task list. Baseline spec changes SHALL flow exclusively through delta specs and `/opsx:sync`. During task generation, the system SHALL exclude any edits to files matching `openspec/specs/**/*` from implementation tasks. During `/opsx:apply`, the system SHALL NOT modify any file under `openspec/specs/` as part of task implementation. If a task description references baseline spec edits, the system SHALL skip that edit and note that spec changes are handled by `/opsx:sync`. Implementation tasks (sections 1-2) SHALL NOT include sync, archive, or other post-apply workflow steps. These steps MAY appear in the Standard Tasks section if defined in the project constitution.

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

#### Scenario: Implementation tasks exclude post-apply workflow steps

- **GIVEN** a change being processed through the artifact pipeline
- **WHEN** the tasks artifact is generated
- **THEN** implementation task sections (Foundation, Implementation) SHALL NOT include sync, archive, changelog, docs, or push steps
- **AND** these steps MAY appear in the Standard Tasks section if defined in the constitution

## Edge Cases

- **No standard tasks in constitution:** If the project constitution does not define a `## Standard Tasks` section, the tasks.md SHALL omit the Post-Implementation section entirely. Apply behavior is unchanged.
- **Standard tasks manually checked:** If a user manually marks standard tasks as `- [x]` before archive, the system SHALL count them as complete in progress totals.
- **Apply re-invoked after standard tasks complete:** If all tasks including standard tasks are marked complete, the system SHALL report "All tasks complete" and suggest archiving.

## Assumptions

<!-- ASSUMPTION: Standard tasks in the constitution use the same markdown checkbox format (- [ ]) as implementation tasks -->
<!-- ASSUMPTION: The agent can distinguish task sections by their ## heading numbers/titles -->
