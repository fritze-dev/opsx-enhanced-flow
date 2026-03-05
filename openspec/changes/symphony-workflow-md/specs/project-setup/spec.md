## MODIFIED Requirements

### Requirement: Install OpenSpec and Schema
The system SHALL provide `/opsx:init` as the single entry point for project setup. The init command SHALL install the OpenSpec CLI globally via npm, register the `opsx-enhanced` schema via `openspec schema init`, copy the plugin's custom schema files and templates into the project's `openspec/schemas/` directory, create `WORKFLOW.md` at the project root (YAML front matter with schema reference, project name placeholder, and `docs_language` field + markdown body with constitution placeholder), and create the legacy `openspec/config.yaml` only if `WORKFLOW.md` creation is not possible. The init command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps and report what was already in place.

The init skill SHALL set `disable-model-invocation: false` in its frontmatter so that it is discoverable and invocable via `/opsx:init`.

The init command SHALL NOT run `openspec init --tools claude` because that creates built-in OpenSpec skills (e.g. `openspec-apply-change`) in `.claude/skills/` that duplicate and conflict with the plugin's own `/opsx:*` skills. Schema initialization SHALL use `openspec schema init` directly, which works independently without prior `openspec init`.

The init command SHALL ensure target directories exist (via `mkdir -p`) before copying files from the plugin.

The init command SHALL generate `WORKFLOW.md` from a template rather than copying the plugin's own files. This prevents project-specific rules from leaking into consumer projects. The generated `WORKFLOW.md` SHALL include a commented YAML field for `docs_language: English` for discoverability. The markdown body SHALL include an English-enforcement rule stating that all workflow artifacts (research, proposal, specs, design, preflight, tasks) must be written in English.

**User Story:** As a new user I want a single `/opsx:init` command that sets up everything including `WORKFLOW.md`, so that I do not have to manually install dependencies or configure the project.

#### Scenario: First-time project initialization generates WORKFLOW.md
- **GIVEN** a project directory without OpenSpec or the opsx-enhanced plugin installed
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL install the OpenSpec CLI globally, register the schema via `openspec schema init`, copy custom schema files from the plugin, create `WORKFLOW.md` at the project root, and validate the setup
- **AND** `WORKFLOW.md` SHALL contain YAML front matter with `schema: opsx-enhanced` and a markdown body with project rules placeholder

#### Scenario: Idempotent re-initialization preserves WORKFLOW.md
- **GIVEN** a project that has already been initialized with `/opsx:init` and has an existing `WORKFLOW.md`
- **WHEN** the user runs `/opsx:init` again
- **THEN** the system SHALL skip already-completed steps, preserve existing `WORKFLOW.md` without overwriting, and report which components were already in place

#### Scenario: No duplicate skill creation
- **GIVEN** a project where the opsx plugin is already installed
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL NOT create any `.claude/skills/openspec-*` skill files that would duplicate the plugin's `/opsx:*` skills

#### Scenario: WORKFLOW.md generated from template, not copied
- **GIVEN** a project directory without `WORKFLOW.md`
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL create `WORKFLOW.md` containing a `schema` reference in front matter, a commented-out `docs_language` field, and a markdown body with an English-enforcement rule for workflow artifacts
- **AND** the `WORKFLOW.md` SHALL NOT contain workflow rules or per-artifact rules copied from the plugin's own files

#### Scenario: Existing WORKFLOW.md preserved
- **GIVEN** a project that already has `WORKFLOW.md` at the root
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL preserve the existing `WORKFLOW.md` unchanged

#### Scenario: Legacy project without WORKFLOW.md migrated
- **GIVEN** a project that was initialized before the WORKFLOW.md feature (has `openspec/config.yaml` and `openspec/constitution.md` but no `WORKFLOW.md`)
- **WHEN** the user runs `/opsx:init`
- **THEN** the system SHALL detect the legacy setup, generate `WORKFLOW.md` merging existing config and constitution content, and inform the user that `openspec/config.yaml` and `openspec/constitution.md` are now superseded by `WORKFLOW.md`
- **AND** the legacy files SHALL be retained (not deleted) to allow the user to verify the migration

#### Scenario: WORKFLOW.md includes docs_language for discoverability
- **GIVEN** a project directory without `WORKFLOW.md`
- **WHEN** the user runs `/opsx:init`
- **THEN** the generated `WORKFLOW.md` front matter SHALL include `# docs_language: English` as a commented-out field
- **AND** the markdown body SHALL include a rule enforcing English for all workflow artifacts
