# ADR-017: Consolidation Guidance for Proposal/Spec Creation

## Status

Accepted (2026-03-24)

## Context

After extended use of the OpenSpec workflow on a real-world enterprise project, severe spec fragmentation was observed: 115+ micro-specs averaging 68 lines instead of the expected 15-20 cohesive domain specs at 250-350 lines each. Many specs covered single UI details like "pagination always visible" or "clickable table rows" -- things that clearly belong as requirements within a broader domain spec, not standalone specs.

The root cause was traced to the proposal stage. The schema instruction defined the mechanic (1 capability = 1 spec file) but provided no rules for capability granularity -- no definition of what distinguishes a "capability" from a "feature detail", no guidance on when to extend an existing capability versus creating a new one, and no consolidation check against existing baseline specs. The existing preflight quality gate (Section E: Duplication & Consistency) catches overlap post-hoc, but by that point fragmentation is already baked in.

Three approaches were considered: (A) text-only instruction and template changes at the proposal/specs stages, (B) adding a new pipeline stage for consolidation checking, and (C) relying solely on the existing preflight check. Approach B was rejected as over-engineered for what is fundamentally a guidance problem, and Approach C was rejected because it fires too late to prevent fragmentation.

## Decision

1. **Text-only instruction changes** -- addresses root cause at lowest complexity; consistent with the existing pattern of schema instructions guiding agent behavior
2. **Three-layer defense (instruction + template + skill)** -- defense in depth reduces agent compliance risk; the template section creates a reviewable artifact that makes consolidation reasoning visible
3. **Consolidation Check as a template section, not a separate artifact** -- keeps it lightweight and part of the proposal without adding pipeline complexity or breaking pipeline symmetry
4. **Heuristics (3-8 requirements, 250-350 lines, shared actor/trigger/data)** -- provides concrete guidance without being rigid; consistent with ADR-001's original granularity decision that chose 15 capabilities over 19 (one-per-skill)

## Alternatives Considered

- **New pipeline stage for consolidation checking**: Rejected as over-engineered -- would require CLI changes and a new artifact type for what is fundamentally a text-instruction problem
- **CLI validation for capability overlap**: Rejected -- requires code changes and does not address the conceptual gap in what a "capability" means
- **Single-layer instruction only (no template section)**: Rejected -- higher risk of agent skipping the check with no visible artifact for human review
- **Separate consolidation artifact**: Rejected -- breaks pipeline symmetry and adds unnecessary complexity
- **No heuristics (vague guidance only)**: Rejected -- too vague to be actionable
- **Strict rules instead of heuristics**: Rejected -- too rigid for the diversity of projects using OpenSpec

## Consequences

### Positive

- Consolidation pressure is shifted left to the earliest possible point (proposal stage), preventing fragmentation before it happens
- The Consolidation Check template section creates a visible, reviewable artifact that documents the agent's reasoning about capability boundaries
- The three-layer defense (proposal instruction, proposal template, specs instruction) provides multiple opportunities to catch overlap
- Heuristics are concrete enough to be actionable while flexible enough for diverse project structures
- No pipeline changes, no CLI changes, no new artifacts -- minimal complexity added to the system

### Negative

- Instruction-based guidance depends on AI agent compliance -- there is no programmatic enforcement; mitigated by the template section making reasoning visible for human review
- Heuristics could cause over-consolidation of genuinely distinct capabilities -- mitigated by upper-bound guidance and explicit edge cases allowing conscious splitting
- Old proposals created before this change have no Consolidation Check section -- the continue skill falls back gracefully, relying on the specs instruction's overlap verification

## References

- [Change: consolidation-guidance](../../openspec/changes/2026-03-24-consolidation-guidance/)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [ADR-001: Initial Spec Organization](adr-001-initial-spec-organization.md)
