## Purpose

Define the release workflow conventions for the plugin, including automatic patch version bumps on archive, version synchronization between plugin files, manual minor/major release processes, consumer update guidance, skill immutability rules, and end-to-end install/update checklists.

## Requirements

### Requirement: Post-Archive Auto Patch Bump Convention

The project constitution SHALL define a convention that instructs `/opsx:archive` to automatically increment the patch version in `.claude-plugin/plugin.json` after a successful archive. The convention SHALL also require syncing the `version` field in `.claude-plugin/marketplace.json` to match. The archive output SHALL display the new version.

**User Story:** As a plugin maintainer I want the patch version to auto-increment on archive, so that consumers can detect updates without manual version bumps.

#### Scenario: Successful auto-bump after archive

- **GIVEN** a plugin project with `.claude-plugin/plugin.json` containing version `1.0.3`
- **AND** `.claude-plugin/marketplace.json` containing version `1.0.3`
- **AND** the constitution defines the post-archive auto-bump convention
- **WHEN** the user archives a completed change via `/opsx:archive`
- **THEN** the system SHALL increment the patch version to `1.0.4` in `plugin.json`
- **AND** SHALL update `marketplace.json` to version `1.0.4`
- **AND** SHALL display the new version in the archive summary

### Requirement: Version Sync Between Plugin Files

The `version` field in `.claude-plugin/marketplace.json` MUST always match the `version` field in `.claude-plugin/plugin.json`. The auto-bump convention SHALL update both files together. If they are found out of sync before bumping, the system SHALL sync them to the plugin.json version first, then apply the patch bump.

#### Scenario: Files already in sync

- **GIVEN** `plugin.json` version is `1.0.3` and `marketplace.json` version is `1.0.3`
- **WHEN** the auto-bump runs
- **THEN** both files SHALL be updated to `1.0.4`

#### Scenario: Files out of sync

- **GIVEN** `plugin.json` version is `1.0.3` and `marketplace.json` version is `1.0.0`
- **WHEN** the auto-bump runs
- **THEN** both files SHALL be bumped to `1.0.4` (based on plugin.json as source of truth)

### Requirement: Manual Minor and Major Release Process

For intentional minor or major version changes, the maintainer SHALL manually set the version in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, create a git tag in the format `v<version>`, push the tag, and optionally create a GitHub Release via `gh release create`. This process is documented, not automated.

**User Story:** As a maintainer I want a clear process for minor/major releases, so that I can publish breaking or feature-level changes with proper git tags.

#### Scenario: Manual minor release

- **GIVEN** a maintainer decides a set of changes warrants a minor version bump
- **WHEN** the maintainer follows the documented manual release process
- **THEN** the maintainer SHALL update `plugin.json` and `marketplace.json` to the new minor version (e.g., `1.1.0`)
- **AND** SHALL create a git tag `v1.1.0`
- **AND** SHALL push the tag via `git push --tags`

#### Scenario: Optional GitHub Release

- **GIVEN** a maintainer has created and pushed a version tag
- **WHEN** the maintainer wants to publish a GitHub Release
- **THEN** the maintainer SHALL run `gh release create v<version>` with changelog content
- **AND** consumers SHALL be able to reference the release by tag

### Requirement: Consumer Update Process

The project documentation SHALL describe the complete consumer update process: refresh the marketplace listing, update the plugin, and restart Claude Code. This process SHALL be documented in the spec so that `/opsx:docs` can generate user-facing documentation from it.

**User Story:** As a consumer of the plugin I want to know exactly how to update, so that I always have the latest version.

#### Scenario: Consumer updates to latest version

- **GIVEN** a new plugin version has been pushed by the maintainer
- **WHEN** a consumer wants to update
- **THEN** the consumer SHALL run `claude plugin marketplace update opsx-enhanced-flow`
- **AND** SHALL run `claude plugin update opsx@opsx-enhanced-flow`
- **AND** SHALL restart Claude Code to load the new version

#### Scenario: Update not detected

- **GIVEN** a consumer runs `claude plugin update` but no new version is detected
- **WHEN** the consumer investigates
- **THEN** the consumer SHALL first run `claude plugin marketplace update opsx-enhanced-flow` to refresh the listing
- **AND** SHALL retry the update
- **AND** if still not detected, SHALL uninstall and reinstall the plugin as fallback

### Requirement: Skill Immutability Convention

The constitution SHALL define a rule that skills in `skills/` are generic plugin code shared across all consumers and MUST NOT be modified for project-specific behavior. Project-specific workflows and conventions MUST be defined in the constitution.

#### Scenario: Project-specific behavior defined in constitution

- **GIVEN** a need for project-specific post-archive behavior (e.g., version bumps)
- **WHEN** a developer plans the implementation
- **THEN** the behavior SHALL be defined as a convention in `openspec/constitution.md`
- **AND** SHALL NOT be added as a step in the skill file

### Requirement: End-to-End Install and Update Checklist

The project spec SHALL document the complete happy path for plugin installation and updates as testable scenarios: marketplace add -> install -> init -> bootstrap, and marketplace update -> plugin update -> verify. This ensures the full flow is exercised and regressions are caught.

**User Story:** As a maintainer I want a testable checklist for the full install/update flow, so that I can verify the entire pipeline works end-to-end.

#### Scenario: Clean install flow

- **GIVEN** a clean project without the plugin installed
- **WHEN** the maintainer tests the install flow
- **THEN** `claude plugin marketplace add fritze-dev/opsx-enhanced-flow` SHALL succeed
- **AND** `claude plugin install opsx@opsx-enhanced-flow` SHALL succeed
- **AND** `/opsx:init` SHALL install the schema and create config files
- **AND** `/opsx:bootstrap` SHALL generate constitution and initial specs

#### Scenario: Update flow after new version

- **GIVEN** a project with the plugin installed at version N
- **AND** a new version N+1 has been pushed
- **WHEN** the maintainer tests the update flow
- **THEN** `claude plugin marketplace update opsx-enhanced-flow` SHALL refresh the listing
- **AND** `claude plugin update opsx@opsx-enhanced-flow` SHALL detect and install version N+1
- **AND** `/opsx:init` SHALL run idempotently without errors

### Requirement: Post-Push Developer Plugin Update

After pushing a version bump to the remote, the developer's local plugin installation SHALL be updated to match the new version. The constitution convention SHALL include this as a next step after push, ensuring the developer always runs the latest plugin version during development.

**User Story:** As a plugin developer I want my local plugin to auto-update after I push a new version, so that I'm always developing against the latest version.

#### Scenario: Developer updates local plugin after push

- **GIVEN** a version bump has been applied (via archive auto-bump or manual)
- **AND** the changes have been pushed to remote
- **WHEN** the developer follows the post-archive next steps
- **THEN** the developer SHALL run `claude plugin marketplace update opsx-enhanced-flow`
- **AND** SHALL run `claude plugin update opsx@opsx-enhanced-flow`
- **AND** the local plugin installation SHALL reflect the new version

### Requirement: Archive Output Includes Next Steps

The archive summary output SHALL include a "Next steps" section guiding the user through the complete post-archive workflow: generate changelog, push, and update the local plugin. This is defined via the constitution convention.

#### Scenario: Next steps shown after archive

- **GIVEN** a successful archive with auto-bump
- **WHEN** the archive summary is displayed
- **THEN** the output SHALL include next steps: `/opsx:changelog` → push → update plugin
