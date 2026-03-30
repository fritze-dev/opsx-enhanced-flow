---
order: 1
category: setup
---

## MODIFIED Requirements

### Requirement: Install OpenSpec and Schema
The system SHALL provide `/opsx:setup` as the single entry point for project setup. The setup command SHALL copy the plugin's custom schema files and templates into the project's `openspec/schemas/` directory, create a minimal `openspec/config.yaml` bootstrap (schema reference + constitution pointer + commented-out `docs_language` field + English-enforcement rule for workflow artifacts), and create a constitution placeholder if none exists. The setup command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps and report what was already in place.

The setup skill SHALL set `disable-model-invocation: false` in its frontmatter so that it is discoverable and invocable via `/opsx:setup`.

The setup command SHALL NOT install any external CLI tools or require Node.js/npm as prerequisites.

The setup command SHALL ensure target directories exist (via `mkdir -p`) before copying files from the plugin.

The setup command SHALL generate config.yaml from a template rather than copying the plugin's own config.yaml. This prevents project-specific rules from leaking into consumer projects.

The generated config.yaml SHALL include a commented-out `docs_language: English` field for discoverability. The `context` field SHALL include a rule stating that all workflow artifacts (research, proposal, specs, design, preflight, tasks) must be written in English regardless of `docs_language`.

**User Story:** As a new user I want a single `/opsx:setup` command that sets up everything, so that I do not have to manually install dependencies or configure the project.

#### Scenario: First-time project initialization
- **GIVEN** a project directory without the opsx-enhanced schema installed
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL copy custom schema files from the plugin, create config.yaml, create a constitution placeholder, and verify the schema files are readable

#### Scenario: Idempotent re-initialization
- **GIVEN** a project that has already been initialized with `/opsx:setup`
- **WHEN** the user runs `/opsx:setup` again
- **THEN** the system SHALL skip already-completed steps, preserve existing constitution.md, and report which components were already in place

#### Scenario: No duplicate skill creation
- **GIVEN** a project where the opsx plugin is already installed
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL NOT create any `.claude/skills/openspec-*` skill files that would duplicate the plugin's `/opsx:*` skills

#### Scenario: Config generated from template, not copied
- **GIVEN** a project directory without `openspec/config.yaml`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL create a config.yaml containing a `schema` reference, a commented-out `docs_language` field, and a `context` field pointing to the project constitution with an English-enforcement rule for workflow artifacts
- **AND** the config SHALL NOT contain workflow rules, per-artifact rules, or any content copied from the plugin's own config.yaml

#### Scenario: Existing config preserved
- **GIVEN** a project that already has `openspec/config.yaml`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL preserve the existing config.yaml unchanged

#### Scenario: Config includes docs_language for discoverability
- **GIVEN** a project directory without `openspec/config.yaml`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the generated config.yaml SHALL include `# docs_language: English` as a commented-out field
- **AND** SHALL include a context rule enforcing English for all workflow artifacts

### Requirement: Schema Validation
The setup command SHALL validate the project setup after all installation steps complete. Validation SHALL confirm that the schema directory exists and contains a readable `schema.yaml`, and that `config.yaml` is present. The setup command SHALL report a summary of validation results to the user.

**User Story:** As a user I want setup to verify everything works after setup, so that I can trust the environment is ready for spec-driven development.

#### Scenario: Successful validation after fresh setup
- **GIVEN** the setup command has completed all installation steps
- **WHEN** the validation phase runs
- **THEN** the system SHALL verify that `openspec/schemas/opsx-enhanced/schema.yaml` is readable and `openspec/config.yaml` is present, and report all checks as passing

#### Scenario: Validation detects partial setup failure
- **GIVEN** the setup command completed but the schema copy failed silently
- **WHEN** the validation phase runs
- **THEN** the system SHALL detect the missing schema and report which specific validation check failed

## REMOVED Requirements

### Requirement: OpenSpec CLI Prerequisite Check
**Reason**: The OpenSpec CLI is no longer a dependency. Skills read schema.yaml and templates directly instead of shelling out to CLI commands.
**Migration**: Setup no longer installs or checks for the CLI. Schema validation is done by reading the local schema.yaml file.

## Edge Cases

- If the user does not have write permissions to the project directory, setup SHALL fail before making any changes and report the permission issue.
- Plugin config has project-specific rules: The setup template is hardcoded in the skill, not read from the plugin's own config.yaml. Even if the plugin maintainer adds project-specific rules to their config, consumer projects get a clean template.

## Assumptions

No assumptions made.
