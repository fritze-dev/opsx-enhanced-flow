# ADR-026: ADR generation runs BEFORE README generation

## Status
Accepted (2026-03-05)

## Context
The consolidated README (ADR-024) includes inline links to ADR files in the Key Design Decisions table. This creates a data dependency: the README generation step needs to know the ADR file paths to produce correct links. If the README were generated first, a two-pass approach would be required — generate README with placeholder links, then generate ADRs, then backfill the README with actual links. Research into the SKILL.md step sequence confirmed that reordering to generate ADRs before the README eliminates this complexity entirely, since ADR file paths are known after Step 4 completes and can be directly referenced in Step 5.

## Decision
ADR generation (Step 4) runs before README generation (Step 5), so that ADR file paths are available for inline links.

## Rationale
README needs ADR file paths for inline links. Reversing the order would require a two-pass approach that adds unnecessary complexity.

## Alternatives Considered
- Generate README first, then backfill ADR links — adds complexity with a two-pass approach

## Consequences

### Positive
- Single-pass generation with correct links
- No placeholder or backfill logic needed

### Negative
- No significant negative consequences identified

## References
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
