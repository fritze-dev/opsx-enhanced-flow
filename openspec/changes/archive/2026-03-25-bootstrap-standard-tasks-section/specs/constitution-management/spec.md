## MODIFIED Requirements

### Requirement: Constitution Contains Only Project-Specific Rules
The constitution SHALL contain only rules that are specific to the project and not already defined by the schema or its templates. Rules that duplicate schema instructions, templates, or artifact `requires` chains SHALL be removed. The constitution retains: Tech Stack, Architecture Rules (structure and paths), Code Style (project conventions not in schema), Constraints (principles not enforced by schema mechanics), Conventions, and Standard Tasks (project-specific post-implementation steps appended to the universal standard tasks in the schema template).

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

## Edge Cases

- If a project has no project-specific standard tasks, the section remains empty with an HTML comment — it is not removed.

## Assumptions

No assumptions made.
