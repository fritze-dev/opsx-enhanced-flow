## Purpose

Handles one-time project initialization via `/opsx:init`, including OpenSpec CLI installation, schema setup, config creation, and post-setup validation.

## Requirements

### Requirement: Install OpenSpec and Schema
The system SHALL provide `/opsx:init` as the single entry point for project setup. The init command SHALL install the OpenSpec CLI globally via npm, register the `opsx-enhanced` schema via `openspec schema init`, copy the plugin's custom schema files and templates into the project's `openspec/schemas/` directory, create the `openspec/config.yaml` with workflow rules, and create a constitution placeholder if none exists. The init command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps and report what was already in place.

The init skill SHALL set `disable-model-invocation: false` in its frontmatter so that it is discoverable and invocable via `/opsx:init`.

The init command SHALL NOT run `openspec init --tools claude` because that creates built-in OpenSpec skills (e.g. `openspec-apply-change`) in `.claude/skills/` that duplicate and conflict with the plugin's own `/opsx:*` skills. Schema initialization SHALL use `openspec schema init` directly, which works independently without prior `openspec init`.

The init command SHALL ensure target directories exist (via `mkdir -p`) before copying files from the plugin.

**User Story:** As a new user I want a single `/opsx:init` command that sets up everything, so that I do not have to manually install dependencies or configure the project.

#### Scenario: First-time project initialization
- **GIVEN** a project directory without OpenSpec or the opsx-enhanced plugin installed
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL install the OpenSpec CLI globally, register the schema via `openspec schema init`, copy custom schema files from the plugin, create config.yaml, create a constitution placeholder, and validate the setup

#### Scenario: Idempotent re-initialization
- **GIVEN** a project that has already been initialized with `/opsx:init`
- **WHEN** the user runs `/opsx:init` again
- **THEN** the system SHALL skip already-completed steps, preserve existing constitution.md, and report which components were already in place

#### Scenario: No duplicate skill creation
- **GIVEN** a project where the opsx plugin is already installed
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL NOT create any `.claude/skills/openspec-*` skill files that would duplicate the plugin's `/opsx:*` skills

### Requirement: OpenSpec CLI Prerequisite Check
The init command SHALL check whether the OpenSpec CLI (`@fission-ai/openspec`) is installed globally. If the CLI is not found, the init command SHALL auto-install it via `npm install -g @fission-ai/openspec`. The installed version SHALL be compatible with `^1.2.0`. If npm is not available, the init command SHALL report a clear error instructing the user to install Node.js and npm first.

**User Story:** As a user I want the init command to handle CLI installation automatically, so that I do not need to know which npm package to install or which version is required.

#### Scenario: CLI not installed, npm available
- **GIVEN** the OpenSpec CLI is not installed globally and npm is available
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL run `npm install -g @fission-ai/openspec` and verify the installed version is compatible with `^1.2.0`

#### Scenario: CLI already installed with compatible version
- **GIVEN** the OpenSpec CLI is already installed at version 1.2.3
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL skip CLI installation and report the existing version

#### Scenario: npm not available
- **GIVEN** neither Node.js nor npm is installed on the system
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL report a clear error message stating that Node.js and npm are prerequisites and provide installation guidance

#### Scenario: CLI installed but incompatible version
- **GIVEN** the OpenSpec CLI is installed at version 0.9.0 (below ^1.2.0)
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL upgrade the CLI to a compatible version via npm and report the version change

### Requirement: Schema Validation
The init command SHALL validate the project setup after all installation steps complete. Validation SHALL confirm that the OpenSpec CLI is accessible and at a compatible version, the schema directory exists and contains a valid `schema.yaml`, and the `config.yaml` is present with required workflow rules. The init command SHALL report a summary of validation results to the user.

**User Story:** As a user I want init to verify everything works after setup, so that I can trust the environment is ready for spec-driven development.

#### Scenario: Successful validation after fresh init
- **GIVEN** the init command has completed all installation steps
- **WHEN** the validation phase runs
- **THEN** the system SHALL verify CLI accessibility, schema validity, and config presence, and report all checks as passing

#### Scenario: Validation detects partial setup failure
- **GIVEN** the init command completed but the schema copy failed silently
- **WHEN** the validation phase runs
- **THEN** the system SHALL detect the missing schema and report which specific validation check failed

## Edge Cases

- If the user does not have write permissions to the global npm prefix, the auto-install SHALL fail with a clear error suggesting `sudo` or an npm prefix configuration change.
- If the project directory is read-only, init SHALL fail before making any changes and report the permission issue.
- If network connectivity is unavailable during npm install, the system SHALL report a network error with a suggestion to retry.

## Assumptions

<!-- ASSUMPTION: npm global install (`npm install -g`) is the correct installation method for the OpenSpec CLI. This assumes the user's Node.js environment supports global installs. -->
<!-- ASSUMPTION: The `^1.2.0` version constraint is enforced via npm semver, meaning any version >= 1.2.0 and < 2.0.0 is acceptable. -->
<!-- ASSUMPTION: `openspec schema init` works independently without prior `openspec init`. Verified by testing in a clean directory. -->
No further assumptions beyond those marked above.
