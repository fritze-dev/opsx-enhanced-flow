# ADR-004: Schema owns workflow rules

## Status
Accepted (2026-03-02)

## Context
The first dogfooding run revealed that workflow rules were scattered across config.yaml, constitution, and schema with heavy redundancy. A rule ownership audit (Issue #1) found that rules like the Definition of Done (DoD) and post-apply workflow sequence were duplicated in config.yaml's global context and the constitution, even though they apply universally to ALL projects using the opsx-enhanced schema. Research into OpenSpec config.yaml customization confirmed that per-artifact `rules` and `instructions` in the schema are the correct mechanism for targeted enforcement. The key constraint was establishing clear rule ownership: schema for universal rules, constitution for project-specific rules, config.yaml for bootstrap only.

## Decision
Schema owns workflow rules. The DoD and post-apply sequence are placed in schema.yaml's `tasks.instruction` and `apply.instruction` respectively, since they apply to all projects using the opsx-enhanced schema.

## Rationale
DoD and post-apply sequence apply to ALL projects using opsx-enhanced — they belong in the shared schema, not per-project config.

## Alternatives Considered
- config.yaml rules — leads to per-project duplication of universal rules
- Constitution — also per-project, inappropriate for universal workflow rules

## Consequences

### Positive
- Single source of truth for universal workflow rules
- Consumer projects inherit correct rules automatically via schema
- No per-project duplication or drift risk

### Negative
- Reduced defense-in-depth since rules now live in one place instead of being duplicated; accepted because schema enforcement plus skill guardrails are sufficient

## References
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-005: Config as bootstrap-only](adr-005-config-as-bootstrap-only.md)
- [ADR-006: Remove constitution redundancies](adr-006-remove-constitution-redundancies.md)
