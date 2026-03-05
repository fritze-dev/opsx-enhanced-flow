# ADR-016: Research context integrated into ADR Context section

## Status
Accepted (2026-03-04)

## Context
Research artifacts (research.md) contain valuable context about approaches evaluated, decisions made, and open questions explored during each change. This context is directly relevant to understanding why architecture decisions were made. The question was whether to create separate research log documents in `docs/research/` or integrate research context into the ADR Context sections where it would be most useful. Research logs as separate documents would create more files and fragment the decision narrative, while integration into ADR Context sections provides a single place for understanding "why did we decide this?" — combining the problem motivation with the investigation findings.

## Decision
Integrate research context into ADR Context sections rather than creating separate research log documents.

## Rationale
One place for "why did we decide this?" is more useful than separate research logs. Avoids creating additional files with fragmented context.

## Alternatives Considered
- Separate `docs/research/` output — more files, less focused, fragments the decision narrative

## Consequences

### Positive
- ADR Context sections are rich and self-contained
- No separate research log files to maintain or navigate
- Decision context and research findings are co-located

### Negative
- No significant negative consequences identified

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
