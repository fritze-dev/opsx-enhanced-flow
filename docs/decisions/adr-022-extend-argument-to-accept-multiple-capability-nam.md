# ADR-022: Extend Argument to Accept Multiple Capability Names

## Status

Accepted (2026-03-24)

## Context

The `/opsx:docs` skill's Step 1 (change detection) scans all capabilities against all archives to determine which docs need regeneration. For 18 capabilities across 19+ archives, this requires reading 18 frontmatter files plus 18 glob operations -- O(capabilities x archives) complexity that grows with project history. In the post-archive workflow (`/opsx:verify` then `/opsx:archive` then `/opsx:changelog` then `/opsx:docs`), the just-archived change already identifies exactly which capabilities were affected, making the full archive scan redundant. The existing single-capability argument mode already proved the pattern of skipping date scans when the caller explicitly names a capability. Extending this to accept multiple names was the natural next step.

## Decision

**Extend the existing argument to accept multiple capability names (comma-separated)** -- simplest change that naturally extends the existing single-capability mode. The alternatives considered (change name argument tied to archive parsing, or automatic detection from conversation context) were either too coupled to the archive structure or too implicit in their behavior.

## Alternatives Considered

- Change name argument (too coupled to archive structure, requires archive parsing)
- Automatic detection from conversation context (too implicit, unreliable)

## Consequences

### Positive

- Post-archive workflow can pass exactly the affected capabilities, eliminating the O(capabilities x archives) scan
- Backward compatible: no argument = full scan, single capability = existing behavior
- Simple to implement and reason about

### Negative

- Caller must know which capabilities were affected (no automatic detection from archive data)

## References

- [Change: optimize-docs-regeneration](../../openspec/changes/2026-03-24-optimize-docs-regeneration/)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-012: Incremental Docs Generation](adr-012-incremental-docs-generation.md)
