## MODIFIED Requirements

### Requirement: Implement Tasks from Task List

The system SHALL work through pending task checkboxes in the change's `tasks.md` file when the user invokes `/opsx:apply`. For each task, the system SHALL read the task description, make the required code changes, and mark the task as complete by changing `- [ ]` to `- [x]` in the tasks file. The system SHALL read all context files (proposal, specs, design, tasks) before beginning implementation. The system SHALL pause and request clarification if a task is ambiguous, if implementation reveals a design issue, or if a blocker is encountered. The system SHALL NOT guess when requirements are unclear.

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

## Assumptions

- tasks.md uses standard markdown checkbox format (- [ ] / - [x]) as defined by the schema. <!-- ASSUMPTION: Checkbox format stability -->
- Task ordering in tasks.md represents the recommended implementation sequence, though the system may encounter out-of-order completions. <!-- ASSUMPTION: Ordering is recommended not enforced -->
- The apply skill has read/write access to both the tasks.md file and all project source files. <!-- ASSUMPTION: Skill file access -->
- Standard tasks in the constitution use the same markdown checkbox format (- [ ]) as implementation tasks. <!-- ASSUMPTION: Constitution checkbox format -->
- The agent can distinguish task sections by their ## heading numbers/titles. <!-- ASSUMPTION: Section heading parsing -->
