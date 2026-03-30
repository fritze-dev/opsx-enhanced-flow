# Research: Consolidation Guidance for Proposal/Spec Creation

## 1. Current State

The spec fragmentation issue originates in 4 files:

- **`openspec/schemas/opsx-enhanced/schema.yaml`** (lines 34-52): The proposal `instruction` defines the mechanic (1 capability = 1 spec file) but provides no rules for capability granularity. The instruction says "Research existing specs before filling this in" but gives no criteria for what constitutes a proper capability boundary vs. a feature detail.

- **`openspec/schemas/opsx-enhanced/schema.yaml`** (lines 58-115): The specs `instruction` says "Create one spec file per capability listed in the proposal" with no overlap verification against existing baseline specs.

- **`openspec/schemas/opsx-enhanced/templates/proposal.md`**: A bare scaffold with New Capabilities / Modified Capabilities sections but no consolidation check section that forces the agent to reason about overlap.

- **`skills/continue/SKILL.md`** (line 104): The specs creation guideline in the Artifact Creation Guidelines section has no consolidation-awareness note.

The existing preflight quality gate (Section E: Duplication & Consistency) catches overlap but fires too late — after specs are already written. The fragmentation is already baked in by the time preflight runs.

**Baseline specs affected:**
- `artifact-pipeline` — owns schema instruction rules (proposal + specs instructions)
- `artifact-generation` — owns continue/ff skill delivery

**ADR-001** documented the original granularity decision (15 capabilities over 19 one-per-skill), establishing the intellectual foundation for consolidation heuristics.

## 2. External Research

No external dependencies or APIs involved. This is purely an instruction/template text change within the OpenSpec framework.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A. Schema instruction + template changes only | Minimal diff, addresses root cause directly at proposal stage | No runtime enforcement (agent compliance only) |
| B. Add a new pipeline stage (consolidation-check) | Automated gate, hard to skip | Over-engineered for a text-instruction problem; requires CLI changes |
| C. Shift consolidation to preflight only | Already partially exists | Too late — fragmentation already happened |

**Selected: Approach A** — schema instruction + template changes. Three-layer defense: proposal instruction (primary gate), proposal template (visibility), specs instruction (safety net).

## 4. Risks & Constraints

- **Agent compliance**: Instruction-based guidance depends on the AI agent following it. The Consolidation Check section in the template mitigates this by creating a visible, reviewable artifact.
- **Over-consolidation risk**: Guidance could cause merging of distinct capabilities into bloated specs. Heuristics (3-8 requirements, 250-350 lines) provide upper bounds.
- **Template compatibility**: Adding a new section to proposal.md template affects future proposals but not archived ones.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 4 files, text-only changes to instructions and templates |
| Behavior | Clear | Adds consolidation check steps to proposal and specs creation |
| Data Model | Clear | No data model changes — instruction text only |
| UX | Clear | Adds Consolidation Check section to proposal template |
| Integration | Clear | No CLI changes; schema instructions read by existing skills |
| Edge Cases | Clear | Over-consolidation handled by upper-bound heuristics |
| Constraints | Clear | Must not break existing pipeline flow or archived changes |
| Terminology | Clear | "Capability" vs "feature detail" distinction is new but intuitive |
| Non-Functional | Clear | No performance or scalability concerns |

All categories Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach A: instruction + template changes | Addresses root cause directly; minimal changes; consistent with existing text-instruction pattern | B (new pipeline stage) rejected as over-engineered; C (preflight-only) rejected as too late |
| 2 | Modified Capabilities: `artifact-pipeline`, `artifact-generation` | Schema instructions owned by artifact-pipeline; skill guidelines owned by artifact-generation | New capability rejected — this is clearly modifications to existing pipeline behavior |
| 3 | Three-layer consolidation defense | Proposal instruction as primary gate, template section for visibility, specs instruction as safety net | Single-point-of-change rejected — defense in depth reduces agent compliance risk |
