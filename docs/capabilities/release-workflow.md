---
title: "Release Workflow"
capability: "release-workflow"
description: "Version management, changelog generation, and consumer update process."
lastUpdated: "2026-03-05"
---
# Release Workflow

The release workflow handles version management for the plugin, including automatic patch bumps on archive, version synchronization, changelog generation via `/opsx:changelog`, and documented processes for manual releases and consumer updates.

## Purpose

Without an automated release workflow, version bumps are a manual step that is regularly forgotten, causing consumers to miss updates even after changes are pushed. Additionally, version fields across plugin files can drift out of sync, and there is no structured process for generating changelogs or guiding consumers through updates.

## Rationale

The auto-bump is implemented as a constitution convention rather than a skill modification, respecting the principle that skills are shared plugin code and must not contain project-specific behavior. Patch bumps cover the vast majority of changes; minor and major releases are rare enough that a documented manual process suffices. The changelog command reads `openspec/config.yaml` for a `docs_language` setting, allowing teams to generate release notes in their preferred language while keeping dates in ISO format and product names in English.

## Features

- **Automatic patch version bump** — the patch version increments automatically after each successful archive
- **Version synchronization** — `plugin.json` and `marketplace.json` stay in sync automatically
- **Manual minor/major releases** — documented process for intentional version changes with git tags
- **Consumer update guidance** — clear steps for consumers to get the latest plugin version
- **Changelog generation** — `/opsx:changelog` produces release notes from archived changes in Keep a Changelog format
- **Language-aware changelog** — changelog entries can be generated in the language configured in `docs_language`
- **Post-archive next steps** — archive output includes guidance for the complete post-archive workflow

## Behavior

### Automatic Patch Bump After Archive

After a successful `/opsx:archive`, the patch version in `.claude-plugin/plugin.json` is incremented automatically (for example, `1.0.3` becomes `1.0.4`). The new version is displayed in the archive summary.

### Version Synchronization

The `version` field in `marketplace.json` always matches `plugin.json`. Both files are updated together during the auto-bump. If they are found out of sync beforehand, they are aligned to the `plugin.json` version first, then the patch bump is applied.

### Manual Minor and Major Releases

For intentional minor or major version changes, you manually set the version in both `plugin.json` and `marketplace.json`, create a git tag in the format `v<version>`, push the tag, and optionally create a GitHub Release via `gh release create`.

### Optional GitHub Release

After creating and pushing a version tag, you can run `gh release create v<version>` with changelog content. Consumers can reference the release by tag.

### Consumer Update Process

When a new plugin version is available, consumers run `claude plugin marketplace update opsx-enhanced-flow` to refresh the listing, then `claude plugin update opsx@opsx-enhanced-flow` to install the update, and restart Claude Code to load the new version.

### Update Not Detected

If `claude plugin update` does not detect a new version, first refresh the marketplace listing with `claude plugin marketplace update opsx-enhanced-flow` and retry. As a last resort, uninstall and reinstall the plugin.

### Skill Immutability

Skills in `skills/` are generic plugin code shared across all consumers and are not modified for project-specific behavior. Project-specific workflows and conventions are defined in the constitution.

### Project-Specific Behavior in Constitution

When project-specific post-archive behavior is needed (such as version bumps), it is defined as a convention in `openspec/constitution.md`, not added as a step in the skill file.

### End-to-End Install Flow

The complete install path is: `claude plugin marketplace add` followed by `claude plugin install` followed by `/opsx:init` followed by `/opsx:bootstrap`.

### End-to-End Update Flow

The complete update path is: `claude plugin marketplace update` followed by `claude plugin update`. Running `/opsx:init` again is safe (idempotent) and ensures schema updates are picked up.

### Post-Push Developer Plugin Update

After pushing a version bump to the remote, the developer updates their local plugin installation by running `claude plugin marketplace update` and `claude plugin update` to stay on the latest version during development.

### Archive Output Next Steps

After a successful archive with auto-bump, the output includes next steps: run `/opsx:changelog`, push, and update the local plugin.

### Changelog from Single Archive

Running `/opsx:changelog` reads each archived change directory, examines the proposal, delta specs, and design artifacts, and produces changelog entries summarizing what changed from a user perspective. Entries use the Keep a Changelog format with sections like Added, Changed, and Fixed as applicable.

### Multiple Archives Ordered Newest First

When multiple archives exist, changelog entries are ordered with the newest first.

### Existing Changelog Preserved

If `CHANGELOG.md` already contains manually written entries, new entries are added at the top without modifying or removing existing content.

### No Archives to Process

If the archive directory is empty or does not exist, `/opsx:changelog` informs you that no archived changes were found.

### Internal-Only Changes

If an archived change describes purely internal refactoring with no user-visible impact, it is either omitted or included under a minimal note rather than fabricating user-facing changes.

### Changelog in Configured Language

When `openspec/config.yaml` contains a `docs_language` setting (for example, `German`), `/opsx:changelog` generates section headers and entry descriptions in that language. Dates remain in ISO format and product names stay in English.

### Default Language

When the `docs_language` field is missing or set to `English`, changelog entries are generated in English.

### Language Change Mid-Project

If the documentation language is changed after entries have already been generated, existing entries are preserved in their original language and new entries use the new language.

## Known Limitations

- Does not support automatic minor or major version bumps — these require a manual process.
- Does not create git tags automatically — tagging is part of the manual minor/major release process.
- No CI/CD automation or git hooks — the workflow relies on constitution conventions followed by the agent.

## Future Enhancements

- A dedicated `/opsx:release` skill for automated minor/major releases.
- A `/opsx:status` skill for checking the current project and plugin state.

## Edge Cases

- If `.claude-plugin/plugin.json` does not exist (consumer projects without plugin manifests), the version bump step is silently skipped.
- If the version field contains a non-semver value, the system warns and skips the bump rather than producing an invalid version.
- If the archive directory contains changes with only internal refactoring, the changelog agent either omits the entry or uses a minimal note to avoid fabricating user-facing changes.
