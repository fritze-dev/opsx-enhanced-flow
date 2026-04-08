## Why

With delta-specs eliminated (ADR-037), there is no built-in mechanism to track which specs are actively being edited or by which change. Four skills (verify, changelog, docs, preflight) rely on fragile text parsing of proposal `## Capabilities` sections to identify affected specs — a pattern that breaks silently on older changes and triggers overly broad fallbacks. Additionally, Smart Templates have no version tracking — `/opsx:setup` overwrites local templates via `cp -r` on every run, silently destroying user customizations (#67).

## What Changes

- Add four YAML frontmatter fields to spec files: `status` (stable/draft), `change` (only when draft), `version` (integer), `lastModified` (YYYY-MM-DD)
- FF skill sets `status: draft`, `change`, and `lastModified` when editing specs during the specs stage
- Verify flips `draft → stable`, removes `change`, bumps `version`, and sets `lastModified` during completion
- Verify gates on draft status: FAIL if specs belonging to the current change are still draft
- Preflight validates that `draft` specs have a `change` value matching the current change
- Changelog and docs skills use `version`/`lastModified` for detection instead of proposal parsing
- Migrate all 18 existing specs with `status: stable`, `version: 1`, `lastModified: 2026-04-08`
- Add `version` field to all Smart Template frontmatter (integer, bumped on plugin changes)
- Setup skill uses template `version` for merge detection: unchanged local templates are updated silently, customized templates trigger merge with conflict surfacing

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `spec-format`: Add `status`, `change`, `version`, `lastModified` frontmatter field definitions and lifecycle rules
- `artifact-generation`: FF must set `status: draft`, `change: <change-dir>`, `lastModified: <today>` when creating or modifying specs
- `quality-gates`: Verify must gate on draft status (FAIL if draft specs remain); verify completion flips `draft → stable`, bumps `version`, sets `lastModified`. Preflight validates `draft` specs match current change.
- `release-workflow`: Changelog detection uses spec `version`/`lastModified` instead of proposal Capabilities parsing
- `user-docs`: Docs incremental detection uses spec `lastModified` instead of directory-date comparison with proposal parsing fallback
- `workflow-contract`: Smart Template frontmatter format adds `version` field definition
- `project-setup`: Setup uses template `version` for merge detection — skip overwrite when user has customized, merge new plugin template changes with local customizations, surface conflicts for manual resolution

### Removed Capabilities

(none)

### Consolidation Check

1. **Existing specs reviewed**: all 18 specs — project-setup, project-bootstrap, change-workspace, workflow-contract, artifact-pipeline, artifact-generation, interactive-discovery, constitution-management, quality-gates, task-implementation, human-approval-gate, release-workflow, three-layer-architecture, spec-format, roadmap-tracking, user-docs, architecture-docs, decision-docs
2. **Overlap assessment**: No new capabilities proposed. All changes fold into existing specs:
   - Frontmatter field definitions → `spec-format` (owns spec format rules)
   - Draft lifecycle in FF → `artifact-generation` (owns FF behavior)
   - Verify gate + completion flip → `quality-gates` (owns verify/preflight behavior)
   - Changelog detection → `release-workflow` (owns changelog generation)
   - Docs detection → `user-docs` (owns incremental doc generation)
   - Template version field definition → `workflow-contract` (owns Smart Template format)
   - Template merge during setup → `project-setup` (owns setup behavior)
3. **Merge assessment**: N/A — no new specs proposed.

## Impact

- **Spec template**: `src/templates/specs/spec.md` and `openspec/templates/specs/spec.md` — add new frontmatter fields to template output
- **All Smart Templates**: 10 templates in `src/templates/` — add `version` field to frontmatter
- **Skills**: `src/skills/ff/SKILL.md`, `src/skills/verify/SKILL.md`, `src/skills/changelog/SKILL.md`, `src/skills/docs/SKILL.md`, `src/skills/setup/SKILL.md`
- **Existing specs**: 18 spec files need one-time frontmatter migration
- **Backward compatibility**: New fields are optional — consumers without them continue to work. Skills handle absent fields gracefully. Setup falls back to overwrite behavior when local templates lack `version` field.

## Scope & Boundaries

**In scope:**
- Spec frontmatter field definitions and lifecycle rules
- Smart Template `version` field definition and merge semantics
- FF, verify, preflight, changelog, docs, setup skill updates
- Spec template updates (both consumer and project)
- All Smart Template updates (add `version: 1`)
- Migration of 18 existing specs
- Setup merge detection: version comparison, customization detection, conflict surfacing

**Out of scope:**
- Proposal frontmatter changes (could complement but not needed for core goals)
- Automated orphan draft detection/cleanup (enforced via verify gate instead)
- Create date tracking (can be added later if needed)
- WORKFLOW.md merge (special file — handled separately from Smart Templates)
