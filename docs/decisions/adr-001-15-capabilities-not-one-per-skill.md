# ADR-001: 15 capabilities (not one per skill)

## Status
Accepted (2026-03-02)

## Context
The opsx-enhanced-flow plugin needed formal specifications to enable spec-driven feature development, but the right granularity for organizing capabilities into specs was unclear. The plugin has 13 skills across three categories (workflow, governance, documentation) and a three-layer architecture (Constitution, Schema, Skills). Research identified three granularity levels for organizing capabilities: per-skill (19+ specs, too granular), monolithic (1 spec, untraceable), or logical capability grouping. The key constraint was that specs must be self-contained, each covering one coherent capability without cross-spec duplication, while still being maintainable as the project evolves. Each capability was mapped at structural, operational, or supporting levels to ensure comprehensive coverage without gaps.

## Decision
Organize the project into 15 capabilities (not one per skill), grouping related behavior logically at three levels: structural (three-layer-architecture, artifact-pipeline, spec-format), operational (project-setup, project-bootstrap, artifact-generation, change-workspace, task-implementation, quality-gates, human-approval-gate, interactive-discovery, spec-sync), and supporting (constitution-management, docs-generation, roadmap-tracking).

## Rationale
Groups related behavior logically. For example, continue and ff are grouped under artifact-generation, and docs and changelog under docs-generation. This approach ensures comprehensive coverage without gaps or overlaps while keeping each spec focused and self-contained.

## Alternatives Considered
- One spec per skill (19 specs) — too granular, creates excessive maintenance burden
- Monolithic single spec — untraceable, impossible to reason about individual capabilities

## Consequences

### Positive
- Each spec covers one coherent capability with clear boundaries
- Related behaviors (e.g., continue/ff) are grouped together, reducing duplication
- Drift detection works at the capability level, which matches how users think about features

### Negative
- 15 specs is a significant number to maintain, though each is focused and self-contained
- Spec content may not perfectly match actual skill behavior initially; the verify step mitigates this

## References
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
