## MODIFIED Requirements

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

## Edge Cases

- If the user does not have write permissions to the global npm prefix, the auto-install SHALL fail with a clear error suggesting `sudo` or an npm prefix configuration change.
- If the project directory is read-only, init SHALL fail before making any changes and report the permission issue.
- If network connectivity is unavailable during npm install, the system SHALL report a network error with a suggestion to retry.

## Assumptions

<!-- ASSUMPTION: `openspec schema init` works independently without prior `openspec init`. Verified by testing in a clean directory. -->
No further assumptions beyond those marked above.
