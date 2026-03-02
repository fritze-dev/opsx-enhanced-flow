## MODIFIED Requirements

### Requirement: Constitution Contains Only Project-Specific Rules
The constitution SHALL contain only rules that are specific to the project and not already defined by the schema or its templates. Rules that duplicate schema instructions, templates, or artifact `requires` chains SHALL be removed. The constitution retains: Tech Stack, Architecture Rules (structure and paths), Code Style (project conventions not in schema), Constraints (principles not enforced by schema mechanics), and Conventions.

**User Story:** As a workflow maintainer I want the constitution free of redundancy, so that each rule lives in exactly one authoritative place and the constitution stays focused on project-specific knowledge.

#### Scenario: Constitution does not duplicate schema-defined rules

- **GIVEN** the project constitution at `openspec/constitution.md`
- **WHEN** its contents are compared with the schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **THEN** the constitution SHALL NOT contain rules about spec format, task format, assumption markers, capability naming, or artifact pipeline ordering
- **AND** those rules SHALL exist only in the schema's `instruction` fields or templates

#### Scenario: Constitution retains project-specific content

- **GIVEN** the project constitution
- **WHEN** its sections are inspected
- **THEN** it SHALL contain Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions
- **AND** Architecture Rules SHALL include directory paths and structural decisions
- **AND** Conventions SHALL include commit style, version bump, and friction tracking

## ADDED Requirements

### Requirement: Friction Tracking Convention

The constitution's Conventions section SHALL include a rule requiring that workflow friction discovered during any workflow run be captured as a GitHub Issue with the `friction` label. The convention SHALL specify that each issue must include: what happened, expected behavior, and a suggested fix.

**User Story:** As a plugin maintainer I want a convention for capturing workflow friction systematically, so that problems discovered during dogfooding are tracked and addressed instead of being lost in conversation history.

#### Scenario: Friction convention present in constitution

- **GIVEN** the project constitution at `openspec/constitution.md`
- **WHEN** the Conventions section is inspected
- **THEN** it SHALL contain a "Workflow friction" entry
- **AND** the entry SHALL require capturing friction as GitHub Issues with the `friction` label
- **AND** the entry SHALL specify including: what happened, expected behavior, and suggested fix

## Edge Cases

- **Friction in non-plugin projects**: The convention applies to all projects using the opsx workflow, not just the plugin itself. Consumer projects should track friction in their own issue trackers.
- **New schema version adds rules**: When the schema is updated with new instructions, the constitution should be audited for newly-redundant entries.

No assumptions made.
