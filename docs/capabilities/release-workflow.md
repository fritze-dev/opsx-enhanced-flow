---
title: "Release Workflow"
capability: "release-workflow"
description: "Version management, automated releases, plugin distribution, changelog generation, and consumer update process."
lastUpdated: "2026-04-07"
---
# Release Workflow

The release workflow handles version management for the plugin, including automatic patch bumps during the post-apply workflow, automated GitHub Releases via CI, plugin source distribution from the `src/` subdirectory, consumer version pinning, developer local marketplace workflow, changelog generation via `/opsx:changelog`, and documented processes for manual releases and consumer updates.

## Purpose

Without an automated release workflow, version bumps are a manual step that is regularly forgotten, causing consumers to miss updates even after changes are pushed. Additionally, version fields across plugin files can drift out of sync, and there is no structured process for generating changelogs or guiding consumers through updates.

## Rationale

The auto-bump is implemented as a constitution convention rather than a skill modification, respecting the principle that skills are shared plugin code and must not contain project-specific behavior. Patch bumps cover the vast majority of changes; minor and major releases are rare enough that a documented manual process suffices. The changelog command reads `openspec/WORKFLOW.md` for a `docs_language` setting, allowing teams to generate release notes in their preferred language while keeping dates in ISO format and product names in English.

## Features

- **Automatic patch version bump** — the patch version increments automatically after each completed change during the post-apply workflow
- **Version synchronization** — `plugin.json` and `marketplace.json` stay in sync automatically
- **Automated GitHub Releases** — a GitHub Action creates git tags and releases automatically when a version bump is pushed to `main`
- **Plugin source separation** — plugin files live in `src/`, consumer caches contain only plugin files (no docs, CI, or project files)
- **Consumer version pinning** — consumers can pin to a specific version using a tag reference when adding the marketplace
- **Developer local marketplace** — developers register the local repo as marketplace source for live plugin development in VS Code and CLI
- **Manual minor/major releases** — documented process for intentional version changes; the Action handles tagging automatically
- **Consumer update guidance** — clear steps for consumers to get the latest plugin version
- **Changelog generation** — `/opsx:changelog` produces release notes from completed changes in Keep a Changelog format
- **Language-aware changelog** — changelog entries can be generated in the language configured in `docs_language`
- **Post-apply next steps** — apply output includes guidance for the complete post-apply workflow

## Behavior

### Automatic Patch Bump

During the post-apply workflow, the patch version in `src/.claude-plugin/plugin.json` is incremented automatically (for example, `1.0.3` becomes `1.0.4`). The `version` field in `.claude-plugin/marketplace.json` is synced to match. The new version is displayed in the summary.

### Automated GitHub Releases

When a version bump is pushed to `main`, a GitHub Action automatically creates a git tag (`v<version>`) and a GitHub Release. The release body contains the latest changelog entry from `CHANGELOG.md`. If the tag already exists, the Action skips silently (idempotent).

### Plugin Source Directory

Plugin source code (skills, templates, manifest) lives in the `src/` subdirectory. Consumer plugin caches contain only `src/` contents — documentation, CI workflows, OpenSpec project files, and changelogs are not downloaded. The marketplace uses `source: "./src"` to reference the plugin subdirectory.

### Consumer Version Pinning

Consumers can pin to a specific plugin version by adding the marketplace with a tag reference (for example, `claude plugin marketplace add fritze-dev/opsx-enhanced-flow#v1.0.30`). Pinned marketplaces do not receive updates when new versions are released.

### Developer Local Marketplace

Developers register the local repository path as a marketplace source for live plugin development. This works in both the VS Code extension and CLI, unlike `--plugin-dir` which is CLI-only. Skill changes reload instantly via `/reload-plugins`. Version changes require an explicit `claude plugin update`.

### Version Synchronization

The `version` field in `marketplace.json` always matches `src/.claude-plugin/plugin.json`. Both files are updated together during the auto-bump. If they are found out of sync beforehand, they are aligned to the `plugin.json` version first, then the patch bump is applied.

### Manual Minor and Major Releases

For intentional minor or major version changes, you manually set the version in both `src/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, then push to `main`. The GitHub Action automatically creates the git tag and release. For retroactive tagging without a version change, you can manually create and push a tag.

### Consumer Update Process

When a new plugin version is available, consumers run `claude plugin marketplace update opsx-enhanced-flow` to refresh the listing, then `claude plugin update opsx@opsx-enhanced-flow` to install the update, and restart Claude Code to load the new version.

### Update Not Detected

If `claude plugin update` does not detect a new version, first refresh the marketplace listing with `claude plugin marketplace update opsx-enhanced-flow` and retry. As a last resort, uninstall and reinstall the plugin.

### Skill Immutability

Skills in `skills/` are generic plugin code shared across all consumers and are not modified for project-specific behavior. Project-specific workflows and conventions are defined in the constitution.

### Project-Specific Behavior in Constitution

When project-specific post-apply behavior is needed (such as version bumps), it is defined as a convention in `openspec/CONSTITUTION.md`, not added as a step in the skill file.

### End-to-End Install Flow

The complete install path is: `claude plugin marketplace add` followed by `claude plugin install` followed by `/opsx:setup` followed by `/opsx:bootstrap`.

### End-to-End Update Flow

The complete update path is: `claude plugin marketplace update` followed by `claude plugin update`. Running `/opsx:setup` again is safe (idempotent) and ensures schema updates are picked up.

### Post-Push Developer Plugin Update

For developers using the local marketplace, running `claude plugin update opsx@opsx-enhanced-flow` detects the local version change and updates the cached plugin. For developers using the GitHub marketplace, the existing `marketplace update` + `plugin update` flow applies.

### Post-Apply Workflow Next Steps

After a completed change, the post-apply workflow includes next steps: verify, changelog, docs, version bump, and commit.

### Changelog from Single Change

Running `/opsx:changelog` reads each completed change directory, examines the proposal, current specs, and design artifacts, and produces changelog entries summarizing what changed from a user perspective. Entries use the Keep a Changelog format with sections like Added, Changed, and Fixed as applicable.

### Multiple Archives Ordered Newest First

When multiple archives exist, changelog entries are ordered with the newest first.

### Existing Changelog Preserved

If `CHANGELOG.md` already contains manually written entries, new entries are added at the top without modifying or removing existing content.

### No Completed Changes to Process

If no completed changes exist, `/opsx:changelog` informs you that no completed changes were found.

### Internal-Only Changes

If an archived change describes purely internal refactoring with no user-visible impact, it is either omitted or included under a minimal note rather than fabricating user-facing changes.

### Changelog in Configured Language

When `openspec/WORKFLOW.md` contains a `docs_language` setting (for example, `German`), `/opsx:changelog` generates section headers and entry descriptions in that language. Dates remain in ISO format and product names stay in English.

### Default Language

When the `docs_language` field is missing or set to `English`, changelog entries are generated in English.

### Language Change Mid-Project

If the documentation language is changed after entries have already been generated, existing entries are preserved in their original language and new entries use the new language.

## Known Limitations

- Does not support automatic minor or major version bumps — these require a manual process (but the Action handles tagging automatically after push).
- Consumer migration from the old flat layout to the new `src/` layout requires a `plugin update` — there is no automatic migration.

## Future Enhancements

- A `/opsx:status` skill for checking the current project and plugin state.
- Sparse checkout via `git-subdir` for even more efficient consumer downloads.

## Edge Cases

- If `src/.claude-plugin/plugin.json` does not exist (consumer projects without plugin manifests), the version bump step is silently skipped.
- If `CHANGELOG.md` is missing when the release Action runs, the release is created with a minimal body instead of failing.
- If a consumer adds the marketplace before the `src/` restructuring, the old cache is replaced on the next `plugin update`.
- If the version field contains a non-semver value, the system warns and skips the bump rather than producing an invalid version.
- If the archive directory contains changes with only internal refactoring, the changelog agent either omits the entry or uses a minimal note to avoid fabricating user-facing changes.
