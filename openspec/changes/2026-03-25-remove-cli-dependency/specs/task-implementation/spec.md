---
order: 9
category: development
---

## MODIFIED Requirements

### Requirement: Implement Tasks from Task List

The system SHALL work through pending task checkboxes in the change's `tasks.md` file when the user invokes `/opsx:apply`. For each task, the system SHALL read the task description, make the required code changes, and mark the task as complete by changing `- [ ]` to `- [x]` in the tasks file. The system SHALL read all context files (proposal, specs, design, tasks) from the change directory before beginning implementation. The system SHALL read the `apply.instruction` field from schema.yaml for apply guidance. The system SHALL pause and request clarification if a task is ambiguous, if implementation reveals a design issue, or if a blocker is encountered. The system SHALL NOT guess when requirements are unclear.

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

## Edge Cases

- If tasks.md does not exist but the change has artifacts, the system SHALL inform the user and suggest running `/opsx:continue` or `/opsx:ff` to generate tasks first.

## Assumptions

No assumptions made.
