## Why

The OpenSpec CLI has been removed but its directory structure (`openspec/schemas/opsx-enhanced/`) persists as unnecessary indirection. Instructions are split from templates in schema.yaml, config is split across schema.yaml and config.yaml, and the `continue` skill duplicates ff's functionality. This change dissolves the schema directory, introduces WORKFLOW.md + Smart Templates as replacements, and consolidates the generation commands.

## What Changes

- **NEW**: `openspec/WORKFLOW.md` replaces schema.yaml + config.yaml as slim pipeline orchestration file (YAML frontmatter)
- **NEW**: Smart Templates — templates with YAML frontmatter carrying `id`, `generates`, `requires`, `instruction` metadata alongside the output structure
- **NEW**: `openspec/CONSTITUTION.md` (caps rename from constitution.md)
- **NEW**: Template variable substitution (`{{ change.name }}`, `{{ change.stage }}`, `{{ project.name }}`)
- **REMOVED**: `openspec/schemas/opsx-enhanced/` directory (schema.yaml, README.md, templates/)
- **REMOVED**: `openspec/config.yaml` (absorbed into WORKFLOW.md)
- **REMOVED**: `skills/continue/` (merged into ff)
- **MODIFIED**: All 12 remaining skills updated to read WORKFLOW.md + Smart Templates
- **MODIFIED**: `/opsx:setup` generates WORKFLOW.md + copies templates instead of schema directory
- **MODIFIED**: `/opsx:ff` absorbs continue's change-selection logic for existing changes

## Capabilities

### New Capabilities
- `workflow-contract`: Defines the WORKFLOW.md format (YAML frontmatter for pipeline orchestration) and the Smart Template format (YAML frontmatter with instruction + metadata in template files). Covers template variable substitution, file resolution, and the new reading pattern for skills.

### Modified Capabilities
- `three-layer-architecture`: Layer definitions change from Constitution → Schema → Skills to CONSTITUTION.md → WORKFLOW.md → Skills. Schema layer replaced by WORKFLOW.md + Smart Templates. File paths and separation rules updated.
- `artifact-pipeline`: All references to schema.yaml replaced with WORKFLOW.md + Smart Templates. Instructions move from schema.yaml to template frontmatter. Config bootstrap (config.yaml) replaced by WORKFLOW.md. Post-artifact hook moves to WORKFLOW.md.
- `artifact-generation`: `/opsx:continue` removed. `/opsx:ff` becomes sole generation command with change-selection for existing changes. "Unified Skill Delivery" requirement updated for single skill.
- `project-setup`: Setup generates WORKFLOW.md + CONSTITUTION.md + copies templates/ instead of schema directory + config.yaml. Migration logic for existing projects with old layout.

### Consolidation Check

1. **Existing specs reviewed**: three-layer-architecture, artifact-pipeline, artifact-generation, project-setup, spec-format, spec-sync, quality-gates, task-implementation, change-workspace, constitution-management, release-workflow, interactive-discovery, project-bootstrap, human-approval-gate, user-docs, architecture-docs, decision-docs, roadmap-tracking

2. **Overlap assessment for `workflow-contract`**:
   - Closest: `artifact-pipeline` — covers schema-level pipeline definition. However, `workflow-contract` is a distinct new concept (WORKFLOW.md file format + Smart Template format) that doesn't exist in any current spec. The pipeline spec will be modified to reference the new format, but the format definition itself is new domain knowledge.
   - Also checked: `three-layer-architecture` — covers layer responsibilities but not file format details. `project-setup` — covers setup behavior but not the contract format.

3. **Merge assessment**: Only one new capability proposed — no pair-wise merge needed.

## Impact

- **All 13 skill files** — path references change from `schema.yaml`/`config.yaml` to `WORKFLOW.md` + template paths
- **`openspec/schemas/` directory** — fully removed
- **`openspec/config.yaml`** — removed (absorbed into WORKFLOW.md)
- **`openspec/constitution.md`** — renamed to CONSTITUTION.md (caps)
- **`openspec/templates/`** — new location for templates (moved from schemas/opsx-enhanced/templates/)
- **Consumer projects** — require `/opsx:setup` re-run for migration
- **PR #27** — closed (superseded by this change)
- **README.md** — major update to reflect new architecture

## Scope & Boundaries

**In scope:**
- WORKFLOW.md format and creation
- Smart Template format (all 10 templates)
- Template variable substitution ({{ change.name }}, {{ change.stage }}, {{ project.name }})
- Constitution rename to CONSTITUTION.md
- Continue → FF merge
- All skill path updates
- Setup skill rewrite with migration logic
- Spec updates for affected capabilities
- Constitution and README updates

**Out of scope:**
- Moving WORKFLOW.md/CONSTITUTION.md to project root (separate follow-up change)
- Full Liquid template engine (simple string substitution only)
- Skill consolidation beyond continue→ff (planned separately)
- Changes to archive structure or spec format
