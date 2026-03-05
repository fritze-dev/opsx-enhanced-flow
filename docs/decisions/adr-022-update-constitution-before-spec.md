# ADR-022: Update constitution before spec

## Status
Accepted (2026-03-05)

## Context
The design review checkpoint required changes to both the constitution (governance rule) and the artifact-generation spec (behavioral specification). The question was which to update first during implementation. The constitution establishes governance rules that are authoritative across the project — it is the source of truth that agents read at every step. The spec formalizes the behavioral change in a testable format. Research into the project's three-layer architecture confirmed that governance rules in the constitution provide the backing for behavioral specifications: without the constitution convention, the spec change would lack governance authority. Updating the constitution first establishes the rule, then the spec formalizes it.

## Decision
Update the constitution before the spec to establish the governance rule first, then formalize the behavioral change in the spec.

## Rationale
The constitution establishes the governance rule that backs the spec change. Without it, the spec would lack governance authority.

## Alternatives Considered
- Spec first — would lack governance backing from the constitution

## Consequences

### Positive
- Clear governance chain: constitution rule backs the spec requirement
- Agents following the constitution will respect the checkpoint even before the spec is updated

### Negative
- Spec text may temporarily contradict the constitution during the transition; mitigated by delta spec taking precedence during the active change

## References
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-019: Constitution convention only](adr-019-constitution-convention-only.md)
