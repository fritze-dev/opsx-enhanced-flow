# ADR-029: Unified "Purpose" heading for all docs

## Status
Accepted (2026-03-05)

## Context
After the v1.0.7 docs quality improvement, a detailed review revealed heading inconsistency across the 18 generated capability docs. Enriched docs used "Why This Exists" while initial-spec-only docs used a different variation. The inconsistency confused readers who expected a uniform structure across all capability documentation. Research identified "Purpose" as the standard, unambiguous term used across technical documentation. The root cause was that SKILL.md instructed agents to derive the section from archive proposal "Why" sections (which describe change motivation like "the init skill was broken") instead of the spec's Purpose section (which describes capability purpose like "without a single initialization command, you'd need to manually...").

## Decision
Use a unified "Purpose" heading for all capability docs, regardless of whether they are enriched with archive data or spec-only.

## Rationale
Standard, unambiguous term. Eliminates the inconsistency between enriched and spec-only docs.

## Alternatives Considered
- Keep "Why This Exists" — informal, not standard terminology
- Use "Motivation" — too change-focused, conflates change motivation with capability purpose

## Consequences

### Positive
- Consistent heading structure across all 18 capability docs
- Standard terminology that readers expect
- Purpose content is derived from the correct source (spec Purpose section)

### Negative
- No significant negative consequences identified

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-030: Unified "Rationale" heading for all docs](adr-030-unified-rationale-heading-for-all-docs.md)
