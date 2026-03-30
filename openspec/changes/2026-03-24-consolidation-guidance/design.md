# Technical Design: Consolidation Guidance

## Context

The proposal and specs stages in the OpenSpec pipeline lack guidance on capability granularity, leading to spec fragmentation. This change adds text-only instruction and template modifications to shift consolidation pressure earlier in the pipeline. No code changes, no CLI changes, no new pipeline stages.

Four files affected, all text/instruction changes:
1. `openspec/schemas/opsx-enhanced/schema.yaml` — proposal instruction + specs instruction
2. `openspec/schemas/opsx-enhanced/templates/proposal.md` — new template section
3. `skills/continue/SKILL.md` — one-line guideline update

## Architecture & Components

**Schema instruction layer** (primary):
- `schema.yaml` proposal instruction gains: capability granularity rules + mandatory consolidation check steps
- `schema.yaml` specs instruction gains: overlap verification step before file creation

**Template layer** (visibility):
- `proposal.md` template gains: `### Consolidation Check` section between Modified Capabilities and Impact

**Skill layer** (reinforcement):
- `continue/SKILL.md` specs guideline gains: one sentence about verifying consolidation check

All three layers are read by the AI agent during artifact creation. The schema instruction is the primary control; the template forces visible reasoning; the skill guideline reinforces at execution time.

## Goals & Success Metrics

- PASS/FAIL: The proposal instruction in schema.yaml contains capability granularity rules (capability vs feature detail definition, merge heuristic, minimum scope heuristic)
- PASS/FAIL: The proposal instruction in schema.yaml contains a mandatory consolidation check with 4 steps
- PASS/FAIL: The proposal template contains a `### Consolidation Check` section with instructions for documenting overlap reasoning
- PASS/FAIL: The specs instruction in schema.yaml contains an overlap verification step before "Create one spec file per capability"
- PASS/FAIL: The continue skill's specs guideline mentions consolidation check verification

## Non-Goals

- No runtime enforcement or CLI validation changes
- No changes to preflight quality gate (existing Section E is sufficient post-hoc)
- No changes to ff skill (delegates to schema instructions)
- No changes to archived changes or baseline spec structure
- No migration of existing fragmented projects

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Text-only instruction changes | Addresses root cause at lowest complexity; consistent with existing pattern of schema instructions guiding agent behavior | New pipeline stage (over-engineered), CLI validation (requires code changes) |
| Three-layer defense (instruction + template + skill) | Defense in depth reduces agent compliance risk; template section creates reviewable artifact | Single-layer instruction only (higher risk of agent skipping) |
| Consolidation Check as template section, not separate artifact | Keeps it lightweight and part of the proposal; doesn't add pipeline complexity | Separate consolidation artifact (over-engineered, breaks pipeline symmetry) |
| Heuristics (3-8 requirements, 250-350 lines, shared actor/trigger/data) | Provides concrete guidance without being rigid; consistent with ADR-001 granularity decision | No heuristics (too vague), strict rules (too rigid for diverse projects) |

## Risks & Trade-offs

- **Agent compliance**: Instruction-based guidance depends on AI following it → Mitigated by the Consolidation Check template section which creates a visible, reviewable artifact
- **Over-consolidation**: Guidance could cause merging of genuinely distinct capabilities → Mitigated by upper-bound heuristics and the edge case allowing conscious splitting
- **Existing proposal compatibility**: Old proposals without Consolidation Check section → Continue skill falls back gracefully (documented in edge case)

## Open Questions

No open questions.

## Assumptions

<!-- ASSUMPTION: Agent compliance with instruction-based guidance is sufficient for consolidation enforcement. The Consolidation Check template section provides the primary enforcement mechanism by making reasoning visible. -->
No further assumptions beyond those marked above.
