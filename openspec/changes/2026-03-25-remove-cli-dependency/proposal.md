## Why

The plugin requires users to install the OpenSpec CLI (`@fission-ai/openspec@^1.2.0`) via npm as a global dependency. This adds Node.js + npm as prerequisites for a project that otherwise only needs Claude Code. All data the CLI provides is already present in local files (schema.yaml, templates, directory structure) that Claude can read directly. Removing the CLI simplifies setup, eliminates an external dependency, and makes the plugin self-contained.

## What Changes

- **BREAKING**: Skills no longer shell out to `openspec` CLI commands. Instead, they read `openspec/schemas/opsx-enhanced/schema.yaml` and templates directly.
- `/opsx:setup` no longer installs the OpenSpec CLI — it only copies schema files and creates config.
- Change creation (`openspec new change`) replaced by `mkdir -p`.
- Change listing (`openspec list --json`) replaced by directory listing.
- Artifact status (`openspec status --json`) replaced by file-existence checks against schema's `generates` fields.
- Artifact instructions (`openspec instructions`) replaced by direct schema.yaml + template reads.
- Archiving (`openspec archive change`) replaced by `mv` command.
- Node.js + npm prerequisites removed from README, devcontainer, and constitution.
- All `openspec`-prefixed Bash permissions removed from `.claude/settings.local.json`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-setup`: Remove CLI installation requirement and CLI prerequisite check. Setup becomes schema-file-copy + config-creation only.
- `three-layer-architecture`: Update layer separation requirement — skills depend on schema via direct file reads instead of via CLI.
- `artifact-pipeline`: Update dependency enforcement — artifact status computed by file existence checks instead of CLI enforcement.
- `artifact-generation`: Update skill descriptions — skills read schema.yaml directly instead of wrapping CLI commands.
- `change-workspace`: Remove CLI delegation for workspace creation — use `mkdir -p` instead of `openspec new change`.
- `task-implementation`: Update context loading — read change directory files directly instead of CLI `instructions apply` output.
- `interactive-discovery`: Update prerequisite check — verify file existence instead of `openspec schema which`.

### Consolidation Check

1. **Existing specs reviewed:** All 18 specs in `openspec/specs/` (architecture-docs, artifact-generation, artifact-pipeline, change-workspace, constitution-management, decision-docs, human-approval-gate, interactive-discovery, project-bootstrap, project-setup, quality-gates, release-workflow, roadmap-tracking, spec-format, spec-sync, task-implementation, three-layer-architecture, user-docs).
2. **Overlap assessment:** No new capabilities proposed — all changes modify existing specs whose requirements directly reference CLI behavior.
3. **Merge assessment:** N/A — no new capabilities to merge.

N/A — no new specs proposed.

## Impact

- **Skills (13):** All SKILL.md files modified to replace CLI calls with file reads.
- **Documentation:** README.md, constitution.md, schema README updated to remove CLI references.
- **DevContainer:** Node.js feature and openspec npm install removed.
- **Settings:** CLI-specific Bash permissions removed from `.claude/settings.local.json`.
- **Consumer projects:** No migration needed — schema files already exist locally after setup. New setup runs the updated skill.
- **Archived changes:** Unaffected — `.openspec.yaml` files from CLI are inert.

## Scope & Boundaries

**In scope:**
- Replace all `openspec` CLI calls in skills with direct file reads
- Update setup skill to remove CLI installation
- Update specs (project-setup, three-layer-architecture, artifact-pipeline, artifact-generation) to reflect new architecture
- Update README, constitution, schema README, devcontainer, settings
- Remove Node.js/npm prerequisites

**Out of scope:**
- Schema.yaml format changes (stays identical)
- Template changes (stay identical)
- Config.yaml changes (stays identical)
- Archived change migration
- Multi-schema support (preserved via config.yaml indirection but not expanded)

## Pull Request

- **Branch**: `remove-cli-dependency`
- **PR URL**: https://github.com/fritze-dev/opsx-enhanced-flow/pull/54
- **Status**: Draft
