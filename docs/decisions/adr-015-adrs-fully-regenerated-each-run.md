# ADR-015: ADRs fully regenerated each run

## Status
Accepted (2026-03-04)

## Context
ADR generation from design.md decision tables could follow two models: incremental updates (tracking which archives have been processed and only generating new ADRs) or full regeneration (rebuilding all ADRs from scratch each time `/opsx:docs` runs). Incremental updates require state tracking to know which archives were last processed and which ADR numbers were assigned, adding complexity. Full regeneration is stateless and deterministic — the same archives always produce the same numbered ADRs in the same order. Since ADRs are derived entirely from archived design.md files that do not change after archiving, regeneration produces identical results each run.

## Decision
ADRs are fully regenerated each time `/opsx:docs` runs, not incrementally updated.

## Rationale
Deterministic, no state to track, numbering is always consistent. The same input archives always produce the same output.

## Alternatives Considered
- Incremental updates — requires tracking which archives are processed, adds state management complexity

## Consequences

### Positive
- Stateless and deterministic: same archives always produce the same ADRs
- No tracking state to manage or risk corrupting
- Numbering is always consistent and sequential

### Negative
- No significant negative consequences identified

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
