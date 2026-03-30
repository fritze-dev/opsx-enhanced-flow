## MODIFIED Requirements

### Requirement: Constitution Contains Only Project-Specific Rules

The constitution SHALL contain only rules that are specific to the project and not already defined by the schema or its templates. Rules that duplicate schema instructions, templates, or artifact `requires` chains SHALL be removed. The constitution retains: Tech Stack, Architecture Rules (structure and paths), Code Style (project conventions not in schema), Constraints (principles not enforced by schema mechanics), Conventions, and Standard Tasks (project-specific post-implementation steps appended to the universal standard tasks in the schema template). Standard Tasks that update the PR body SHALL include GitHub issue-closing keywords (e.g., `Closes #X`) when the change originated from a GitHub issue, to ensure issues are auto-closed on merge regardless of merge strategy.

**User Story:** As a workflow maintainer I want the constitution free of redundancy, so that each rule lives in exactly one authoritative place and the constitution stays focused on project-specific knowledge.

#### Scenario: Constitution does not duplicate schema-defined rules

- **GIVEN** the project constitution at `openspec/constitution.md`
- **WHEN** its contents are compared with the schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **THEN** the constitution SHALL NOT contain rules about spec format, task format, assumption markers, capability naming, or artifact pipeline ordering
- **AND** those rules SHALL exist only in the schema's `instruction` fields or templates

#### Scenario: Constitution retains project-specific content

- **GIVEN** the project constitution
- **WHEN** its sections are inspected
- **THEN** it SHALL contain Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and Standard Tasks
- **AND** Architecture Rules SHALL include directory paths and structural decisions
- **AND** Conventions SHALL include commit style, version bump, README accuracy, and friction tracking
- **AND** Standard Tasks SHALL contain project-specific post-implementation steps (or be empty with an explanatory comment)

#### Scenario: PR body update includes issue-closing keywords

- **GIVEN** a change that originated from GitHub issue #42
- **AND** the constitution defines a pre-merge standard task to update the PR body
- **WHEN** the agent executes the PR body update task
- **THEN** the updated PR body SHALL include `Closes #42`
- **AND** the issue SHALL be auto-closed when the PR is merged (regardless of merge strategy)

#### Scenario: No issue linked — keywords omitted

- **GIVEN** a change that did not originate from a GitHub issue
- **WHEN** the agent executes the PR body update task
- **THEN** the updated PR body SHALL NOT include issue-closing keywords

## Edge Cases

- **Multiple issues:** If a change addresses multiple issues, all should be referenced (e.g., `Closes #42, Closes #43`).

## Assumptions

No assumptions made.
