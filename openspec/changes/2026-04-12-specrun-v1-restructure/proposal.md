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

The current "OpenSpec/OPSX" naming and `openspec/` folder structure create unnecessary nesting, namespace confusion, and template duplication. The project is ready for a clean v1.0 release as **SpecRun** — a product name that stands on its own. A clean slate in a new repository eliminates 58 historical changes, 54 ADRs with obsolete paths, and the baggage of iterative refactoring. This is the right moment because there are no active consumers relying on the current structure.

## What Changes

- **BREAKING**: Rename product from "OpenSpec/OPSX" to "SpecRun", plugin name from `opsx` to `specrun`
- **BREAKING**: New folder structure — `.specrun/` as hidden infrastructure dir, `docs/specs/` for flat specs
- **BREAKING**: New repository `specrun` (old `opsx-enhanced-flow` archived)
- All `openspec/` paths replaced: `openspec/WORKFLOW.md` → `.specrun/WORKFLOW.md`, `openspec/CONSTITUTION.md` → `.specrun/CONSTITUTION.md`, `openspec/specs/<name>/spec.md` → `docs/specs/<name>.md`, `openspec/changes/` → `.specrun/changes/`, `openspec/templates/` → `.specrun/templates/`
- Templates stay at `src/templates/` (plugin level), copied to `.specrun/templates/` during init
- Skill discovery via plugin system only — no `.agents/` or `.claude/skills/` symlinks
- `AGENTS.md` + `CLAUDE.md` symlink replaced by single `CLAUDE.md`
- Dogfooding setup 1:1 like a client project (no symlinks)
- Template versions reset to 1, plugin version 1.0.0
- All "OpenSpec" wording removed from requirement names, spec text, templates, and docs

## Capabilities

### New Capabilities

None — this is a structural refactoring, not a new feature.

### Modified Capabilities

All 14 existing specs receive path updates and naming changes:

- `artifact-pipeline`: `openspec/` paths → `.specrun/` and `docs/specs/` paths throughout
- `change-workspace`: Workspace path `openspec/changes/` → `.specrun/changes/`, proposal scan paths updated
- `constitution-management`: Constitution path `openspec/CONSTITUTION.md` → `.specrun/CONSTITUTION.md`
- `documentation`: All spec references, capability doc paths, ADR generation paths updated
- `human-approval-gate`: Review artifact path references updated
- `project-init`: Major rewrite — "Install OpenSpec Workflow" → "Install SpecRun Workflow", all target paths changed, legacy migration removed (handled by old repo README), template source paths updated
- `quality-gates`: Spec reference paths updated
- `release-workflow`: Plugin name `opsx` → `specrun`, marketplace references updated, repo name changed
- `roadmap-tracking`: Minor path updates
- `spec-format`: Spec directory references updated
- `task-implementation`: Change artifact paths updated
- `test-generation`: Spec parsing paths updated
- `three-layer-architecture`: Architecture layer descriptions updated to reflect new structure
- `workflow-contract`: WORKFLOW.md path, template directory references updated

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. All 14 existing specs are modified for path/naming updates. No specs are merged or split — the capability boundaries remain unchanged.

## Impact

- **All 14 spec files**: Path references updated (~280+ occurrences)
- **SKILL.md**: All 39+ `openspec/` references updated, requirement anchor links updated
- **All 14 templates**: `openspec/` paths replaced with new paths
- **Plugin manifests**: Name and version changed
- **CONSTITUTION.md**: Self-referential paths and conventions updated
- **WORKFLOW.md**: templates_dir and context paths updated
- **README.md**: Complete rewrite for new product name and installation flow
- **docs/**: capabilities and README regenerated with new paths

## Scope & Boundaries

**In scope:**
- New repo structure with `.specrun/`, `docs/specs/`, `src/`
- All path and naming changes across specs, templates, skill, manifests
- Spec content transfer (14 specs, flattened)
- New ADR-001 documenting the architecture decision
- New CHANGELOG.md starting at v1.0.0
- New README.md with SpecRun branding and install instructions
- Dogfooding setup as 1:1 client project

**Out of scope:**
- Scalable pipelines (fast/full) — deferred to future change
- Plugin update check hook — deferred to future change
- CI/CD enforcer GitHub Action — not needed (workflow handles guardrails)
- Anti-laziness directives — not needed (workflow handles this)
- Spec content changes beyond path/naming updates (behavior stays the same)
- Old repo migration tooling — migration prompt in archived repo README only
