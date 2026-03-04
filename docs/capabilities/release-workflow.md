---
title: "Release Workflow"
capability: "release-workflow"
description: "Automatic patch versioning on archive, manual minor/major releases, and consumer update process"
order: 16
lastUpdated: "2026-03-04"
---

# Release Workflow

The plugin uses automatic patch version bumps to ensure consumers always detect updates. When you archive a change, the version increments automatically. For larger releases, a manual process with git tags is available.

## Features

- Patch versions auto-increment when you archive a change via `/opsx:archive`
- Both plugin version files stay synchronized automatically
- Manual process for minor and major version releases with git tags and GitHub Releases
- Clear consumer update steps: refresh marketplace, update plugin, restart Claude Code
- Developer plugin auto-update after pushing a new version
- End-to-end checklist for testing the full install and update flow

## Behavior

### Automatic Patch Bump

When you archive a completed change, the system automatically increments the patch version (e.g., 1.0.3 becomes 1.0.4) and keeps both version files in sync. If the files were out of sync beforehand, the system corrects this before bumping. The new version is displayed in the archive summary along with next steps.

### Manual Minor and Major Releases

For intentional feature-level or breaking changes, you manually set the version in both plugin files, create a git tag, push it, and optionally create a GitHub Release. This gives you full control over when and how larger releases are published.

### Consumer Update Process

To update the plugin, consumers refresh the marketplace listing, run the update command, and restart Claude Code. If an update isn't detected, refreshing the marketplace listing first usually resolves it. As a last resort, uninstalling and reinstalling the plugin works as a fallback.

### Skill Immutability

Skills are shared plugin code and must not be customized for specific projects. Any project-specific behavior — like version bumps or post-action workflows — is defined in the project constitution instead.

### End-to-End Testing

The full install flow (marketplace add, plugin install, `/opsx:init`, `/opsx:bootstrap`) and the update flow (marketplace update, plugin update, verify) are documented as testable checklists to catch regressions.

### Developer Plugin Update

After pushing a version bump, developers update their local plugin installation by refreshing the marketplace listing and running the plugin update command. This ensures the developer always works with the latest plugin version.

### Archive Next Steps

After a successful archive with auto-bump, the system shows next steps: generate changelog, push, and update the local plugin.

## Edge Cases

- If the `gh` CLI is not available, you can create GitHub Releases through the web UI instead
- The consumer update process is the same regardless of how many versions behind — marketplace update followed by plugin update always fetches the latest version
