# ADR-028: README shortening is a separate implementation task from docs regeneration

## Status
Accepted (2026-03-05)

## Context
The project README (462 lines) contained detailed content that was now duplicated by the auto-generated documentation in `docs/`. Shortening the README and linking to `docs/` was part of the improve-docs-quality change, but it involved editing a hand-written file that is independent of the auto-generated documentation output. Research showed that mixing hand-written README edits with auto-generated docs regeneration in the same implementation task would make review harder, since changes to the README require subjective judgment about which sections to keep and at what length. The design review checkpoint is the right place to align on README content decisions.

## Decision
README shortening is a separate implementation task from docs regeneration, allowing independent review of each.

## Rationale
README is hand-written; changes are independent of auto-generated docs. Allows separate review of subjective content decisions.

## Alternatives Considered
- Include README shortening in the docs regeneration task — mixes auto-generated and hand-written concerns, harder to review

## Consequences

### Positive
- Clearer separation of concerns between auto-generated and hand-written content
- Each task can be reviewed independently with appropriate review criteria

### Negative
- No significant negative consequences identified

## References
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
