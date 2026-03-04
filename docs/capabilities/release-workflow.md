---
title: "Release Workflow"
capability: "release-workflow"
description: "Automatic patch version bumps on archive, version sync, manual release process, and consumer update guidance"
order: 16
lastUpdated: "2026-03-04"
---

# Release Workflow

The release workflow handles version management automatically on archive, keeps version numbers in sync across plugin files, and provides clear processes for both maintainers releasing new versions and consumers updating.

## Features

- Automatic patch version bump after each successful archive
- Version synchronization between plugin files
- Documented manual process for minor and major releases with git tags
- Consumer update guidance (marketplace refresh, plugin update, restart)
- Skill immutability convention — project-specific behavior lives in the constitution, not in skills
- End-to-end install and update checklists for verification
- Post-push developer plugin auto-update guidance

## Behavior

### Automatic Patch Bump on Archive

After a successful archive, the patch version is automatically incremented in both plugin files (e.g., 1.0.3 becomes 1.0.4). The new version is displayed in the archive summary. If the version numbers are out of sync before bumping, they are aligned to the plugin.json version first, then the patch bump is applied.

### Manual Minor and Major Releases

For intentional minor or major version changes, you manually update the version in both plugin files, create a git tag (e.g., `v1.1.0`), push the tag, and optionally create a GitHub Release. This process is documented but not automated.

### Consumer Updates

To update to the latest plugin version:
1. Run `claude plugin marketplace update opsx-enhanced-flow` to refresh the listing
2. Run `claude plugin update opsx@opsx-enhanced-flow` to install the update
3. Restart Claude Code to load the new version

If an update is not detected, refresh the marketplace listing first and retry. As a last resort, uninstall and reinstall the plugin.

### Skill Immutability

Skills are generic plugin code shared across all consumers. They are not modified for project-specific behavior. Project-specific workflows and conventions are defined in the constitution.

### Post-Archive Next Steps

After a successful archive, the output includes next steps guiding you through the complete post-archive workflow: generate changelog, push, and update the local plugin.

### Developer Plugin Auto-Update

After pushing a version bump to the remote, the developer updates their local plugin installation to match, ensuring they always develop against the latest version.

## Edge Cases

- If plugin files have version numbers that are out of sync, they are aligned to the plugin.json version before the patch bump is applied.
- The clean install flow (marketplace add → install → init → bootstrap) and update flow (marketplace update → plugin update → verify) serve as end-to-end checklists for verifying the full pipeline works.
