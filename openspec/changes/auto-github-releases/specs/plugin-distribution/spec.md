---
order: 13
category: finalization
---

## ADDED Requirements

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

- **Consumer adds marketplace before restructuring**: Old cache with flat structure remains until `claude plugin update` fetches the new `src/` layout. No migration needed — the new cache replaces the old one.
- **Plugin.json at both root and src**: marketplace.json at root does NOT have a plugin.json sibling (only marketplace.json). The plugin.json lives exclusively in `src/.claude-plugin/`.
- **Empty src directory**: If `src/` is missing or empty, plugin installation SHALL fail with a clear error.

## Assumptions

- Claude Code resolves relative paths in marketplace.json `source` field relative to the repository root. <!-- ASSUMPTION: relative path resolution -->
- Claude Code caches only the referenced subdirectory, not the full repository clone. <!-- ASSUMPTION: subdirectory caching -->
- `CLAUDE_PLUGIN_ROOT` resolves to the plugin's cached directory (i.e., the `src/` contents). <!-- ASSUMPTION: plugin root resolution -->
