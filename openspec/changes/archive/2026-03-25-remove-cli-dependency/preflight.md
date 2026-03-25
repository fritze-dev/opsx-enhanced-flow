# Pre-Flight Check: Remove OpenSpec CLI Dependency

## A. Traceability Matrix

- [x] project-setup / Install OpenSpec and Schema → Scenarios: First-time init, Idempotent re-init, No duplicate skills, Config generated, Config preserved, Config docs_language → Components: `skills/setup/SKILL.md`
- [x] project-setup / Schema Validation → Scenarios: Successful validation, Partial failure → Components: `skills/setup/SKILL.md`
- [x] project-setup / CLI Prerequisite Check (REMOVED) → N/A → Components: `skills/setup/SKILL.md`
- [x] three-layer-architecture / Schema Layer → Scenarios: 6-stage pipeline, Template+instruction, Apply gate → Components: `openspec/schemas/opsx-enhanced/schema.yaml`
- [x] three-layer-architecture / Layer Separation → Scenarios: Schema change, Constitution update, Skill update → Components: all skills, schema.yaml, constitution.md
- [x] artifact-pipeline / Artifact Dependencies → Scenarios: Check passes, Check fails, Schema declares deps, Status from file existence → Components: all generation skills (new, continue, ff)
- [x] artifact-generation / Step-by-Step Generation → Scenarios: Next artifact, All complete, Dependency gating, Auto-continue, Design checkpoint, Consolidation → Components: `skills/continue/SKILL.md`
- [x] artifact-generation / Fast-Forward Generation → Scenarios: Full forward, Partial, Complete, Order, Design checkpoint, Checkpoint skip, Preflight warnings → Components: `skills/ff/SKILL.md`
- [x] artifact-generation / Unified Skill Delivery → Scenarios: Continue reads schema, FF reads schema, Model-invocable → Components: `skills/continue/SKILL.md`, `skills/ff/SKILL.md`

## B. Gap Analysis

No gaps identified. Each CLI command has a direct file-based replacement:
- Schema resolution → config.yaml + derived path
- Status → file existence checks against schema's `generates` fields
- Instructions → schema.yaml `instruction` field + template reads
- Change creation → `mkdir -p`
- Change listing → directory listing
- Archiving → `mv` command
- Validation → file readability check

## C. Side-Effect Analysis

- **Consumer projects**: No migration needed. Schema files already exist locally after setup. CLI is only used at runtime by skills, never directly by consumers.
- **Archived changes**: `.openspec.yaml` metadata files from CLI remain inert. No cleanup needed.
- **devcontainer**: Removing Node.js feature may affect projects that use the devcontainer for non-plugin purposes. Low risk — the devcontainer is specific to this plugin project.
- **settings.local.json**: Removing CLI permissions is a development-only change. No consumer impact.

## D. Constitution Check

Constitution needs updating:
- Remove CLI from Tech Stack (lines 8-9, 11)
- Update architecture rule about skills depending on schema "via CLI" (line 16)

These updates are included in the implementation plan.

## E. Duplication & Consistency

- All 4 delta specs consistently describe the new pattern (direct file reads instead of CLI).
- The "Unified Skill Delivery" requirement was updated consistently across artifact-generation spec.
- No contradictions between delta specs and remaining baseline specs.
- Terminology is consistent: "read schema.yaml directly" used throughout.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | Claude can reliably read and interpret YAML via Read tool | design.md | Acceptable Risk — extensively verified by existing usage |
| 2 | No consumer runs `openspec status` manually | design.md | Acceptable Risk — CLI is wrapper for skills, not end-user tool |
| 3 | Skill discovery via `skills/*/SKILL.md` scanning | three-layer-architecture spec | Acceptable Risk — existing assumption, unchanged by this change |
| 4 | Config enforcement for constitution loading | three-layer-architecture spec | Acceptable Risk — existing assumption, unchanged by this change |
| 5 | File-existence-based completion | artifact-pipeline spec | Acceptable Risk — same logic CLI used internally |
| 6 | Claude YAML comprehension for skills | artifact-generation spec | Acceptable Risk — same as #1 |

All assumptions rated as **Acceptable Risk**. No blocking or needs-clarification items.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifact.

---

**Verdict: PASS**

No blocking issues. No warnings. All requirements traced, no gaps, no contradictions, all assumptions acceptable.
