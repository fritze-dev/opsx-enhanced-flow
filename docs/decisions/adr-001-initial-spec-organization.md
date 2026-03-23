# ADR-001: Initial Spec Organization

## Status

Accepted — 2026-03-02

## Context

The opsx-enhanced-flow plugin was fully functional with 13 skills, a 6-stage artifact pipeline, and a three-layer architecture, but had no formal specifications. Without baseline specs, spec-driven feature development was impossible — changes could not be tracked as delta specs, verify could not check implementation against specs, and drift detection had no reference point. The research phase confirmed that the existing system was well-understood across all categories (scope, behavior, data model, UX, integration, edge cases, constraints, terminology, non-functional) with no open questions, making it a straightforward documentation-only bootstrap. The key design challenge was determining the right granularity for specs: too many fine-grained specs (one per skill) would create a maintenance burden, while too few coarse specs would lose traceability. The investigation identified 15 logical capabilities organized at three levels — structural (architecture, pipeline, format), operational (setup, bootstrap, generation, workspace, implementation, gates, approval, discovery, sync), and supporting (constitution, docs, roadmap) — as the optimal grouping that balanced coverage against maintainability.

## Decision

1. **Organize 15 capabilities (not one per skill)** — Groups related behavior logically rather than following the 1:1 skill mapping. For example, continue and ff are grouped under artifact-generation, and docs and changelog are grouped under docs-generation. This avoids both extremes of 19 specs (too granular) and 1 monolithic spec (untraceable).

2. **Use `/opsx:sync` for baseline creation, not programmatic archive merge** — The OpenSpec CLI's programmatic merge has format limitations including missing Purpose sections and header matching issues. Agent-driven sync via `/opsx:sync` correctly strips delta operation prefixes and produces properly formatted baselines.

3. **Use empty tasks.md (QA loop only)** — Since this is a documentation bootstrap with no code to implement, tasks.md contains only the QA verification loop. Skipping tasks entirely was rejected because it would break the pipeline gate.

## Alternatives Considered

- One spec per skill (19 specs) — too granular, high maintenance burden
- Single monolithic spec — untraceable, impossible to manage
- Direct `openspec archive` for programmatic merge — failed in a previous attempt due to format limitations
- Skip tasks.md entirely — breaks the artifact pipeline gate requirement
- Single-level capability categorization — too flat, loses organizational clarity
- Embedding spec-format rules in artifact-generation — hidden and hard to find; better as a standalone cross-cutting capability

## Consequences

### Positive

- Establishes baseline specs enabling spec-driven feature development going forward
- Provides a reference point for drift detection and verify checks
- Each spec is focused and self-contained, covering one coherent capability without cross-spec duplication
- Every skill's core behavior is covered by at least one Gherkin scenario
- Creates the `openspec/specs/` directory with 15 validated capability specs

### Negative

- 15 specs is a significant number to maintain, though each is focused and self-contained; drift detection in bootstrap re-run mode mitigates this
- Spec content may not perfectly match actual skill behavior; the verify step checks coherence, with iteration in a fix loop as mitigation
- Sync agent may produce inconsistent baseline format; all baselines must be validated after sync before committing

## References

- [Archive: initial-spec](../../openspec/changes/archive/2026-03-02-initial-spec/)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [Spec: project-bootstrap](../../openspec/specs/project-bootstrap/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [Spec: human-approval-gate](../../openspec/specs/human-approval-gate/spec.md)
- [Spec: interactive-discovery](../../openspec/specs/interactive-discovery/spec.md)
- [Spec: spec-sync](../../openspec/specs/spec-sync/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: roadmap-tracking](../../openspec/specs/roadmap-tracking/spec.md)
- [ADR-M001: Setup is model-invocable](adr-M001-init-model-invocable.md)
