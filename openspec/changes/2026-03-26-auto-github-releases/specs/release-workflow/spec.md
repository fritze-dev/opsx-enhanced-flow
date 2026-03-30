## ADDED Requirements

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

## MODIFIED Requirements

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

### Requirement: Post-Push Developer Plugin Update

After pushing a version bump to the remote, the developer's local plugin installation SHALL be updated to match the new version. For developers using the local marketplace (directory-based source), running `claude plugin update opsx@opsx-enhanced-flow` SHALL detect the local version change and update the cached plugin. For developers using the GitHub marketplace, the existing marketplace update + plugin update flow applies.

**User Story:** As a plugin developer I want my local plugin to update after I push a new version, so that I'm always developing against the latest version.

#### Scenario: Developer with local marketplace updates after version bump

- **GIVEN** a version bump has been applied locally (via archive auto-bump or manual)
- **WHEN** the developer runs `claude plugin update opsx@opsx-enhanced-flow`
- **THEN** the local plugin installation SHALL reflect the new version

#### Scenario: Developer with GitHub marketplace updates after push

- **GIVEN** a version bump has been pushed to remote
- **WHEN** the developer runs `claude plugin marketplace update opsx-enhanced-flow`
- **AND** runs `claude plugin update opsx@opsx-enhanced-flow`
- **THEN** the local plugin installation SHALL reflect the new version

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

## Edge Cases

- **CHANGELOG.md missing when Action runs**: The Action SHALL create the release with a minimal body (e.g., "Release v1.0.29") instead of failing.
- **Concurrent pushes with version changes**: The idempotent tag check prevents duplicate releases.
- **Version downgrade**: If `src/.claude-plugin/plugin.json` version is lower than the latest tag, the Action SHALL still create the tag (no version comparison logic — keep it simple).
- **Branch protection**: The Action needs `contents: write` permission to create tags. If branch protection prevents this, the Action SHALL fail with a clear error.
- **Consumer adds marketplace before restructuring**: Old cache with flat structure remains until `claude plugin update` fetches the new `src/` layout. No migration needed — the new cache replaces the old one.
- **Plugin.json at both root and src**: marketplace.json at root does NOT have a plugin.json sibling (only marketplace.json). The plugin.json lives exclusively in `src/.claude-plugin/`.

## Assumptions

- GitHub Actions has access to create tags and releases via the default `GITHUB_TOKEN`. <!-- ASSUMPTION: GITHUB_TOKEN permissions -->
- `jq` is available on `ubuntu-latest` runners for JSON parsing. <!-- ASSUMPTION: jq availability -->
- `CHANGELOG.md` follows the Keep a Changelog format with `## ` headings separating entries. <!-- ASSUMPTION: changelog format -->
- Claude Code resolves relative paths in marketplace.json `source` field relative to the repository root. <!-- ASSUMPTION: relative path resolution -->
- Claude Code caches only the referenced subdirectory, not the full repository clone. <!-- ASSUMPTION: subdirectory caching -->
- `CLAUDE_PLUGIN_ROOT` resolves to the plugin's cached directory (i.e., the `src/` contents). <!-- ASSUMPTION: plugin root resolution -->
