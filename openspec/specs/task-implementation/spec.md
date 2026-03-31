---
order: 9
category: development
---
## Purpose

Handles `/opsx:apply` for working through task checklists in tasks.md, with sequential implementation, progress tracking, pause-on-blocker behavior, and session-level progress reporting.

## Requirements

### Requirement: Implement Tasks from Task List

The system SHALL work through pending task checkboxes in the change's `tasks.md` file when the user invokes `/opsx:apply`. For each task, the system SHALL read the task description, make the required code changes, and mark the task as complete by changing `- [ ]` to `- [x]` in the tasks file. The system SHALL read all context files (proposal, design, tasks) from the change directory and specs from `openspec/specs/` for the capabilities listed in the proposal before beginning implementation. The system SHALL read the `apply.instruction` field from WORKFLOW.md for apply guidance. The system SHALL pause and request clarification if a task is ambiguous, if implementation reveals a design issue, or if a blocker is encountered. The system SHALL NOT guess when requirements are unclear.

**User Story:** As a developer I want the AI to systematically work through my task list and implement each item, so that I can focus on review and guidance rather than manual coding of each task.

#### Scenario: Implement all tasks sequentially

- **GIVEN** a change named "add-user-auth" with a tasks.md containing 5 pending tasks
- **AND** all pipeline artifacts (proposal, specs, design) are available as context in the change directory
- **WHEN** the user invokes `/opsx:apply add-user-auth`
- **THEN** the system reads all context files from the change directory and the apply instruction from schema.yaml
- **AND** works through each pending task in order
- **AND** makes the code changes described by each task
- **AND** marks each task `- [x]` immediately after completing it
- **AND** continues to the next task until all are done or a blocker is hit

#### Scenario: Resume partially completed task list

- **GIVEN** a change with tasks.md containing 3 completed and 4 pending tasks
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system skips the 3 already-completed tasks
- **AND** begins working from the first pending task (task 4 of 7)
- **AND** displays "3/7 tasks already complete, continuing from task 4"

#### Scenario: Pause on ambiguous task

- **GIVEN** a task description that is unclear or could be interpreted multiple ways
- **WHEN** the system encounters this task during apply
- **THEN** the system SHALL pause implementation
- **AND** SHALL present the ambiguity to the user with suggested interpretations
- **AND** SHALL wait for user guidance before proceeding

### Requirement: Progress Tracking

The system SHALL report implementation progress using checkbox counts from the tasks file. Progress SHALL be displayed as "N/M tasks complete" where N is the count of `- [x]` items and M is the total count of checkbox items. The system SHALL show progress at the start of an apply session, after each task completion, and in the final summary. When all tasks are complete, the system SHALL display a completion message with the total count.

**User Story:** As a developer I want to see clear progress counts as tasks are completed, so that I can track how much work remains and estimate time to completion.

#### Scenario: Display progress at session start

- **GIVEN** a change with tasks.md containing 2 completed and 5 pending tasks
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system displays "Progress: 2/7 tasks complete" before starting implementation

#### Scenario: Update progress after each task

- **GIVEN** the system has just completed task 3 of 7
- **WHEN** the checkbox is marked complete in tasks.md
- **THEN** the system displays "Progress: 3/7 tasks complete"
- **AND** announces which task it will work on next

#### Scenario: Display final summary on completion

- **GIVEN** the system has completed the last pending task (task 7 of 7)
- **WHEN** the final checkbox is marked complete
- **THEN** the system displays "Progress: 7/7 tasks complete"
- **AND** lists all tasks completed during the current session
- **AND** suggests running the post-apply workflow

#### Scenario: Display progress on pause

- **GIVEN** the system pauses at task 4 of 7 due to a blocker
- **WHEN** the pause message is displayed
- **THEN** the system includes "Progress: 3/7 tasks complete"
- **AND** shows which task caused the pause
- **AND** presents options for how to proceed

#### Scenario: Handle parallelizable task markers

- **GIVEN** tasks.md contains tasks marked with `[P]` indicating they can be done in parallel
- **WHEN** the system displays progress
- **THEN** the progress count SHALL still be based on individual checkbox completion
- **AND** the `[P]` marker SHALL be informational only (no change to counting logic)

### Requirement: Standard Tasks Exclusion from Apply Scope

The system SHALL distinguish between implementation tasks (Foundation, Implementation, QA Loop sections) and standard tasks (Post-Implementation section) in the generated `tasks.md`. During `/opsx:apply`, the system SHALL only process tasks in the implementation and QA sections. Standard tasks in the Post-Implementation section SHALL NOT be executed by the apply phase. Standard tasks SHALL remain as unchecked `- [ ]` items after apply completes. The standard tasks section SHALL be included in the total checkbox count for progress reporting, reflecting the full workflow completion state. During the post-apply workflow, the system SHALL mark all standard task checkboxes as complete in `tasks.md` — including universal steps and constitution-defined pre-merge extras — before creating the final commit, so that the committed file reflects the fully-checked state. Constitution-defined post-merge tasks SHALL remain unchecked as reminders for manual execution after the PR is merged.

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

#### Scenario: All standard tasks marked before commit

- **GIVEN** a tasks.md with all implementation tasks complete and standard tasks including universal steps (changelog, docs, version bump, commit and push), pre-merge extras (e.g., update PR), and post-merge extras (e.g., update plugin) unchecked
- **AND** the post-apply workflow has completed all steps including pre-merge constitution extras
- **WHEN** the system is about to create the final commit
- **THEN** the system SHALL mark universal and pre-merge standard task checkboxes as `- [x]` in tasks.md
- **AND** post-merge standard tasks SHALL remain as `- [ ]`
- **AND** the committed tasks.md SHALL reflect the pre-merge/post-merge distinction
- **AND** no extra follow-up commit SHALL be needed for pre-merge standard task checkboxes

### Requirement: Spec Edits During Implementation

The system SHALL allow implementation tasks to modify spec files (`openspec/specs/`) when required by the task description. Specs are edited directly during the specs stage and may need refinements during implementation. Implementation tasks (sections 1-2) SHALL NOT include post-apply workflow steps (changelog, docs, version bump). These steps SHALL appear in the Standard Tasks section.

**User Story:** As a developer I want to be able to refine specs during implementation if needed, so that specs stay accurate as implementation reveals edge cases.

#### Scenario: Task refines a spec during implementation

- **GIVEN** a task that says "Add edge case for empty input to user-auth spec"
- **WHEN** the system implements this task
- **THEN** the system SHALL edit `openspec/specs/user-auth/spec.md` to add the edge case
- **AND** SHALL mark the task as complete

#### Scenario: Implementation tasks exclude post-apply workflow steps

- **GIVEN** a change being processed through the artifact pipeline
- **WHEN** the tasks artifact is generated
- **THEN** implementation task sections (Foundation, Implementation) SHALL NOT include changelog, docs, or version bump steps
- **AND** these steps SHALL appear in the Standard Tasks section

## Edge Cases

- **Change with only spec modifications (no code):** If a change modifies only specs and has no code implementation, the tasks list implementation sections may contain only spec-editing tasks. The QA loop still applies.
- **Empty tasks.md**: If tasks.md exists but contains no checkbox items, the system SHALL report "0/0 tasks" and suggest the tasks file may need to be regenerated.
- **Malformed checkboxes**: If tasks.md contains checkbox-like items that do not follow the `- [ ]` / `- [x]` format exactly, the system SHALL ignore them in the count and note the discrepancy.
- **Tasks modified externally**: If the user manually edits tasks.md between apply invocations (adding, removing, or reordering tasks), the system SHALL re-read the file and compute progress from the current state.
- If tasks.md does not exist but the change has artifacts, the system SHALL inform the user and suggest running `/opsx:continue` or `/opsx:ff` to generate tasks first.
- **Mixed checkbox states mid-file**: If completed tasks appear after pending tasks (out of order), the system SHALL still count correctly and work on pending tasks regardless of position.
- **Single task remaining**: The system SHALL handle the case where only one task remains with the same progress reporting format ("6/7 tasks complete").
- **No standard tasks in constitution:** If the project constitution does not define a `## Standard Tasks` section, the tasks.md SHALL omit the Post-Implementation section entirely. Apply behavior is unchanged.
- **Standard tasks manually checked:** If a user manually marks standard tasks as `- [x]` before completion, the system SHALL count them as complete in progress totals.
- **Apply re-invoked after standard tasks complete:** If all tasks including standard tasks are marked complete, the system SHALL report "All tasks complete" and suggest running the post-apply workflow.
- **Pre-merge extras executed during post-apply:** Constitution-defined pre-merge standard tasks (e.g., "Update PR") SHALL be executed during the post-apply workflow after commit and push. Post-merge tasks (e.g., "Update plugin") SHALL remain unchecked — they are executed manually after the PR is merged.
- **Constitution extra fails:** If a constitution extra fails (e.g., `gh pr ready` fails due to network), the agent SHALL note the failure, skip marking that task as complete, and continue with remaining extras. The failed task remains as `- [ ]` for manual resolution.
- **Partial post-apply workflow:** If the post-apply workflow is interrupted (e.g., changelog fails), only the steps that actually completed should be marked. The commit step should not be marked if the commit does not happen.

## Assumptions

- tasks.md uses standard markdown checkbox format (- [ ] / - [x]) as defined by the schema. <!-- ASSUMPTION: Checkbox format stability -->
- Task ordering in tasks.md represents the recommended implementation sequence, though the system may encounter out-of-order completions. <!-- ASSUMPTION: Ordering is recommended not enforced -->
- The apply skill has read/write access to both the tasks.md file and all project source files. <!-- ASSUMPTION: Skill file access -->
- Standard tasks in the constitution use the same markdown checkbox format (- [ ]) as implementation tasks. <!-- ASSUMPTION: Constitution checkbox format -->
- The agent can distinguish task sections by their ## heading numbers/titles. <!-- ASSUMPTION: Section heading parsing -->
