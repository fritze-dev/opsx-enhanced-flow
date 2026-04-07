## Why

PR #77 eliminated `config.yaml`, `schema.yaml`, and the `openspec/schemas/` directory, but ~57 references in capability specs still point to these removed paths. This causes specs to be inconsistent with the actual project structure, potentially misleading AI agents and human readers.

## What Changes

- Replace `openspec/config.yaml` → `openspec/WORKFLOW.md` in docs_language references across 6 specs
- Replace `openspec/schemas/opsx-enhanced/templates/` → `openspec/templates/` in template path references across 4 specs
- Replace `openspec/constitution.md` → `openspec/CONSTITUTION.md` (correct casing) across 4 specs
- Replace `schema.yaml` → `WORKFLOW.md` in 2 specs
- Fix `.claude-plugin/plugin.json` → `src/.claude-plugin/plugin.json` in auto-bump requirement
- Rewrite constitution-management "config.yaml workflow rules" to "WORKFLOW.md context field" semantically

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `decision-docs`: Update `docs_language` source from `config.yaml` to `WORKFLOW.md`; fix ADR template path
- `user-docs`: Update `docs_language` source from `config.yaml` to `WORKFLOW.md`; fix capability template path
- `release-workflow`: Update `docs_language` source from `config.yaml` to `WORKFLOW.md`; fix auto-bump plugin.json path
- `constitution-management`: Rewrite config.yaml/schema.yaml references to WORKFLOW.md; fix template paths; fix constitution casing
- `interactive-discovery`: Update prerequisite check from config.yaml/schema.yaml to WORKFLOW.md/templates
- `architecture-docs`: Update `docs_language` source from `config.yaml` to `WORKFLOW.md`; fix template paths; fix constitution casing
- `task-implementation`: Fix schema.yaml reference to WORKFLOW.md
- `project-bootstrap`: Fix constitution.md casing to CONSTITUTION.md

### Removed Capabilities

None.

### Consolidation Check

N/A — no new specs proposed. All changes are modifications to existing capabilities.

## Impact

- 8 spec files modified (text corrections only)
- No behavioral changes to any skill or workflow
- No code changes — spec content only

## Scope & Boundaries

**In scope:**
- All stale references identified in GitHub Issue #79 (Gaps 1-3, 5-8)
- Semantic rewrites where simple path swaps are insufficient (constitution-management config.yaml context)

**Out of scope:**
- Gap 4 (plugin template `src/templates/workflow.md` divergence) — separate concern, not a stale reference
- workflow-contract, artifact-pipeline, project-setup specs — their references are intentional legacy/migration context
