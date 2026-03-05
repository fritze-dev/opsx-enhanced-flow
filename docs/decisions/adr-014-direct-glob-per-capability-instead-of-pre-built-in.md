# ADR-014: Direct glob per capability instead of pre-built index

## Status
Accepted (2026-03-04)

## Context
To enrich capability documentation with archive-derived content (motivation, research findings, design decisions), the docs skill needs to find which archives touched each capability. Two approaches were considered: building a Capability-to-Change Index upfront by parsing all proposal.md files, or using a direct glob pattern (`archive/*/specs/<capability>/`) per capability during generation. Research found that the number of archives is small (5 at the time), proposal.md files have a consistent `- \`capability-name\`: description` format under `### New Capabilities` / `### Modified Capabilities`, and the glob approach requires no separate index-building step. The simpler approach was preferred given the small scale.

## Decision
Use a direct glob per capability (`archive/*/specs/<capability>/`) instead of building a pre-built Capability-to-Change Index.

## Rationale
Simpler implementation with no separate step needed. Archives are few, and the glob pattern reliably finds all archives that touched a given capability.

## Alternatives Considered
- Capability-to-Change Index with proposal parsing — over-engineering given the small number of archives

## Consequences

### Positive
- No index to build or maintain
- Simpler implementation with fewer moving parts
- Works reliably with the existing archive directory structure

### Negative
- ADR numbering instability if archives are reordered; mitigated by deterministic regeneration from chronological sort

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
