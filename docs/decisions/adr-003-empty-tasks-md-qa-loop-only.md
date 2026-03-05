# ADR-003: Empty tasks.md (QA loop only)

## Status
Accepted (2026-03-02)

## Context
The initial-spec change was a pure documentation bootstrap that created baseline specs for all 15 existing capabilities. Since no code was being written or modified, there were no implementation tasks to track. However, the artifact pipeline requires a tasks.md file as part of its 6-stage pipeline (research, proposal, specs, design, preflight, tasks), and the apply phase is gated by tasks completion. Skipping tasks.md entirely would break the pipeline gate, while populating it with artificial tasks would misrepresent the scope of the change. The tasks.md needed to exist to satisfy the pipeline, but only contain the QA verification loop.

## Decision
Use an empty tasks.md containing only the QA loop, with no implementation tasks.

## Rationale
No code to implement — this is a documentation bootstrap. The QA loop is sufficient to satisfy the pipeline gate while accurately reflecting the scope of work.

## Alternatives Considered
- Skip tasks entirely — breaks the pipeline gate and violates the artifact pipeline requirements

## Consequences

### Positive
- Pipeline gate is satisfied without artificial implementation tasks
- Accurately represents the documentation-only nature of the change

### Negative
- No significant negative consequences identified

## References
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
