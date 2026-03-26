---
status: Accepted
date: 2026-03-26
---
# ADR-031: Auto GitHub Releases and Plugin Source Restructuring

## Context

The plugin repository mixed plugin source code (skills, templates, manifest) with project management files (documentation, CI, specs, changelogs) at the repository root. Consumers downloading the plugin received all files, including those irrelevant to plugin functionality. GitHub Releases were a manual step after each archive cycle, frequently falling out of sync with changelog entries. The developer workflow relied on `--plugin-dir` which does not work in the VS Code extension.

## Decision

1. **`src/` as subdirectory name** — short, conventional, clearly identifies source code
2. **`src/templates/` flat structure** — cleaner than `src/openspec/templates/`; the `openspec/` nesting was an artifact of co-location, not a meaningful namespace
3. **marketplace.json stays at root `.claude-plugin/`** — required for marketplace discovery; `marketplace add` looks for `.claude-plugin/marketplace.json` at the repo root
4. **GitHub Action triggers on `src/.claude-plugin/plugin.json` path** — precise path filter; only fires on version changes, not other pushes
5. **Action uses `gh release create`** — simpler than the REST API; `gh` is pre-installed on runners and handles both tag and release creation in one command
6. **Root `.claude-plugin/` has only marketplace.json** — plugin.json belongs with the plugin source in `src/`, avoiding ambiguity about which manifest is authoritative

## Alternatives Considered

- **`plugin/` as subdirectory name** — longer, less standard than `src/`
- **Keep `openspec/templates/` nesting inside `src/`** — unnecessary depth
- **Move marketplace.json alongside plugin.json in `src/`** — breaks marketplace discovery
- **Trigger on any push to main** — too broad; releases would fire on non-version changes
- **Trigger on tag push** — chicken-and-egg problem (who creates the tag?)
- **GitHub REST API directly** — more verbose; separate tag and release steps
- **Keep plugin.json at root too** — confusing dual source of truth

## Consequences

### Positive

- Consumer caches contain only plugin files — no docs, CI workflows, or project metadata
- GitHub Releases are created automatically, always in sync with changelog entries
- Developers can use the local marketplace in VS Code (no `--plugin-dir` needed)
- Clear separation between plugin source and project management
- Marketplace works identically for both local filesystem and GitHub-based installations

### Negative

- Breaking change for existing consumers — requires `plugin update` to switch to `src/` layout (no migration tooling)
- `CLAUDE_PLUGIN_ROOT` assumption — if it doesn't resolve to the cached `src/` directory, the setup skill fails (validated via testing)

## References

- [Archive: auto-github-releases](../../openspec/changes/archive/2026-03-26-auto-github-releases/)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-004: Release Workflow](adr-004-release-workflow.md)
- [ADR-029: Dissolve Schema Directory](adr-029-dissolve-schema-directory.md)
