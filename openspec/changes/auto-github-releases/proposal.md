## Why

GitHub Releases are currently a manual step after `/opsx:changelog`. Every archive cycle requires the maintainer to remember to create tags and releases by hand. This leads to releases falling out of sync with changelog entries and version bumps. Automating this closes the gap between version bump and release publication.

## What Changes

- **New GitHub Action** (`.github/workflows/release.yml`) that automatically creates a git tag and GitHub Release when `plugin.json` version changes on `main`
- **Updated developer documentation** in README.md: replaces `--plugin-dir` with the local marketplace approach (which works in VS Code), documents consumer version pinning via `#ref`
- **Updated DevContainer** to use local marketplace instead of GitHub clone for development
- **Updated constitution convention** to reflect that tags and releases are now automated
- **New settings permission** for `git tag` commands

## Capabilities

### New Capabilities

None — this change adds CI automation and documentation, not new plugin capabilities with testable requirements.

### Modified Capabilities

- `release-workflow`: Adding requirement for automated GitHub Release creation via CI, consumer version pinning documentation, and developer local marketplace workflow

### Consolidation Check

1. Existing specs reviewed: `release-workflow`, `workflow-contract`, `artifact-generation`, `project-setup`, `artifact-pipeline`
2. Overlap assessment: The `release-workflow` spec already covers version bumping, manual release process, and consumer updates. Auto GitHub Releases is a direct extension of this existing capability — no new spec needed.
3. Merge assessment: N/A — single modified capability.

## Impact

- **CI/CD**: New GitHub Action workflow file alongside existing `claude.yml` and `claude-code-review.yml`
- **Developer workflow**: Local marketplace replaces `--plugin-dir` for VS Code compatibility
- **Consumer workflow**: Version pinning via `#ref` at marketplace add time (documentation only, no code change)
- **DevContainer**: postCreateCommand changes from GitHub marketplace to local path
- **Constitution**: Release convention updated to reflect automation
- **Settings**: New `git tag` permission

## Scope & Boundaries

**In scope:**
- GitHub Action for automatic tag + release on version change
- README developer documentation update (local marketplace, pinning, auto-releases)
- DevContainer update to local marketplace
- Constitution convention update
- Settings permission for `git tag`
- Delta spec for `release-workflow`

**Out of scope:**
- Changing `marketplace.json` source field (must stay `"./"` for local dev)
- New skills or WORKFLOW.md hooks
- Minor/major release automation (stays manual per existing convention)
- Changelog skill changes (Action reads existing CHANGELOG.md output)
