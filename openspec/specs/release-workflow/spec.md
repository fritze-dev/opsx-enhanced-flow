---
order: 12
category: finalization
---
## Purpose

Define the release workflow conventions for the plugin, including automatic patch version bumps, version synchronization between plugin files, manual minor/major release processes, consumer update guidance, skill immutability rules, end-to-end install/update checklists, and changelog generation from completed changes.

## Requirements

### Requirement: Auto Patch Version Bump

The project constitution SHALL define a convention that instructs the post-apply workflow to automatically increment the patch version in `src/.claude-plugin/plugin.json` after a successful change completion. The convention SHALL also require syncing the `version` field in `.claude-plugin/marketplace.json` to match. The output SHALL display the new version.

**User Story:** As a plugin maintainer I want the patch version to auto-increment when a change is completed, so that consumers can detect updates without manual version bumps.

#### Scenario: Successful auto-bump after change completion

- **GIVEN** a plugin project with `src/.claude-plugin/plugin.json` containing version `1.0.3`
- **AND** `.claude-plugin/marketplace.json` containing version `1.0.3`
- **AND** the constitution defines the post-completion auto-bump convention
- **WHEN** the post-apply workflow runs for a completed change
- **THEN** the system SHALL increment the patch version to `1.0.4` in `plugin.json`
- **AND** SHALL update `marketplace.json` to version `1.0.4`
- **AND** SHALL display the new version

### Requirement: Version Sync Between Plugin Files

The `version` field in `.claude-plugin/marketplace.json` MUST always match the `version` field in `src/.claude-plugin/plugin.json`. The auto-bump convention SHALL update both files together. If they are found out of sync before bumping, the system SHALL sync them to the plugin.json version first, then apply the patch bump.

#### Scenario: Files already in sync

- **GIVEN** `plugin.json` version is `1.0.3` and `marketplace.json` version is `1.0.3`
- **WHEN** the auto-bump runs
- **THEN** both files SHALL be updated to `1.0.4`

#### Scenario: Files out of sync

- **GIVEN** `plugin.json` version is `1.0.3` and `marketplace.json` version is `1.0.0`
- **WHEN** the auto-bump runs
- **THEN** both files SHALL be bumped to `1.0.4` (based on plugin.json as source of truth)

### Requirement: Manual Minor and Major Release Process

For intentional minor or major version changes, the maintainer SHALL manually set the version in both `src/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, then push to `main`. The GitHub Actions release workflow SHALL automatically create the git tag and GitHub Release from the pushed version change. For cases where a tag and release are needed without a code change (e.g., retroactive tagging), the maintainer MAY manually create a git tag in the format `v<version>`, push the tag, and create a GitHub Release via `gh release create`.

**User Story:** As a maintainer I want a clear process for minor/major releases, so that I can publish breaking or feature-level changes with proper git tags.

#### Scenario: Manual minor release via push

- **GIVEN** a maintainer decides a set of changes warrants a minor version bump
- **WHEN** the maintainer updates `src/.claude-plugin/plugin.json` and `marketplace.json` to `1.1.0` and pushes to `main`
- **THEN** the GitHub Actions release workflow SHALL create tag `v1.1.0` and a corresponding GitHub Release

#### Scenario: Retroactive manual tagging

- **GIVEN** a maintainer needs to tag an existing commit without a version change push
- **WHEN** the maintainer manually creates and pushes a git tag `v1.1.0`
- **THEN** the maintainer MAY create a GitHub Release via `gh release create v1.1.0`

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

- **GIVEN** a need for project-specific post-completion behavior (e.g., version bumps)
- **WHEN** a developer plans the implementation
- **THEN** the behavior SHALL be defined as a convention in `openspec/CONSTITUTION.md`
- **AND** SHALL NOT be added as a step in the skill file

### Requirement: End-to-End Install and Update Checklist

The project spec SHALL document the complete happy path for plugin installation and updates as testable scenarios: marketplace add -> install -> init -> bootstrap, and marketplace update -> plugin update -> verify. This ensures the full flow is exercised and regressions are caught.

**User Story:** As a maintainer I want a testable checklist for the full install/update flow, so that I can verify the entire pipeline works end-to-end.

#### Scenario: Clean install flow

- **GIVEN** a clean project without the plugin installed
- **WHEN** the maintainer tests the install flow
- **THEN** `claude plugin marketplace add fritze-dev/opsx-enhanced-flow` SHALL succeed
- **AND** `claude plugin install opsx@opsx-enhanced-flow` SHALL succeed
- **AND** `/opsx:setup` SHALL install the schema and create config files
- **AND** `/opsx:bootstrap` SHALL generate constitution and initial specs

#### Scenario: Update flow after new version

- **GIVEN** a project with the plugin installed at version N
- **AND** a new version N+1 has been pushed
- **WHEN** the maintainer tests the update flow
- **THEN** `claude plugin marketplace update opsx-enhanced-flow` SHALL refresh the listing
- **AND** `claude plugin update opsx@opsx-enhanced-flow` SHALL detect and install version N+1
- **AND** `/opsx:setup` SHALL run idempotently without errors

### Requirement: Post-Push Developer Plugin Update

After pushing a version bump to the remote, the developer's local plugin installation SHALL be updated to match the new version. For developers using the local marketplace (directory-based source), running `claude plugin update opsx@opsx-enhanced-flow` SHALL detect the local version change and update the cached plugin. For developers using the GitHub marketplace, the existing marketplace update + plugin update flow applies.

**User Story:** As a plugin developer I want my local plugin to update after I push a new version, so that I'm always developing against the latest version.

#### Scenario: Developer with local marketplace updates after version bump

- **GIVEN** a version bump has been applied locally (via auto-bump or manual)
- **WHEN** the developer runs `claude plugin update opsx@opsx-enhanced-flow`
- **THEN** the local plugin installation SHALL reflect the new version

#### Scenario: Developer with GitHub marketplace updates after push

- **GIVEN** a version bump has been pushed to remote
- **WHEN** the developer runs `claude plugin marketplace update opsx-enhanced-flow`
- **AND** runs `claude plugin update opsx@opsx-enhanced-flow`
- **THEN** the local plugin installation SHALL reflect the new version

### Requirement: Completion Workflow Next Steps

The post-apply workflow output SHALL include a "Next steps" section guiding the user through the complete post-completion workflow: generate changelog, generate docs, version bump, push, and update the local plugin. This is defined via the constitution convention.

#### Scenario: Next steps shown after verification

- **GIVEN** a successful verification of a completed change
- **WHEN** the verification summary is displayed
- **THEN** the output SHALL include next steps: `/opsx:changelog` → `/opsx:docs` → version bump → push → update plugin

### Requirement: Generate Changelog from Completed Changes
The `/opsx:changelog` command SHALL generate release notes from completed changes located in `openspec/changes/`. The agent SHALL scan all change directories (named `YYYY-MM-DD-<feature>`) and identify completed changes (all tasks checked). For each completed change not yet in the changelog, the agent SHALL read `proposal.md` from the change directory for motivation and capabilities, and read the current specs at `openspec/specs/<capability>/spec.md` for user stories and scenario titles of the affected capabilities. The generated changelog SHALL follow the Keep a Changelog format with sections for Added, Changed, Deprecated, Removed, Fixed, and Security as applicable. Entries SHALL be ordered newest first. The changelog SHALL be written to `CHANGELOG.md` in the project root. If `CHANGELOG.md` already exists, the agent SHALL update it by adding new entries for changes not yet represented, preserving existing manually written entries.

**User Story:** As a user of the project I want a changelog that tells me what changed and when, so that I can understand the impact of updates without reading spec files or commit logs.

#### Scenario: Changelog generated from single completed change
- **GIVEN** a completed change at `openspec/changes/2025-01-15-user-auth/` containing a proposal describing a new authentication feature
- **AND** the proposal lists capability `user-auth` as new
- **AND** `openspec/specs/user-auth/spec.md` contains user stories and scenarios
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent creates or updates `CHANGELOG.md` with an entry dated 2025-01-15 describing the new authentication feature using user stories from the spec

#### Scenario: Multiple completed changes ordered newest first
- **GIVEN** three completed changes dated 2025-01-10, 2025-02-05, and 2025-03-20
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the changelog lists the 2025-03-20 entry first, followed by 2025-02-05, then 2025-01-10

#### Scenario: Existing changelog preserved
- **GIVEN** a `CHANGELOG.md` that already contains manually written entries for versions 1.0 and 1.1
- **AND** a new completed change that has not been represented in the changelog
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent adds the new entry at the top of the changelog without modifying or removing the existing 1.0 and 1.1 entries

#### Scenario: No completed changes to process
- **GIVEN** no completed changes exist under `openspec/changes/`
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent informs the user that no completed changes were found and no changelog entries were generated

#### Scenario: Change with only internal refactoring
- **GIVEN** a completed change whose proposal and specs describe purely internal refactoring with no user-visible changes
- **WHEN** the agent processes the change
- **THEN** the agent either omits the entry entirely or includes it under a minimal note (e.g., "Internal improvements") rather than fabricating user-facing changes

### Requirement: Language-Aware Changelog Generation
The `/opsx:changelog` command SHALL determine the documentation language before generating entries. The agent SHALL read `openspec/WORKFLOW.md` and extract the `docs_language` field. If the field is missing or set to "English", the agent SHALL generate changelog entries in English (default behavior). If a non-English language is configured, the agent SHALL translate section headers (e.g., `### Added` → `### Hinzugefügt` for German) and entry descriptions to the target language. Dates SHALL remain in ISO format (`YYYY-MM-DD`). Product names (OpenSpec, Claude Code), commands (`/opsx:*`), and file paths SHALL remain in English.

**User Story:** As a non-English-speaking team I want changelog entries in my language, so that release notes are immediately understandable.

#### Scenario: Changelog generated in configured language
- **GIVEN** `openspec/WORKFLOW.md` contains `docs_language: German`
- **AND** a new completed change exists that is not yet in the changelog
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the new entry SHALL have German section headers (e.g., `### Hinzugefügt`, `### Geändert`, `### Behoben`)
- **AND** entry descriptions SHALL be in German
- **AND** dates SHALL remain in ISO format

#### Scenario: Default to English when field is missing
- **GIVEN** `openspec/WORKFLOW.md` does not contain a `docs_language` field
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** all entries SHALL be generated in English (unchanged behavior)

#### Scenario: Existing entries preserved in previous language
- **GIVEN** existing changelog entries were generated in English
- **AND** `docs_language` has been changed to "French"
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** existing English entries SHALL be preserved unchanged
- **AND** new entries SHALL be generated in French

### Requirement: Automated GitHub Release via CI

A GitHub Actions workflow SHALL automatically create a git tag and GitHub Release when the version in `src/.claude-plugin/plugin.json` changes on the `main` branch. The workflow SHALL extract the latest changelog entry from `CHANGELOG.md` and use it as the release body. The workflow SHALL be idempotent — if the tag already exists, it SHALL skip without error.

**User Story:** As a plugin maintainer I want GitHub Releases to be created automatically after pushing a version bump, so that releases stay in sync with changelog entries without manual steps.

#### Scenario: Release created after version bump push

- **GIVEN** a push to `main` that changes `src/.claude-plugin/plugin.json` version from `1.0.28` to `1.0.29`
- **AND** `CHANGELOG.md` contains an entry starting with `## 2026-03-26 — Feature Name`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create a git tag `v1.0.29`
- **AND** SHALL create a GitHub Release titled `v1.0.29`
- **AND** SHALL use the latest CHANGELOG.md entry as the release body

#### Scenario: Tag already exists

- **GIVEN** a push to `main` with version `1.0.29` in `src/.claude-plugin/plugin.json`
- **AND** a git tag `v1.0.29` already exists
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL skip tag and release creation
- **AND** SHALL exit successfully (no error)

#### Scenario: No version change

- **GIVEN** a push to `main` that does not modify `src/.claude-plugin/plugin.json`
- **WHEN** the push is processed
- **THEN** the release workflow SHALL NOT trigger

#### Scenario: First release ever

- **GIVEN** a repository with no existing git tags
- **AND** a push to `main` with version `1.0.29` in `src/.claude-plugin/plugin.json`
- **WHEN** the GitHub Actions workflow triggers
- **THEN** the workflow SHALL create tag `v1.0.29` and a corresponding GitHub Release

### Requirement: Consumer Version Pinning

The project documentation SHALL describe how consumers can pin to a specific plugin version by specifying a git tag reference when adding the marketplace. The pinning mechanism uses the `#ref` suffix on the marketplace add command, which is a built-in feature of the Claude Code plugin system.

**User Story:** As a plugin consumer I want to pin my installation to a specific version, so that unexpected updates don't break my workflow.

#### Scenario: Consumer pins to specific version

- **GIVEN** a GitHub Release `v1.0.29` exists with a corresponding git tag
- **WHEN** a consumer runs `claude plugin marketplace add fritze-dev/opsx-enhanced-flow#v1.0.29`
- **THEN** the marketplace SHALL resolve to the commit tagged `v1.0.29`
- **AND** the installed plugin SHALL be version `1.0.29`

#### Scenario: Consumer on pinned version does not receive updates

- **GIVEN** a consumer installed the marketplace with `#v1.0.29`
- **AND** a new version `1.0.30` has been released
- **WHEN** the consumer runs `claude plugin marketplace update`
- **THEN** the marketplace SHALL remain at the `v1.0.29` tag
- **AND** the plugin version SHALL remain `1.0.29`

### Requirement: Developer Local Marketplace Workflow

The project documentation SHALL describe the local marketplace setup for plugin developers. Developers SHALL register the local repository path as a marketplace source using `claude plugin marketplace add <local-path>`. This enables the VS Code extension to load the development version of the plugin without requiring the CLI-only `--plugin-dir` flag.

**User Story:** As a plugin developer using VS Code I want to load my local plugin changes without CLI flags, so that I can iterate on skills and test them in any project.

#### Scenario: Developer registers local marketplace

- **GIVEN** a developer with the plugin source at `/home/user/projekte/opsx-enhanced-flow`
- **WHEN** the developer runs `claude plugin marketplace add /home/user/projekte/opsx-enhanced-flow --scope user`
- **AND** runs `claude plugin install opsx@opsx-enhanced-flow`
- **THEN** the installed plugin SHALL load from the local filesystem
- **AND** `claude plugin list` SHALL show the current local version

#### Scenario: Skill changes reload immediately

- **GIVEN** a developer with the local marketplace registered
- **AND** the developer modifies a SKILL.md file
- **WHEN** the developer runs `/reload-plugins`
- **THEN** the modified skill SHALL be active in the current session

#### Scenario: Version changes require explicit update

- **GIVEN** a developer with the local marketplace registered
- **AND** the developer changes the version in `src/.claude-plugin/plugin.json`
- **WHEN** the developer runs `/reload-plugins`
- **THEN** the old version SHALL still be reported by `claude plugin list`
- **AND** only after `claude plugin update opsx@opsx-enhanced-flow` SHALL the new version be active

### Requirement: Plugin Source Directory Structure

The plugin source code SHALL reside in a `src/` subdirectory at the repository root. The `src/` directory SHALL contain: `.claude-plugin/plugin.json` (plugin manifest), `skills/` (all skill definitions), and `templates/` (Smart Templates for consumer projects). Files not needed by consumers (documentation, CI workflows, OpenSpec project files, changelogs) SHALL remain at the repository root, outside `src/`.

**User Story:** As a plugin consumer I want to download only the files needed to run the plugin, so that my local cache is clean and minimal.

#### Scenario: Consumer cache contains only plugin files

- **GIVEN** a marketplace with `source: "./src"` pointing to the plugin subdirectory
- **WHEN** a consumer installs the plugin
- **THEN** the consumer's plugin cache SHALL contain only the contents of `src/` (skills, templates, plugin.json)
- **AND** SHALL NOT contain docs, CI workflows, changelogs, or OpenSpec project files

#### Scenario: Plugin root resolves to src directory

- **GIVEN** a plugin installed from a marketplace with `source: "./src"`
- **WHEN** a skill references `${CLAUDE_PLUGIN_ROOT}`
- **THEN** `CLAUDE_PLUGIN_ROOT` SHALL resolve to the `src/` directory
- **AND** `${CLAUDE_PLUGIN_ROOT}/templates/` SHALL contain the Smart Templates
- **AND** `${CLAUDE_PLUGIN_ROOT}/skills/` SHALL contain all skill definitions

### Requirement: Marketplace Source Configuration

The `.claude-plugin/marketplace.json` at the repository root SHALL use `source: "./src"` to reference the plugin subdirectory. This relative path SHALL resolve correctly for both local filesystem marketplaces (`claude plugin marketplace add <local-path>`) and GitHub-based marketplaces (`claude plugin marketplace add owner/repo`). The `plugin.json` manifest SHALL reside inside `src/.claude-plugin/plugin.json`, separate from the marketplace-level `.claude-plugin/marketplace.json` at the repo root.

**User Story:** As a plugin developer I want the marketplace to work with both local paths and GitHub, so that I can develop locally and distribute to consumers without config changes.

#### Scenario: Local marketplace resolves src directory

- **GIVEN** a developer registers the local repo as marketplace via `claude plugin marketplace add /path/to/repo`
- **WHEN** Claude Code reads `marketplace.json` with `source: "./src"`
- **THEN** the plugin SHALL load from `/path/to/repo/src/`
- **AND** the developer's local file changes SHALL be reflected after `claude plugin update`

#### Scenario: GitHub marketplace resolves src directory

- **GIVEN** a consumer adds the marketplace via `claude plugin marketplace add owner/repo`
- **WHEN** Claude Code clones the repository and reads `marketplace.json` with `source: "./src"`
- **THEN** the plugin SHALL load from the cloned repository's `src/` directory

#### Scenario: Version in src plugin.json drives update detection

- **GIVEN** a marketplace with `source: "./src"`
- **WHEN** the version in `src/.claude-plugin/plugin.json` changes
- **THEN** `claude plugin update` SHALL detect the new version
- **AND** SHALL update the cached plugin from `src/`

### Requirement: Repository Layout Separation

The repository SHALL maintain a clear separation between plugin source files (in `src/`) and project management files (at repo root). The repository root SHALL contain: `.claude-plugin/marketplace.json`, `openspec/` (project's own OpenSpec workflow), `docs/`, `.github/`, `.devcontainer/`, `CLAUDE.md`, `README.md`, and `CHANGELOG.md`. The `src/` directory SHALL NOT contain project-specific files such as CLAUDE.md, README.md, or OpenSpec project configuration.

#### Scenario: CLAUDE.md is project-level only

- **GIVEN** the repository with `src/` plugin subdirectory
- **WHEN** the file layout is inspected
- **THEN** `CLAUDE.md` SHALL exist at the repository root
- **AND** SHALL NOT exist inside `src/`

#### Scenario: OpenSpec project files separate from plugin

- **GIVEN** the repository with `src/` plugin subdirectory
- **WHEN** the file layout is inspected
- **THEN** `openspec/WORKFLOW.md`, `openspec/CONSTITUTION.md`, `openspec/specs/`, and `openspec/changes/` SHALL exist at the repository root
- **AND** SHALL NOT exist inside `src/`
