## MODIFIED Requirements

### Requirement: Standard Tasks Exclusion from Apply Scope

The system SHALL distinguish between implementation tasks (Foundation, Implementation, QA Loop sections) and standard tasks (Post-Implementation section) in the generated `tasks.md`. During `/opsx:apply`, the system SHALL only process tasks in the implementation and QA sections. Standard tasks in the Post-Implementation section SHALL NOT be executed by the apply phase. Standard tasks SHALL remain as unchecked `- [ ]` items after apply completes. The standard tasks section SHALL be included in the total checkbox count for progress reporting, reflecting the full workflow completion state. The `/opsx:archive` incomplete-task check SHALL detect unchecked standard tasks, providing a safety net against forgotten post-implementation steps. During the post-apply workflow, the system SHALL mark all standard task checkboxes as complete in `tasks.md` — including universal steps and constitution-defined pre-merge extras — before creating the final commit, so that the committed file reflects the fully-checked state. Constitution-defined post-merge tasks SHALL remain unchecked as reminders for manual execution after the PR is merged.

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

#### Scenario: All standard tasks marked before commit

- **GIVEN** a tasks.md with all implementation tasks complete and standard tasks including universal steps (archive, changelog, docs, commit and push), pre-merge extras (e.g., update PR), and post-merge extras (e.g., update plugin) unchecked
- **AND** the post-apply workflow has completed all steps including pre-merge constitution extras
- **WHEN** the system is about to create the final commit
- **THEN** the system SHALL mark universal and pre-merge standard task checkboxes as `- [x]` in tasks.md
- **AND** post-merge standard tasks SHALL remain as `- [ ]`
- **AND** the committed tasks.md SHALL reflect the pre-merge/post-merge distinction
- **AND** no extra follow-up commit SHALL be needed for pre-merge standard task checkboxes

## Edge Cases

- **Pre-merge extras executed during post-apply:** Constitution-defined pre-merge standard tasks (e.g., "Update PR") SHALL be executed during the post-apply workflow after commit and push. Post-merge tasks (e.g., "Update plugin") SHALL remain unchecked — they are executed manually after the PR is merged.
- **Constitution extra fails:** If a constitution extra fails (e.g., `gh pr ready` fails due to network), the agent SHALL note the failure, skip marking that task as complete, and continue with remaining extras. The failed task remains as `- [ ]` for manual resolution.
- **Partial post-apply workflow:** If the post-apply workflow is interrupted (e.g., changelog fails), only the steps that actually completed should be marked. The commit step should not be marked if the commit does not happen.

## Assumptions

No assumptions made.
