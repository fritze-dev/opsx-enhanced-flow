# ADR-018: Standard Tasks Two-Layer Design

## Status

Accepted (2026-03-24)

## Context

Post-implementation workflow steps (archive, changelog, docs, push, plugin update) were defined as prose text in the constitution's Conventions section. This meant they were not tracked as checkboxes, could be forgotten in long sessions, and left no audit trail of whether all steps had actually been performed. Three approaches were evaluated: defining all steps in the constitution (project-specific, flexible, but redundant across projects), hardcoding in the schema (universal but inflexible), or a two-layer approach combining schema-level universal steps with constitution-level project-specific extras. The two-layer approach was chosen because it provides a consistent baseline for all opsx-enhanced projects while allowing each project to extend the steps. A key constraint was the skill immutability rule — skills must not be modified for project-specific behavior, so all changes had to be at the constitution and schema level.

## Decision

1. **Two-layer: schema (universal) + constitution (extras)** — universal steps are available to all projects through the tasks template; project-specific extras stay flexible through the constitution's `## Standard Tasks` section; no CLI changes required
2. **Literal checkbox format** — the template provides universal steps and constitution extras are copied verbatim, eliminating ambiguity in how the agent formats them
3. **Apply skips via instruction** — consistent with existing soft enforcement patterns like baseline spec exclusion
4. **Standard tasks in progress totals** — reflects the full workflow state; the archive incomplete-task warning serves as the safety net against forgotten steps
5. **Template section with universal steps** — makes the section discoverable and gives the agent a clear structural anchor during task generation

## Alternatives Considered

- All steps in constitution only (redundant across projects, every project must define the same universal steps)
- All steps in schema only (no project-specific steps possible)
- Description format requiring agent interpretation (ambiguous, agent may reformat)
- Hardcoded section parsing in skill (violates skill immutability rule)
- Separate progress counting for standard vs implementation tasks (adds complexity for minimal benefit)
- Dynamic-only insertion without template guidance (less discoverable)

## Consequences

### Positive

- Every opsx-enhanced project automatically gets trackable post-implementation steps without any setup
- Projects can customize by adding extras in their constitution
- No skill modifications needed — respects the three-layer architecture
- Archive's existing incomplete-task warning naturally catches forgotten standard tasks
- Post-implementation steps are now auditable — each archived tasks.md records whether all steps were completed

### Negative

- Soft enforcement only — the apply instruction tells the agent to skip standard tasks, but there is no hard gate preventing execution. This is consistent with how all other enforcement works in the system.
- Progress counts include standard tasks, so after apply completes users see e.g. "5/9 complete" instead of "5/5 complete". This was a deliberate choice to reflect the full workflow state.

## References

- [Change: standard-tasks](../../openspec/changes/2026-03-24-standard-tasks/)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [ADR-010: Config as bootstrap-only](adr-010-config-as-bootstrap-only.md)
