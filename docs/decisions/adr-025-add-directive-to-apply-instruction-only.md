# ADR-025: Add Directive to apply.instruction Only

## Status

Accepted (2026-03-25)

## Context

The mark-before-commit behavior needed a home in the schema. The `apply.instruction` field in `schema.yaml` is where the post-apply workflow is defined (archive, changelog, docs, commit). The question was whether the directive should also be added to individual skill files (archive, changelog, docs) to reinforce the behavior at each step, or whether a single directive in `apply.instruction` would suffice. Since the marking happens at commit time (after all steps complete), it logically belongs with the commit step, not with individual skills.

## Decision

**Add the directive to `apply.instruction` only** -- the apply instruction is where the post-apply workflow is defined, and no other location is needed. The alternative of scattering the logic across multiple skill files would spread responsibility without adding value.

## Alternatives Considered

- Adding to each skill file (archive, changelog, docs) -- scatters the logic across multiple files

## Consequences

### Positive

- Single location for the marking directive, easy to find and maintain
- Consistent with existing pattern of `apply.instruction` owning the post-apply workflow

### Negative

- No significant negative consequences identified.

## References

- [Change: fix-standard-tasks-commit-order](../../openspec/changes/2026-03-25-fix-standard-tasks-commit-order/)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [ADR-024: General Rule for Marking Standard Tasks Before Commit](adr-024-general-rule-ensure-all-checked-before-commit-rat.md)
