## MODIFIED Requirements

### Requirement: Standard Tasks Exclusion from Apply Scope

The system SHALL distinguish between implementation tasks (Foundation, Implementation, QA Loop sections) and standard tasks (Post-Implementation section) in the generated `tasks.md`. During `/opsx:apply`, the system SHALL only process tasks in the implementation and QA sections. Standard tasks in the Post-Implementation section SHALL NOT be executed by the apply phase. Standard tasks SHALL remain as unchecked `- [ ]` items after apply completes. The standard tasks section SHALL be included in the total checkbox count for progress reporting, reflecting the full workflow completion state. The `/opsx:archive` incomplete-task check SHALL detect unchecked standard tasks, providing a safety net against forgotten post-implementation steps. During the post-apply workflow, the system SHALL mark all standard task checkboxes as complete in `tasks.md` — including the commit step itself — before creating the final commit, so that the committed file reflects the fully-checked state.

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

#### Scenario: Standard tasks marked before commit

- **GIVEN** a tasks.md with all implementation tasks complete and standard tasks 4.1 (archive), 4.2 (changelog), 4.3 (docs), and 4.4 (commit and push) unchecked
- **AND** the post-apply workflow has completed archive, changelog, and docs steps
- **WHEN** the system is about to create the final commit
- **THEN** the system SHALL mark all standard task checkboxes as `- [x]` in tasks.md — including the commit step itself
- **AND** the committed tasks.md SHALL contain all standard tasks as `- [x]`
- **AND** no extra follow-up commit SHALL be needed for standard task checkboxes

## Edge Cases

- **Constitution extras not executed:** If the constitution defines extra standard tasks (e.g., 4.5), those remain unchecked unless the user marks them manually. Only the universal standard tasks (4.1-4.4) are marked by the post-apply workflow.
- **Partial post-apply workflow:** If the post-apply workflow is interrupted (e.g., changelog fails), only the steps that actually completed should be marked. The commit step (4.4) should not be marked if the commit does not happen.

## Assumptions

No assumptions made.
