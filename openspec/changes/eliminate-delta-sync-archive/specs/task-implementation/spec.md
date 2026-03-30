## MODIFIED Requirements

### Requirement: Implement Tasks from Task List

The system SHALL work through pending task checkboxes in the change's `tasks.md` file when the user invokes `/opsx:apply`. The system SHALL read all context files (proposal, design, tasks) from the change directory and baseline specs from `openspec/specs/` for the capabilities listed in the proposal before beginning implementation.

#### Scenario: Implement all tasks with baseline spec context

- **GIVEN** a change with tasks.md containing 5 pending tasks
- **AND** the proposal references capabilities "user-auth" and "quality-gates"
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system reads proposal.md and design.md from the change directory
- **AND** reads `openspec/specs/user-auth/spec.md` and `openspec/specs/quality-gates/spec.md`
- **AND** works through each pending task in order

### Requirement: Baseline Spec Edits During Implementation

The system SHALL allow implementation tasks to modify baseline spec files (`openspec/specs/`) when required by the task description. Unlike the previous workflow where baseline specs were exclusively updated via sync, direct spec edits during implementation ARE permitted because specs are now edited directly during the specs stage and may need refinements during implementation. Implementation tasks (sections 1-2) SHALL NOT include post-apply workflow steps (changelog, docs, version bump). These steps SHALL appear in the Standard Tasks section.

**User Story:** As a developer I want to be able to refine specs during implementation if needed, so that specs stay accurate as implementation reveals edge cases.

#### Scenario: Task refines a baseline spec during implementation

- **GIVEN** a task that says "Add edge case for empty input to user-auth spec"
- **WHEN** the system implements this task
- **THEN** the system SHALL edit `openspec/specs/user-auth/spec.md` to add the edge case
- **AND** SHALL mark the task as complete

#### Scenario: Implementation tasks exclude post-apply workflow steps

- **GIVEN** a change being processed through the artifact pipeline
- **WHEN** the tasks artifact is generated
- **THEN** implementation task sections (Foundation, Implementation) SHALL NOT include changelog, docs, or version bump steps
- **AND** these steps SHALL appear in the Standard Tasks section

### Requirement: Standard Tasks Exclusion from Apply Scope

The system SHALL distinguish between implementation tasks (Foundation, Implementation, QA Loop sections) and standard tasks (Post-Implementation section) in the generated `tasks.md`. During `/opsx:apply`, the system SHALL only process tasks in the implementation and QA sections. Standard tasks in the Post-Implementation section SHALL NOT be executed by the apply phase. During the post-apply workflow, the system SHALL mark all standard task checkboxes as complete in `tasks.md` — including universal steps and constitution-defined pre-merge extras — before creating the final commit. Constitution-defined post-merge tasks SHALL remain unchecked as reminders for manual execution after the PR is merged.

#### Scenario: Apply skips standard tasks section

- **GIVEN** a tasks.md with sections 1-3 (Foundation, Implementation, QA Loop) and section 4 (Standard Tasks Post-Implementation) containing 3 unchecked items
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL work through pending tasks in sections 1-3 only
- **AND** section 4 items SHALL remain as `- [ ]` after apply completes

## REMOVED Requirements

### Requirement: Baseline Spec Exclusion from Implementation Scope

**Reason:** With the elimination of delta specs and sync, baseline specs are now edited directly. The restriction preventing apply from modifying `openspec/specs/` is removed because there is no longer a separate sync pipeline. Spec edits during implementation are a natural part of the workflow.

**Migration:** Tasks that previously deferred spec edits to sync now include spec edits directly in the implementation task list.

## Edge Cases

- **Change with only spec modifications (no code):** If a change modifies only specs and has no code implementation, the tasks list implementation sections may contain only spec-editing tasks. The QA loop still applies.
- **Empty tasks.md**: If tasks.md exists but contains no checkbox items, the system SHALL report "0/0 tasks" and suggest the tasks file may need to be regenerated.

## Assumptions

- tasks.md uses standard markdown checkbox format (- [ ] / - [x]). <!-- ASSUMPTION: Checkbox format stability -->
No further assumptions beyond those marked above.
