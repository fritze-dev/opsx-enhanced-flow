<!--
---
status: active
branch: specrun-v1-restructure
capabilities:
  new: []
  modified:
    - artifact-pipeline
    - change-workspace
    - constitution-management
    - documentation
    - human-approval-gate
    - project-init
    - quality-gates
    - release-workflow
    - roadmap-tracking
    - spec-format
    - task-implementation
    - test-generation
    - three-layer-architecture
    - workflow-contract
  removed: []
---
-->
## Why

The current "OpenSpec/OPSX" naming and `openspec/` folder structure create unnecessary nesting, namespace confusion, and template duplication. The project is ready for a rebrand as **SpecShift**. Rather than shipping a polished v1.0 in one shot, we start with a **Beta** that focuses purely on mechanics and structure — the code runs in the new folders, the commands work. Existing docs, ADRs, and specs stay as-is or move unsorted into `docs/`. Consolidation and polish come later at v1.0 after the beta validates the workflow in practice.

A Fork & Rewrite approach duplicates the repo under the new name, restructures via `git mv`/`git rm`, and preserves the full git blame history.

## What Changes

### Beta (this change)

- **BREAKING**: Rename product from "OpenSpec/OPSX" to "SpecShift", plugin name from `opsx` to `specshift`
- **BREAKING**: Skill renamed from `workflow` to `specshift` → commands become `specshift init`, `specshift propose`, `specshift apply`, `specshift finalize`
- **BREAKING**: Skill folder renamed from `src/skills/workflow/` to `src/skills/specshift/`
- **BREAKING**: New folder structure — `.specshift/` as hidden infrastructure dir, `docs/specs/` for flat specs
- **BREAKING**: Repository duplicated as `specshift` (old `opsx-enhanced-flow` archived). Full git history preserved.
- All `openspec/` paths replaced via `git mv`:
  - `openspec/WORKFLOW.md` → `.specshift/WORKFLOW.md`
  - `openspec/CONSTITUTION.md` → `.specshift/CONSTITUTION.md`
  - `openspec/specs/<name>/spec.md` → `docs/specs/<name>.md` (flattened)
  - `openspec/changes/` → `.specshift/changes/`
  - `openspec/templates/` → `.specshift/templates/`
- Existing ADRs and capability docs moved as-is into `docs/` (no consolidation, no rewrite)
- Templates stay at `src/templates/` (plugin level), copied to `.specshift/templates/` during init
- Skill discovery via plugin system only — no `.agents/` or `.claude/skills/` symlinks
- `AGENTS.md` + `CLAUDE.md` symlink replaced by single `CLAUDE.md`
- Dogfooding setup 1:1 like a client project (no symlinks)
- Template versions reset to 1, plugin version 0.1.0-beta
- Path references updated in SKILL.md, templates, and WORKFLOW.md

### Deferred to v1.0

- ADR consolidation (55 ADRs → clean summary)
- Spec content rewrite (remove OpenSpec wording from requirement names and prose)
- Capability docs regeneration
- Final README.md and CHANGELOG.md polish
- Template freeze
- Version 1.0.0 release

## Capabilities

### New Capabilities

None — this is a structural refactoring, not a new feature.

### Modified Capabilities

All 14 existing specs receive **path updates only** in the beta. Content rewrites deferred to v1.0:

- `artifact-pipeline`: `openspec/` paths → `.specshift/` and `docs/specs/` paths
- `change-workspace`: Workspace path `openspec/changes/` → `.specshift/changes/`
- `constitution-management`: Constitution path → `.specshift/CONSTITUTION.md`
- `documentation`: Spec references and doc paths updated
- `human-approval-gate`: Review artifact path references updated
- `project-init`: Target paths changed, template source paths updated, skill references `workflow` → `specshift`
- `quality-gates`: Spec reference paths updated
- `release-workflow`: Plugin name `opsx` → `specshift`, repo name changed
- `roadmap-tracking`: Minor path updates
- `spec-format`: Spec directory references updated
- `task-implementation`: Change artifact paths updated
- `test-generation`: Spec parsing paths updated
- `three-layer-architecture`: Architecture layer paths updated
- `workflow-contract`: WORKFLOW.md path, template directory references updated

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. All 14 existing specs are modified for path updates only. No specs are merged or split.

## Impact

- **SKILL.md**: Moved to `src/skills/specshift/SKILL.md`, all 39+ `openspec/` references updated
- **All 14 templates**: `openspec/` paths replaced with new paths
- **All 14 spec files**: Path references updated (~280+ occurrences)
- **Plugin manifests**: Name and version changed
- **CONSTITUTION.md**: Self-referential paths updated
- **WORKFLOW.md**: templates_dir and context paths updated
- **Existing docs/ADRs**: Moved as-is (no content changes in beta)

## Scope & Boundaries

**In scope (Beta):**
- Duplicate repo as `specshift`, restructure via `git mv`/`git rm`
- All path updates across specs, templates, skill, manifests
- Specs flattened via `git mv` (14 specs, `spec.md` → `<name>.md`)
- Router SKILL.md functional with new paths
- Dogfooding setup as 1:1 client project
- Plugin version 0.1.0-beta

**Out of scope (deferred to v1.0):**
- ADR consolidation and cleanup
- Spec content rewrite (OpenSpec wording in requirement names/prose)
- Capability docs regeneration
- Final README.md / CHANGELOG.md polish
- Template freeze
- Scalable pipelines (fast/full)
- Plugin update check hook
