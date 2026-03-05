# ADR-017: "Why This Exists" uses newest archive's proposal

## Status
Accepted (2026-03-04)

## Context
Capability documentation includes a "Why This Exists" section explaining the motivation behind a capability. Since a capability can be touched by multiple archives over time (e.g., initial creation, then later modifications), there are multiple proposal.md files with "Why" sections that could serve as the source. The initial creation proposal may describe the original motivation, while later proposals may describe refinements or fixes. Research showed that the most recent archive's proposal contains the most current and relevant motivation, as older motivations may be superseded by evolved understanding. Concatenating all proposals would be verbose, and using only the oldest might present outdated reasoning.

## Decision
Use the newest archive's proposal "Why" section for the "Why This Exists" documentation section.

## Rationale
The most current motivation is the most relevant. Older motivations may be superseded by later understanding.

## Alternatives Considered
- Concatenate all proposals — too verbose
- Oldest only — may be outdated

## Consequences

### Positive
- Documentation always reflects the most current understanding of why a capability exists
- Concise and focused motivation section

### Negative
- Historical motivation context from earlier proposals is not surfaced; acceptable since ADRs capture the historical decision context

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
