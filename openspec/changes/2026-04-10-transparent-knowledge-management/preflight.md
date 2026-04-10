# Pre-Flight Check: Transparent Project Knowledge Management

## A. Traceability Matrix

- [x] CLAUDE.md Bootstrap → Scenario: CLAUDE.md generated on fresh init, CLAUDE.md skipped when already exists, CLAUDE.md includes project-specific rules → `src/templates/claude.md`, `openspec/WORKFLOW.md` (init instruction), `src/templates/workflow.md`
- [x] Install OpenSpec Workflow (updated) → Scenario: First-time project initialization → `CLAUDE.md`, `openspec/WORKFLOW.md`, `src/templates/workflow.md`
- [x] Knowledge transparency convention → Constitution Update requirement → `openspec/CONSTITUTION.md`
- [x] Knowledge management directive → ADR-039 scoping rule → `CLAUDE.md`

## B. Gap Analysis

No gaps identified. The change is purely additive:
- CLAUDE.md gets a new section (existing section preserved)
- CONSTITUTION.md gets a new convention bullet (existing conventions preserved)
- New template file follows established pattern
- Init instruction gets a minor addition

## C. Side-Effect Analysis

- [x] **Init behavior**: Adding CLAUDE.md generation to init's Fresh mode is additive — constitution generation is unchanged. Idempotent (skips if CLAUDE.md exists).
- [x] **Template sync**: `src/templates/workflow.md` must be synced per the template synchronization convention. No risk of consumer template drift since this is a new addition.
- [x] **Existing consumers**: Consumer projects that already have CLAUDE.md will not be affected (init skips existing files).

## D. Constitution Check

- [x] Constitution gains the `Knowledge transparency` convention. No other constitutional changes needed — no new tech, no new architecture patterns.

## E. Duplication & Consistency

- [x] The CLAUDE.md directive and the constitution convention intentionally express the same principle in two different scopes (agent instruction vs. project rule), following ADR-039's scoping model. Not duplication — complementary placement.
- [x] No contradictions with existing specs or conventions.

## F. Assumption Audit

| Source | Assumption | Rating |
|--------|-----------|--------|
| project-init/spec.md | Agent compliance sufficient (convention-based enforcement) | Acceptable Risk — established project model (ADR-004, ADR-006, ADR-015) |
| design.md | Agent compliance sufficient | Acceptable Risk — same as above |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in spec or design artifacts.

---

**Verdict: PASS**
