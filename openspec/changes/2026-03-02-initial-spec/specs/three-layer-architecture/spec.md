## ADDED Requirements

### Requirement: Constitution Layer
The system SHALL have a `constitution.md` file at `openspec/constitution.md` that defines global project rules. The constitution SHALL include sections for Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. All AI actions SHALL read the constitution before performing any work, enforced via `config.yaml` workflow rules. The constitution SHALL serve as the single authoritative source for project-wide rules that apply across all skills and artifacts.

**User Story:** As a project maintainer I want a single constitution file that governs all AI behavior, so that consistency is enforced without repeating rules in every skill.

#### Scenario: Constitution is read before any AI action
- **GIVEN** a project with `openspec/constitution.md` and `openspec/config.yaml` containing a rule to read the constitution
- **WHEN** any AI-driven skill is invoked
- **THEN** the constitution file is read and its rules are applied to the action

#### Scenario: Constitution contains all required sections
- **GIVEN** a freshly bootstrapped project
- **WHEN** the constitution is generated
- **THEN** the file SHALL contain Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections

### Requirement: Schema Layer
The system SHALL use the `opsx-enhanced` schema located at `openspec/schemas/opsx-enhanced/` to define a 6-stage artifact pipeline. The schema SHALL declare artifacts for research, proposal, specs, design, preflight, and tasks, each with a template, instruction, and dependency list. The schema SHALL be the single source of truth for pipeline structure and artifact generation instructions.

**User Story:** As a developer I want the artifact pipeline defined in a declarative schema, so that I can understand and modify the workflow without editing skill code.

#### Scenario: Schema defines the 6-stage pipeline
- **GIVEN** the schema file at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the schema is loaded by the OpenSpec CLI
- **THEN** it SHALL declare exactly 6 artifacts: research, proposal, specs, design, preflight, and tasks in that dependency order

#### Scenario: Each artifact has a template and instruction
- **GIVEN** the schema with 6 artifact definitions
- **WHEN** a specific artifact is inspected
- **THEN** it SHALL have a `generates` field, a `template` reference, an `instruction` block, and a `requires` dependency list

#### Scenario: Apply phase is gated by tasks
- **GIVEN** the schema with an `apply` section
- **WHEN** the apply phase configuration is inspected
- **THEN** it SHALL require the `tasks` artifact to be complete before implementation begins

### Requirement: Skills Layer
The system SHALL deliver all 13 commands as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills SHALL be categorized as workflow (6: new, continue, ff, apply, verify, archive), governance (5: init, bootstrap, discover, preflight, sync), or documentation (2: changelog, docs). All skills SHALL be model-invocable except `init`, which SHALL be user-only (one-time setup).

**User Story:** As a developer I want every command delivered as a SKILL.md file, so that Claude Code can discover and invoke them through its plugin system.

#### Scenario: All 13 skills are present
- **GIVEN** a fully installed plugin
- **WHEN** the `skills/` directory is listed
- **THEN** it SHALL contain exactly 13 subdirectories, each with a `SKILL.md` file

#### Scenario: Init is user-only
- **GIVEN** the `skills/init/SKILL.md` file
- **WHEN** its YAML frontmatter is inspected
- **THEN** the `disable-model-invocation` field SHALL be set to `true`

#### Scenario: All other skills are model-invocable
- **GIVEN** any skill other than `init`
- **WHEN** its YAML frontmatter is inspected
- **THEN** the `disable-model-invocation` field SHALL be set to `false` or be absent (defaulting to false)

### Requirement: Layer Separation
The three layers SHALL be independently modifiable. The schema SHALL NOT embed skill logic; instead, skills SHALL depend on the schema via the OpenSpec CLI. The constitution SHALL NOT contain schema-specific artifact definitions. Modifications to one layer SHALL NOT require changes to another layer unless the interface contract between them changes.

**User Story:** As a maintainer I want each layer to be independently modifiable, so that I can update pipeline stages without rewriting skills, or change global rules without touching the schema.

#### Scenario: Schema change does not require skill changes
- **GIVEN** the schema defines a new optional artifact stage
- **WHEN** the schema is updated with the new stage
- **THEN** existing skills SHALL continue to function without modification because they depend on the CLI, not the schema directly

#### Scenario: Constitution update does not require schema changes
- **GIVEN** a new code style rule is added to the constitution
- **WHEN** the constitution is updated
- **THEN** the schema SHALL remain unchanged because it does not embed constitution rules

#### Scenario: Skill update does not require constitution or schema changes
- **GIVEN** a skill's instruction text needs refinement
- **WHEN** the skill's SKILL.md is updated
- **THEN** neither the constitution nor the schema SHALL require modification

## Edge Cases

- If the constitution is missing or empty, skills SHALL report an error rather than proceeding without rules.
- If the schema is malformed YAML, the OpenSpec CLI SHALL reject it with a validation error before any artifact generation begins.
- If a skill directory exists but contains no SKILL.md file, the Claude Code plugin system SHALL not register that command.
- If a new skill is added without updating the constitution's skill count documentation, the system still functions but documentation is stale (detected by `/opsx:verify`).

## Assumptions

<!-- ASSUMPTION: The Claude Code plugin system discovers skills by scanning `skills/*/SKILL.md` files and uses YAML frontmatter for configuration. This is based on observed Claude Code behavior. -->
<!-- ASSUMPTION: The `config.yaml` workflow rules mechanism reliably enforces constitution reading before skill execution. -->
No further assumptions beyond those marked above.
