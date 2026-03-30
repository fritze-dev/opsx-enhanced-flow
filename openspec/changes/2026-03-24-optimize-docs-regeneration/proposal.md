## Why

After `/opsx:archive`, the docs skill scans all 18 capabilities against all 19+ archives to detect which docs need regeneration — even though the just-archived change already tells us exactly which capabilities were affected. This makes the post-archive workflow unnecessarily slow.

## What Changes

- Extend `/opsx:docs` to accept multiple capability names (comma-separated), so the post-archive workflow can pass exactly the affected capabilities
- Multi-capability mode skips the archive date scan and always regenerates the listed capabilities (same behavior as existing single-capability mode)
- No argument = full incremental scan (existing behavior preserved)

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `user-docs`: Extend Incremental Capability Documentation Generation to support multi-capability argument mode

### Consolidation Check
1. Existing specs reviewed: `user-docs`, `artifact-generation`, `decision-docs`, `architecture-docs`
2. Overlap assessment: This is clearly within `user-docs` — it owns the incremental generation requirement and the docs skill behavior. No overlap with other specs.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `skills/docs/SKILL.md` — Input section and Step 1 change detection logic
- `openspec/specs/user-docs/spec.md` — Incremental Capability Documentation Generation requirement
- Post-archive workflow callers can pass affected capabilities directly

## Scope & Boundaries

**In scope:**
- Multi-capability argument for `/opsx:docs`
- Skip archive date scan when capabilities are explicitly listed

**Out of scope:**
- No changes to ADR or README detection logic
- No changes to archive skill (it already knows affected capabilities)
- No automatic change-name-to-capabilities resolution
