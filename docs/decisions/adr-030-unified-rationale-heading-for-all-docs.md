# ADR-030: Unified "Rationale" heading for all docs

## Status
Accepted (2026-03-05)

## Context
Similar to the Purpose heading inconsistency (ADR-029), the design reasoning section had multiple heading variants across capability docs: enriched docs used "Background" while spec-only docs used "Design Rationale". The v1.0.7 regeneration had also introduced a regression where 11 of 18 Rationale sections replaced design reasoning with change-event descriptions (e.g., "was later added" narrative). Research showed that "Rationale" is the standard ADR terminology for design reasoning, covering both research-based reasoning (from archives) and assumption-based reasoning (from specs). Using a consistent term across all docs eliminates the enriched-vs-spec-only structural inconsistency.

## Decision
Use a unified "Rationale" heading for all capability docs, replacing both "Background" and "Design Rationale" variants.

## Rationale
Standard ADR terminology. Covers both research-based and assumption-based design reasoning without ambiguity.

## Alternatives Considered
- "Background" — too vague, does not convey design reasoning
- "Design Rationale" — redundant with ADR Context, adds unnecessary length

## Consequences

### Positive
- Consistent heading structure across all capability docs
- Standard terminology aligned with ADR conventions
- Clearer distinction between change events and design reasoning

### Negative
- No significant negative consequences identified

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-029: Unified "Purpose" heading for all docs](adr-029-unified-purpose-heading-for-all-docs.md)
