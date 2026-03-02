## MODIFIED Requirements

### Requirement: Config Bootstrap
The `openspec/config.yaml` SHALL serve as a minimal bootstrap file. It SHALL contain only the schema reference and a global `context` pointing to the project constitution. All workflow rules SHALL be owned by the schema (in artifact `instruction` fields) or the constitution (project-specific rules) — not by config.yaml.

**User Story:** As a workflow maintainer I want config.yaml to be minimal, so that workflow rules live at their authoritative source (schema for universal rules, constitution for project rules) instead of being duplicated in config.

#### Scenario: Config contains only bootstrap content

- **GIVEN** the `openspec/config.yaml` file
- **WHEN** its contents are inspected
- **THEN** it SHALL contain a `schema` field referencing the active schema
- **AND** a `context` field pointing to the project constitution
- **AND** no other workflow rules or per-artifact `rules` entries

### Requirement: Schema Owns Workflow Rules
The schema's artifact `instruction` fields SHALL contain workflow rules that apply to all projects using the schema. The `tasks.instruction` SHALL include the Definition of Done rule (emergent from artifacts). The `apply.instruction` SHALL include the post-apply workflow sequence.

#### Scenario: Tasks instruction includes DoD rule

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `tasks.instruction` field is inspected
- **THEN** it SHALL contain a rule stating that Definition of Done is emergent from artifacts
- **AND** it SHALL reference Gherkin scenarios, success metrics, preflight findings, and user approval

#### Scenario: Apply instruction includes post-apply workflow

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL contain the post-apply sequence: `/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → commit

## Edge Cases

- **Projects without a constitution**: If a project using opsx-enhanced has no constitution file, the config.yaml context pointer is harmless — the AI will note the missing file and proceed.
- **Migration from old config**: Existing projects with workflow rules in config.yaml context will continue to work — the rules are additive to schema instructions.

No assumptions made.
