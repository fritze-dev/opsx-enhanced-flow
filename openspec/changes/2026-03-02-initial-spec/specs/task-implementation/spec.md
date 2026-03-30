# Task Implementation

## ADDED Requirements

### Requirement: Implement Tasks from Task List

The system SHALL work through pending task checkboxes in the change's `tasks.md` file when the user invokes `/opsx:apply`. For each task, the system SHALL read the task description, make the required code changes, and mark the task as complete by changing `- [ ]` to `- [x]` in the tasks file. The system SHALL read all context files (proposal, specs, design, tasks) before beginning implementation. The system SHALL pause and request clarification if a task is ambiguous, if implementation reveals a design issue, or if a blocker is encountered. The system SHALL NOT guess when requirements are unclear.

<!-- ASSUMPTION: tasks.md uses standard markdown checkbox format (- [ ] / - [x]) as defined by the schema -->

**User Story:** As a developer I want the AI to systematically work through my task list and implement each item, so that I can focus on review and guidance rather than manual coding of each task.

#### Scenario: Implement all tasks sequentially

- **GIVEN** a change named "add-user-auth" with a tasks.md containing 5 pending tasks
- **AND** all pipeline artifacts (proposal, specs, design) are available as context
- **WHEN** the user invokes `/opsx:apply add-user-auth`
- **THEN** the system reads all context files listed in `openspec instructions apply` output
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
- **AND** SHALL present the ambiguity to the user with specific questions
- **AND** SHALL NOT implement the task until the user provides clarification

#### Scenario: Pause on design issue discovered during implementation

- **GIVEN** the system is implementing a task
- **AND** discovers that the design.md approach will not work due to a technical constraint
- **WHEN** the issue is identified
- **THEN** the system SHALL pause and report the issue
- **AND** SHALL suggest updating the relevant artifact (design.md, specs, or tasks.md)
- **AND** SHALL NOT continue with an approach that contradicts the design

#### Scenario: All tasks already complete

- **GIVEN** a change where all tasks in tasks.md are marked `- [x]`
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL report "All tasks complete"
- **AND** SHALL suggest archiving the change

#### Scenario: Tasks artifact is blocked

- **GIVEN** a change where the tasks artifact has not been created yet (missing prerequisites)
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL report that apply is blocked due to missing artifacts
- **AND** SHALL suggest running `/opsx:continue` or `/opsx:ff` to generate the required artifacts

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
- **AND** suggests archiving the change

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

## Edge Cases

- **Empty tasks.md**: If tasks.md exists but contains no checkbox items, the system SHALL report "0/0 tasks" and suggest the tasks file may need to be regenerated.
- **Malformed checkboxes**: If tasks.md contains checkbox-like items that do not follow the `- [ ]` / `- [x]` format exactly, the system SHALL ignore them in the count and note the discrepancy.
- **Tasks modified externally**: If the user manually edits tasks.md between apply invocations (adding, removing, or reordering tasks), the system SHALL re-read the file and compute progress from the current state.
- **No tasks.md file**: If the tasks artifact does not exist, the system SHALL report the missing artifact and suggest running the artifact pipeline to generate it.
- **Mixed checkbox states mid-file**: If completed tasks appear after pending tasks (out of order), the system SHALL still count correctly and work on pending tasks regardless of position.
- **Single task remaining**: The system SHALL handle the case where only one task remains with the same progress reporting format ("6/7 tasks complete").

## Assumptions

<!-- ASSUMPTION: tasks.md checkbox format is stable and follows the schema template (- [ ] and - [x]) -->
<!-- ASSUMPTION: Task ordering in tasks.md represents the recommended implementation sequence, though the system may encounter out-of-order completions -->
<!-- ASSUMPTION: The apply skill has read/write access to both the tasks.md file and all project source files -->
