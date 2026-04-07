# Pre-Flight Check: Fix Stale Spec References

## A. Traceability Matrix

- [x] Gap 1 (config.yaml refs) → 18 replacements across 6 specs → decision-docs, user-docs, release-workflow, constitution-management, interactive-discovery, architecture-docs
- [x] Gap 2 (schemas/ template paths) → 14 replacements across 4 specs → decision-docs, user-docs, constitution-management, architecture-docs
- [x] Gap 3 (constitution.md casing) → 20 replacements across 4 specs → constitution-management, architecture-docs, project-bootstrap, release-workflow
- [x] Gap 5 (docs_language source) → covered by Gap 1 replacements
- [x] Gap 6 (interactive-discovery prerequisite) → covered by Gap 1 + Gap 2 replacements
- [x] Gap 7 (task-implementation schema.yaml) → 1 replacement → task-implementation
- [x] Gap 8 (plugin.json path) → 3 replacements → release-workflow

## B. Gap Analysis

No gaps found. All 8 gaps from Issue #79 are addressed (Gap 4 explicitly out of scope per proposal — separate concern).

## C. Side-Effect Analysis

- **workflow-contract/spec.md**: Contains intentional config.yaml/schema.yaml references describing the replacement — must NOT be changed. Verified: 5 references, all in historical/migration context.
- **artifact-pipeline/spec.md**: Contains 1 intentional config.yaml reference in user story motivation text — must NOT be changed.
- **project-setup/spec.md**: Contains intentional legacy migration references (detecting old layout) — must NOT be changed. Exception: line 177 edge case mentions `openspec/constitution.md` (lowercase) alongside CONSTITUTION.md in migration context — this is correct as-is (describes the migration FROM lowercase TO caps).

No regression risks — all changes are spec prose corrections with no behavioral impact.

## D. Constitution Check

No constitution update needed. This change corrects spec text only.

## E. Duplication & Consistency

- The `docs_language` source change (config.yaml → WORKFLOW.md) applies consistently across all 4 docs-related specs (decision-docs, user-docs, release-workflow, architecture-docs).
- The constitution path casing change applies consistently to all non-migration specs.
- No contradictions between specs after the changes.

## F. Assumption Audit

| Assumption | Source | Rating |
|------------|--------|--------|
| grep coverage — all stale references identified | design.md | Acceptable Risk — grep search was exhaustive across all spec files; post-edit verification will catch any misses |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts for this change.

**Verdict: PASS**
