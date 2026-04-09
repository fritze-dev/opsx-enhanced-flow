# Pre-Flight Check: Spec Frontmatter Tracking

## A. Traceability Matrix

| Capability | Spec Requirements Modified | Design Components | Traced |
|---|---|---|---|
| `spec-format` | Spec Frontmatter Metadata (tracking fields added) | Layer 1: Spec Frontmatter | Yes |
| `artifact-generation` | Fast-Forward Generation (draft status + collision detection) | `src/skills/ff/SKILL.md` | Yes |
| `quality-gates` | Preflight (dimension G: Draft Spec Validation), Post-Implementation Verification (draft gate + completion flip), Docs Drift Verification (has_decisions) | `src/skills/verify/SKILL.md`, `src/skills/preflight/SKILL.md`, `src/skills/docs-verify/SKILL.md` | Yes |
| `release-workflow` | Generate Changelog (frontmatter-based detection) | `src/skills/changelog/SKILL.md` | Yes |
| `user-docs` | Incremental Capability Documentation Generation (lastModified-based), Generate Enriched Docs (capabilities frontmatter) | `src/skills/docs/SKILL.md` | Yes |
| `workflow-contract` | Smart Template Format (template-version field), WORKFLOW.md Orchestration (template-version field) | All 11 templates + workflow.md | Yes |
| `project-setup` | Template Merge on Re-Setup (template-version comparison, CONSTITUTION.md section merge) | `src/skills/setup/SKILL.md` | Yes |
| `change-workspace` | Change Context Detection (proposal branch field), Active/Completed Detection (proposal status), Lazy Cleanup (proposal status), Create Workspace (proposal frontmatter) | `src/skills/new/SKILL.md`, `src/skills/ff/SKILL.md` | Yes |
| `artifact-pipeline` | Artifact Output Frontmatter (proposal capabilities, design has_decisions) | `src/templates/proposal.md`, `src/templates/design.md` | Yes |

**Coverage**: 9 modified specs, all traced to design components. No orphan requirements.

## B. Gap Analysis

- **Existing change migration**: The 40+ existing changes under `openspec/changes/` will not have proposal frontmatter. All skills include fallback logic. No gap.
- **Spec migration edge case**: If a spec is currently being edited by another branch when migration runs, the migration sets `status: stable` which could conflict. Mitigation: This change runs on its own branch — no parallel spec edits expected during migration.
- **Template-version bump discipline**: No automated enforcement that plugin maintainers bump `template-version`. Accepted as assumption — low risk since template changes go through the OpenSpec flow which includes review.
- **Design `has_decisions` for existing designs**: Existing design.md files in completed changes won't have `has_decisions`. Skills fall back to table scanning. No gap — fallback is the current behavior.

No blocking gaps found.

## C. Side-Effect Analysis

| System | Risk | Assessment |
|---|---|---|
| Existing specs (18 files) | Migration adds frontmatter fields — could break external tooling that parses spec files | LOW — frontmatter is standard YAML, existing fields preserved |
| Existing proposals (40+ changes) | No modification — skills fall back gracefully | NONE |
| Setup skill behavior change | WORKFLOW.md skip-if-exists replaced by merge detection — first re-setup after update will detect version mismatch | LOW — users get prompted for merge, not silently overwritten |
| Consumer projects | First `/opsx:setup` after plugin update will add `template-version` to all templates | LOW — additive change, no content modifications |
| Verify workflow | New draft gate adds a CRITICAL check — could block merges if specs aren't properly finalized | LOW — the gate fires during verify completion which already handles the flip |
| Template synchronization convention | Both `src/templates/` and `openspec/templates/` must be updated together | EXISTING — already a convention in constitution |

No high-risk side effects.

## D. Constitution Check

- **Skill immutability**: All frontmatter semantics are defined in specs and templates, not hardcoded in skills. Skills read specs for field definitions. ✓ Compliant.
- **Template synchronization**: Constitution convention requires `src/templates/` and `openspec/templates/` changes in sync. This change will update both. ✓ Compliant.
- **No ADR references in specs**: Verified — no specs reference ADRs. ✓ Compliant.
- **Constitution update needed**: The constitution's Template synchronization convention should note that `template-version` must also be synced. Minor update.

## E. Duplication & Consistency

- **Proposal `capabilities` vs body `## Capabilities`**: Intentional duplication — frontmatter is machine-readable index, body is human-readable detail. Design explicitly notes this is set once at generation, not maintained on body edits.
- **Spec `version` vs template `template-version`**: Different names, different semantics. No confusion.
- **Spec `lastModified` vs capability doc `lastUpdated`**: Different scopes — spec modification date vs doc generation date. Both needed. Consistent naming would be nice but changing existing `lastUpdated` is out of scope.
- **Active/completed detection**: Proposal `status` replaces tasks.md parsing as primary. Fallback to tasks.md for legacy changes. No contradiction.

Cross-spec consistency verified. No contradictions found.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|---|---|---|
| 1 | Plugin maintainers will remember to bump `template-version` when changing template content | design.md | Acceptable Risk — template changes go through OpenSpec flow which includes review |
| 2 | YAML frontmatter in proposal.md and design.md does not interfere with skills that read the markdown body | design.md | Acceptable Risk — standard markdown convention, widely used |
| 3 | YAML frontmatter parsing in markdown is supported by the agent reading the spec file | spec-format spec | Acceptable Risk — already true for all existing specs |

No blocking assumptions.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any spec or design artifact.

---

## Verdict: **PASS**

0 blockers, 0 warnings. All requirements traced, no gaps, no side-effect risks above LOW, no constitution violations, no cross-spec contradictions, no blocking assumptions, no review markers.
