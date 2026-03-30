## Why

The first real workflow run revealed friction points that break flow and cause errors — workflow rules were scattered across config.yaml, constitution, and schema with heavy redundancy, there was no convention for capturing friction systematically, and the Development & Testing docs were insufficient. Fixing these now establishes clean rule ownership across the three-layer architecture.

## What Changes

- **Simplify config.yaml to bootstrap-only:** Remove all workflow rules from config.yaml. Reduce to schema reference + constitution pointer. Workflow rules move to their authoritative source (schema or constitution).
- **Clean up constitution:** Remove 12 redundancies where constitution duplicated schema-defined rules. Keep only project-specific content (tech stack, architecture, paths, conventions, constraints).
- **Add workflow rules to schema:** Move DoD-emergent rule into `tasks.instruction` and post-apply workflow sequence into `apply.instruction` — these are schema-level concerns, not project-specific.
- **Add friction tracking convention:** New convention in constitution requiring workflow friction to be captured as GitHub Issues with a `friction` label.
- **Update README documentation:** Expand the Development & Testing section.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `constitution-management`: Constitution cleaned up (12 redundancies removed) + friction tracking convention added.
- `artifact-pipeline`: config.yaml simplified to bootstrap-only. Workflow rules moved to schema instructions.
- `project-setup`: Init skill generates minimal config template instead of copying plugin's own config.

## Impact

- `openspec/config.yaml` — Reduced from 9 global rules to a single constitution pointer.
- `openspec/constitution.md` — 12 redundancies removed, friction convention added.
- `openspec/schemas/opsx-enhanced/schema.yaml` — DoD rule added to tasks.instruction, post-apply workflow added to apply.instruction.
- `README.md` — Development & Testing section updated.
- `.claude-plugin/plugin.json` — Version bump from `1.0.1` to `1.0.2`.

## Scope & Boundaries

**In scope:**
- Rule ownership audit across all three layers (Issue #1)
- Constitution redundancy cleanup (Issue #1)
- Friction tracking convention (FP #8)
- README dev docs (FP #4)
- Schema instruction enhancements

**Out of scope:**
- Already-fixed friction points (FP #1, #2, #3, #6)
- New skills (no `/opsx:status`)
- Changes to the OpenSpec CLI itself
- Skill modifications — project-specific behavior stays in constitution
