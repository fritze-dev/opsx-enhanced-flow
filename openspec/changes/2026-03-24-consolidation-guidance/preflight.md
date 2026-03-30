# Pre-Flight Check: Consolidation Guidance

## A. Traceability Matrix

- [x] Capability Granularity Guidance → Scenario: Guidance defines capability vs feature detail → `schema.yaml` proposal instruction
- [x] Capability Granularity Guidance → Scenario: Agent consolidates related feature details → `schema.yaml` proposal instruction
- [x] Mandatory Consolidation Check → Scenario: Consolidation check is present in proposal instruction → `schema.yaml` proposal instruction
- [x] Mandatory Consolidation Check → Scenario: Agent identifies overlap with existing spec → `schema.yaml` proposal instruction
- [x] Mandatory Consolidation Check → Scenario: Agent merges overlapping new capabilities → `schema.yaml` proposal instruction
- [x] Proposal Template Consolidation Check Section → Scenario: Proposal template includes Consolidation Check → `templates/proposal.md`
- [x] Proposal Template Consolidation Check Section → Scenario: Agent fills Consolidation Check for new capabilities → `templates/proposal.md`
- [x] Proposal Template Consolidation Check Section → Scenario: Consolidation Check for modification-only proposals → `templates/proposal.md`
- [x] Specs Overlap Verification → Scenario: Overlap verification is present in specs instruction → `schema.yaml` specs instruction
- [x] Specs Overlap Verification → Scenario: Agent catches overlap during specs creation → `schema.yaml` specs instruction
- [x] Step-by-Step Generation (MODIFIED) → Scenario: Continue verifies consolidation before creating specs → `skills/continue/SKILL.md`

## B. Gap Analysis

No gaps identified. All requirements map to specific file locations and have clear acceptance criteria (PASS/FAIL metrics in design). Edge cases are covered:
- Greenfield projects (no existing specs)
- Over-large existing specs (conscious splitting allowed)
- Genuinely distinct capabilities (consolidation check confirms rather than force-merges)
- Legacy proposals without Consolidation Check section (graceful fallback)

## C. Side-Effect Analysis

- **Existing proposals**: No impact — changes apply to future proposals only (template and instruction changes)
- **Archived changes**: No impact — archived proposals are immutable
- **ff skill**: No direct change needed — delegates to schema instructions via CLI, automatically picks up updated instructions
- **Preflight Section E**: No conflict — existing duplication check remains as post-hoc safety net; new changes add shift-left prevention
- **Schema validation**: No risk — only `instruction` text fields and template content are modified, not schema structure

## D. Constitution Check

No constitution updates needed. This change adds instruction-level guidance within the schema, consistent with the existing architecture rule: "Schema owns workflow rules" (artifact-pipeline spec, Requirement: Schema Owns Workflow Rules). No new patterns, conventions, or architectural decisions are introduced.

## E. Duplication & Consistency

- No overlapping stories between the two delta specs (artifact-pipeline covers schema instructions + template; artifact-generation covers skill guideline)
- No contradictions between specs
- Consistent with existing specs:
  - `artifact-pipeline` Requirement: Schema Owns Workflow Rules — new instructions added to schema instruction fields, not elsewhere
  - `artifact-generation` Requirement: Unified Skill Delivery — continue skill remains a thin CLI wrapper with supplementary guidelines
  - `quality-gates` — preflight Section E (existing) complements the new shift-left consolidation check; no duplication

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | Agent compliance with instruction-based guidance is sufficient. The Consolidation Check template section provides the primary enforcement mechanism by making reasoning visible. | artifact-pipeline delta spec, design.md | Acceptable Risk — consistent with how all schema instructions work; template section adds reviewability |
| 2 | The continue skill's Artifact Creation Guidelines are supplementary to the schema instructions. Both are read by the agent when creating artifacts. | artifact-generation delta spec | Acceptable Risk — this is already the established pattern for all artifact types |

---

**Verdict: PASS**

All requirements are traceable, no gaps, no side effects, no duplication, no constitution changes needed, and both assumptions are acceptable risks consistent with existing patterns.
