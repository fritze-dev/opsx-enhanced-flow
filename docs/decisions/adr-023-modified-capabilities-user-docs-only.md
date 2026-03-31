# ADR-023: Modified Capabilities: user-docs Only

## Status

Accepted (2026-03-24)

## Context

The multi-capability argument optimization for `/opsx:docs` needed to be placed within the right spec. The docs skill is a thin wrapper around schema instructions, and the incremental generation logic is owned by the `user-docs` spec. The question was whether other specs (e.g., `artifact-generation`) should also be modified to reflect the optimization, since docs generation happens within the broader pipeline. However, docs generation is independent of the artifact pipeline's generation flow -- it operates on already-archived specs, not on in-progress artifacts.

## Decision

**Only modify the `user-docs` spec** -- the docs skill is a thin wrapper, and the spec owns the incremental generation logic. The `artifact-generation` spec is not relevant because docs generation is independent of pipeline artifact generation.

## Alternatives Considered

- Modifying `artifact-generation` (not relevant -- docs is independent of pipeline generation)

## Consequences

### Positive

- Single spec modification keeps the change focused and easy to review
- Correctly reflects ownership: `user-docs` owns incremental generation behavior

### Negative

- No significant negative consequences identified.

## References

- [Change: optimize-docs-regeneration](../../openspec/changes/2026-03-24-optimize-docs-regeneration/)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-022: Extend Argument to Accept Multiple Capability Names](adr-022-extend-argument-to-accept-multiple-capability-nam.md)
