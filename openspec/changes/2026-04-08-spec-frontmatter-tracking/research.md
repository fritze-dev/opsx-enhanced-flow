# Research: Spec Frontmatter Tracking

## 1. Current State

### Spec Frontmatter (18 specs)
All specs under `openspec/specs/*/spec.md` use identical frontmatter with two optional fields:
```yaml
---
order: 3
category: change-workflow
---
```
No status, version, modification date, or change-reference fields exist. The spec template (`src/templates/specs/spec.md`) documents these as optional fields for documentation ordering only.

### Change Tracking After ADR-037
ADR-037 eliminated delta-specs, sync, and archive. Current tracking mechanisms:
- **Completion**: Determined by `tasks.md` checkbox status — not spec metadata
- **Temporal ordering**: Date prefix in change directory name (`YYYY-MM-DD-<name>`)
- **Audit trail**: Git history only
- **No collision detection**: Two changes can silently edit the same spec with no warning

### Proposal-Based Spec Detection (Fragile)
Four skills parse the proposal's `## Capabilities` markdown section to identify affected specs:

| Skill | Detection Method | Fallback |
|-------|-----------------|----------|
| **verify** | Parse `### New/Modified Capabilities` headers | None — breaks silently |
| **changelog** | Parse `### New/Modified Capabilities` headers | Falls back to `What Changes` / `Why` sections |
| **docs** | Parse `### New/Modified Capabilities` headers | Regenerates ALL docs if unparseable |
| **preflight** | Parse `### New/Modified Capabilities` headers | None — breaks silently |

The docs skill already uses `lastUpdated` in generated capability doc frontmatter for incremental detection, but compares against directory name date prefix — not against spec-level metadata.

### Affected Files
- **Spec template**: `src/templates/specs/spec.md` (consumer) + `openspec/templates/specs/spec.md` (project)
- **FF skill**: `src/skills/ff/SKILL.md` — creates/edits specs during artifact pipeline
- **Verify skill**: `src/skills/verify/SKILL.md` — validates implementation against specs
- **Changelog skill**: `src/skills/changelog/SKILL.md` — generates release notes
- **Docs skill**: `src/skills/docs/SKILL.md` — generates capability docs, ADRs, README
- **Preflight skill**: `src/skills/preflight/SKILL.md` — quality gate before tasks

## 2. External Research

No external dependencies. This is an internal metadata enhancement to YAML frontmatter in markdown files. The YAML frontmatter pattern is already established in WORKFLOW.md, Smart Templates, and spec files.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Spec-level frontmatter** (status/version/lastModified/change in each spec) | Direct per-spec tracking; enables collision detection; machine-readable; aligns with existing frontmatter pattern | Every skill touching specs must maintain fields; version semantics need defining; 18 specs to migrate |
| **B: Proposal frontmatter only** (affected_specs list in proposal YAML) | Simpler — one file per change, not per spec; no migration | No collision detection; no incremental doc detection at spec level; still requires proposal parsing improvement |
| **C: External tracking file** (e.g., `openspec/spec-status.yaml`) | Centralized; easy to query | New file type; merge conflicts; diverges from established per-file frontmatter pattern |

**Recommendation**: Approach A — spec-level frontmatter. It solves all stated goals (collision detection, incremental docs, changelog detection, preflight traceability) and aligns with the existing frontmatter conventions. Approach B could complement but doesn't replace it.

## 4. Risks & Constraints

- **Skill immutability** (Constitution): Skills are generic shared code. The frontmatter fields and their semantics must be defined in templates and WORKFLOW.md, with skills reading them at runtime — not hardcoded into skill logic.
- **Migration**: 18 existing specs need `status: stable`, `version: 1`, and `lastModified` fields added. This is a one-time bulk edit — can be done during the specs stage of this change.
- **Stale draft markers**: If a change is abandoned mid-pipeline, specs may remain `status: draft`. Need a recovery path (manual or via bootstrap/preflight detection).
- **Version semantics**: What constitutes a version bump? Each change that modifies a spec should bump version by 1. This is simple and unambiguous.
- **Template sync**: Both `src/templates/specs/spec.md` (consumer) and `openspec/templates/specs/spec.md` (project) must be updated.
- **Backward compatibility**: Existing consumers without these fields must not break. Fields should be treated as optional — skills should handle their absence gracefully.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Four fields: status, change, version, lastModified |
| Behavior | Clear | Draft/stable lifecycle, version bump on modification, collision detection |
| Data Model | Clear | YAML frontmatter fields in spec files |
| UX | Clear | Transparent to users — managed by skills automatically |
| Integration | Clear | Six skills affected, all identified |
| Edge Cases | Clear | Resolved: verify gate blocks draft-to-main; lastModified uses actual edit date |
| Constraints | Clear | Skill immutability, backward compatibility |
| Terminology | Clear | Reuses existing YAML frontmatter conventions |
| Non-Functional | Clear | No performance concerns — file-level metadata reads |

## 6. Open Questions

| # | Question | Category | Impact |
|---|----------|----------|--------|
| 1 | ~~Should `lastModified` use the change directory date prefix or the actual date of the spec edit?~~ | Edge Cases | Resolved — see Decision 1 |
| 2 | ~~How should abandoned drafts be detected and cleaned up?~~ | Edge Cases | Resolved — see Decision 2 |

## 7. Decisions
<!-- Filled after user feedback. -->

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | `lastModified` is always the actual edit date, not the change directory date prefix | Accuracy — multi-day changes would have stale dates otherwise. Directory date is creation context, not modification context. | Use directory date prefix (simpler but less accurate); add separate `createdDate` field (deferred — can add later if needed) |
| 2 | No cleanup automatism for abandoned drafts. Enforce via verify gate: `status: draft` must not reach main. Verify flips `draft → stable` during completion. | Simpler and more robust than recovery mechanisms. Draft status only exists in PR branches. Merge gate is a hard enforcement, not soft guidance. | Preflight warning for stale drafts (soft, could be ignored); bootstrap recovery mode (complex, rarely needed) |
