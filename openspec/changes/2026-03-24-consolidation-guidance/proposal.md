## Why

The proposal stage defines the mechanic (1 capability = 1 spec file) but provides no rules for capability granularity. Without guidance on what constitutes a "capability" vs. a "feature detail", agents list every change as a separate capability — producing 115+ micro-specs instead of ~15-20 cohesive domain specs. Follow-up changes create additional new capabilities instead of modifying existing specs.

## What Changes

- Add capability granularity rules to the proposal schema instruction (what a capability IS vs. a feature detail)
- Add a mandatory consolidation check to the proposal instruction (verify overlap with existing specs before finalizing capabilities)
- Add a Consolidation Check section to the proposal template (visible, reviewable reasoning)
- Add overlap verification to the specs schema instruction (safety net before creating spec files)
- Add consolidation-awareness note to the continue skill's specs creation guideline

## Capabilities

### New Capabilities
<!-- None — this change modifies existing pipeline behavior, not a new domain. -->

### Modified Capabilities
- `artifact-pipeline`: Add capability granularity rules and consolidation check to proposal instruction; add overlap verification to specs instruction in schema.yaml
- `artifact-generation`: Add consolidation-awareness to the specs creation guideline in continue skill

### Consolidation Check
1. Existing specs reviewed: `artifact-pipeline`, `artifact-generation`, `spec-format`, `quality-gates`
2. Overlap assessment: No new capability needed. All changes modify existing pipeline instructions and skill guidelines — both clearly within the domain of `artifact-pipeline` (schema instruction ownership) and `artifact-generation` (skill delivery).
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- `openspec/schemas/opsx-enhanced/schema.yaml` — proposal instruction (lines 34-52) and specs instruction (lines 58-63) gain consolidation guidance
- `openspec/schemas/opsx-enhanced/templates/proposal.md` — new Consolidation Check section added
- `skills/continue/SKILL.md` — line 104 gains consolidation-awareness note
- Future proposals will include a Consolidation Check section showing reasoning about spec overlap

## Scope & Boundaries

**In scope:**
- Schema instruction text changes (proposal + specs artifacts)
- Proposal template addition (Consolidation Check section)
- Continue skill guideline update

**Out of scope:**
- No new pipeline stages or artifacts
- No CLI changes
- No changes to preflight (existing Section E already covers post-hoc duplication detection)
- No changes to ff skill (delegates to schema instructions via CLI)
- No changes to archived changes or baseline spec content
