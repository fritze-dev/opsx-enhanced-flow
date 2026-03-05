# ADR-031: Separate "Future Enhancements" from "Known Limitations"

## Status
Accepted (2026-03-05)

## Context
Capability docs needed to surface two distinct types of information from Non-Goals: current constraints (things the capability deliberately does not do) and deferred features (things planned for the future). These serve different audiences and purposes — limitations help users understand current boundaries, while enhancements help contributors and planners understand the roadmap. Mixing them in a single section obscures both. Research into the archive data showed that Non-Goals consistently fall into these two categories: permanent constraints (e.g., "no CI/CD automation") and deferred features (e.g., "deferred `/opsx:release` skill"). Six or more capabilities had actionable future enhancement items from deferred Non-Goals and tracked GitHub Issues.

## Decision
Create a separate "Future Enhancements" section distinct from "Known Limitations" in capability docs.

## Rationale
Limitations describe current constraints; enhancements describe actionable future ideas. They serve different audiences and purposes and should not be conflated.

## Alternatives Considered
- Single "Limitations & Future" section — conflates different types of information for different audiences
- Embed in Edge Cases — misrepresents future plans as edge cases

## Consequences

### Positive
- Clear separation between current constraints and future plans
- Contributors can quickly find planned improvements
- Users understand current boundaries without confusion

### Negative
- No significant negative consequences identified

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
