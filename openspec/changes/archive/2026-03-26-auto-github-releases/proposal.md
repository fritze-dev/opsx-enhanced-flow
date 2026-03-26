## Why

GitHub Releases are currently a manual step after `/opsx:changelog`. Every archive cycle requires the maintainer to remember to create tags and releases by hand, leading to releases falling out of sync with changelog entries. Additionally, the plugin repo mixes plugin source code with project metadata (docs, CI, specs, changelog), causing consumers to download files they don't need. The developer workflow relies on `--plugin-dir` which doesn't work in VS Code.

## What Changes

- **Repo restructuring**: Move plugin source files into `src/` subdirectory. Consumer cache only contains `src/`, not docs/CI/specs. marketplace.json uses `source: "./src"`.
- **Setup skill update**: Template path changes from `${CLAUDE_PLUGIN_ROOT}/openspec/templates/` to `${CLAUDE_PLUGIN_ROOT}/templates/`
- **New GitHub Action** (`.github/workflows/release.yml`) that automatically creates a git tag and GitHub Release when `plugin.json` version changes on `main`
- **Updated developer documentation** in README.md: local marketplace approach (works in VS Code), consumer version pinning via `#ref`, `src/` structure explanation
- **Updated DevContainer** to use local marketplace instead of GitHub clone
- **Updated constitution convention**: automated releases, version bump path changes to `src/.claude-plugin/plugin.json`
- **New settings permission** for `git tag` commands

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `release-workflow`: Adding automated GitHub Release creation via CI, consumer version pinning, developer local marketplace workflow, plugin source directory structure (`src/`), marketplace source configuration, and repository layout separation
- `project-setup`: Template copy path changes from `openspec/templates/` to `templates/` relative to plugin root

### Consolidation Check

1. Existing specs reviewed: `release-workflow`, `workflow-contract`, `artifact-generation`, `project-setup`, `artifact-pipeline`, `three-layer-architecture`
2. Overlap assessment:
   - `release-workflow` covers version bumping, manual releases, consumer updates — auto-release, directory structure, and marketplace config all extend the same consumer distribution domain (same actor, trigger, data model)
   - `project-setup` covers `/opsx:setup` behavior — template path change modifies this
3. Merge assessment: Directory structure + marketplace source + layout separation folded into `release-workflow` — they share actor (maintainer/consumer), trigger (plugin install/update), and data model (marketplace.json, plugin.json, file paths). No new spec needed.

## Impact

- **Repository structure**: `skills/`, `openspec/templates/`, `.claude-plugin/plugin.json` move into `src/`
- **Setup skill**: Template copy path changes (`CLAUDE_PLUGIN_ROOT` now points to `src/`)
- **CI/CD**: New release action, existing actions unaffected (they run at repo root)
- **Developer workflow**: Local marketplace + `source: "./src"` replaces `--plugin-dir`
- **Consumer workflow**: Smaller cache (only `src/`), version pinning via `#ref`
- **Constitution**: Version bump path, release automation convention
- **DevContainer**: Local marketplace instead of GitHub clone

## Scope & Boundaries

**In scope:**
- Repo restructuring: move plugin files to `src/`
- marketplace.json `source` change from `"./"` to `"./src"`
- Setup skill template path update
- GitHub Action for automatic tag + release
- README developer documentation (local marketplace, pinning, structure)
- DevContainer update to local marketplace
- Constitution convention update
- Settings permission for `git tag`
- New spec `plugin-distribution`, delta specs for `release-workflow` and `project-setup`

**Out of scope:**
- WORKFLOW.md hook changes (no `post_changelog` — Action handles releases)
- Minor/major release automation (stays manual)
- Changelog skill changes
- Consumer-facing spec changes (consumers still run `/opsx:setup` → `/opsx:bootstrap`)
