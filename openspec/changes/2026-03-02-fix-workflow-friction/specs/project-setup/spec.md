## MODIFIED Requirements

### Requirement: Install OpenSpec and Schema
The system SHALL provide `/opsx:init` as the single entry point for project setup. The init command SHALL install the OpenSpec CLI globally via npm, register the `opsx-enhanced` schema via `openspec schema init`, copy the plugin's custom schema files and templates into the project's `openspec/schemas/` directory, create a minimal `openspec/config.yaml` bootstrap (schema reference + constitution pointer), and create a constitution placeholder if none exists. The init command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps and report what was already in place.

The init skill SHALL set `disable-model-invocation: false` in its frontmatter so that it is discoverable and invocable via `/opsx:init`.

The init command SHALL NOT run `openspec init --tools claude` because that creates built-in OpenSpec skills (e.g. `openspec-apply-change`) in `.claude/skills/` that duplicate and conflict with the plugin's own `/opsx:*` skills. Schema initialization SHALL use `openspec schema init` directly, which works independently without prior `openspec init`.

The init command SHALL ensure target directories exist (via `mkdir -p`) before copying files from the plugin.

The init command SHALL generate config.yaml from a template rather than copying the plugin's own config.yaml. This prevents project-specific rules from leaking into consumer projects.

**User Story:** As a new user I want a single `/opsx:init` command that sets up everything, so that I do not have to manually install dependencies or configure the project.

#### Scenario: Config generated from template, not copied
- **GIVEN** a project directory without `openspec/config.yaml`
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL create a config.yaml containing only a `schema` reference and a `context` field pointing to the project constitution
- **AND** the config SHALL NOT contain workflow rules, per-artifact rules, or any content copied from the plugin's own config.yaml

#### Scenario: Existing config preserved
- **GIVEN** a project that already has `openspec/config.yaml`
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL preserve the existing config.yaml unchanged

### Requirement: Schema Validation
The init command SHALL validate the project setup after all installation steps complete. Validation SHALL confirm that the OpenSpec CLI is accessible and at a compatible version, the schema directory exists and contains a valid `schema.yaml`, and the `config.yaml` is present. The init command SHALL report a summary of validation results to the user.

#### Scenario: Successful validation after fresh init
- **GIVEN** the init command has completed all installation steps
- **WHEN** the validation phase runs
- **THEN** the system SHALL verify CLI accessibility, schema validity, and config presence, and report all checks as passing

## Edge Cases

- **Plugin config has project-specific rules**: The init template is hardcoded in the skill, not read from the plugin's own config.yaml. Even if the plugin maintainer adds project-specific rules to their config, consumer projects get a clean template.

No assumptions made.
