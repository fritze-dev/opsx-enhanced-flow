---
order: 13
category: reference
---

## MODIFIED Requirements

### Requirement: Schema Layer
The system SHALL use the `opsx-enhanced` schema located at `openspec/schemas/opsx-enhanced/` to define a 6-stage artifact pipeline. The schema SHALL declare artifacts for research, proposal, specs, design, preflight, and tasks, each with a template, instruction, and dependency list. The schema SHALL be the single source of truth for pipeline structure and artifact generation instructions. Skills SHALL read schema.yaml directly to obtain artifact definitions, instructions, and dependency information.

**User Story:** As a developer I want the artifact pipeline defined in a declarative schema, so that I can understand and modify the workflow without editing skill code.

#### Scenario: Schema defines the 6-stage pipeline
- **GIVEN** the schema file at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the schema is read by a skill
- **THEN** it SHALL declare exactly 6 artifacts: research, proposal, specs, design, preflight, and tasks in that dependency order

#### Scenario: Each artifact has a template and instruction
- **GIVEN** the schema with 6 artifact definitions
- **WHEN** a specific artifact is inspected
- **THEN** it SHALL have a `generates` field, a `template` reference, an `instruction` block, and a `requires` dependency list

#### Scenario: Apply phase is gated by tasks
- **GIVEN** the schema with an `apply` section
- **WHEN** the apply phase configuration is inspected
- **THEN** it SHALL require the `tasks` artifact to be complete before implementation begins

### Requirement: Layer Separation
The three layers SHALL be independently modifiable. The schema SHALL NOT embed skill logic; instead, skills SHALL depend on the schema by reading `schema.yaml` directly for artifact definitions, instructions, and dependencies. The constitution SHALL NOT contain schema-specific artifact definitions. Modifications to one layer SHALL NOT require changes to another layer unless the interface contract between them changes.

**User Story:** As a maintainer I want each layer to be independently modifiable, so that I can update pipeline stages without rewriting skills, or change global rules without touching the schema.

#### Scenario: Schema change does not require skill changes
- **GIVEN** the schema defines a new optional artifact stage
- **WHEN** the schema is updated with the new stage
- **THEN** existing skills SHALL continue to function without modification because they read schema.yaml dynamically at runtime

#### Scenario: Constitution update does not require schema changes
- **GIVEN** a new code style rule is added to the constitution
- **WHEN** the constitution is updated
- **THEN** the schema SHALL remain unchanged because it does not embed constitution rules

#### Scenario: Skill update does not require constitution or schema changes
- **GIVEN** a skill's instruction text needs refinement
- **WHEN** the skill's SKILL.md is updated
- **THEN** neither the constitution nor the schema SHALL require modification

## Edge Cases

- If the schema is malformed YAML, skills SHALL report a read error rather than proceeding with invalid data.
- If a skill directory exists but contains no SKILL.md file, the Claude Code plugin system SHALL not register that command.

## Assumptions

- The Claude Code plugin system discovers skills by scanning `skills/*/SKILL.md` files and uses YAML frontmatter for configuration. This is based on observed Claude Code behavior. <!-- ASSUMPTION: Skill discovery mechanism -->
- The `config.yaml` workflow rules mechanism reliably enforces constitution reading before skill execution. <!-- ASSUMPTION: Config enforcement -->
No further assumptions beyond those marked above.
