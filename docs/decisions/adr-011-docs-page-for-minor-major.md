# ADR-011: Docs page for minor/major

## Status
Accepted (2026-03-04)

## Context
While patch version bumps are automated (ADR-009), minor and major releases require intentional human decisions about version significance, changelog framing, and potentially git tagging. Research into the project's needs showed that minor/major releases are rare events — the project has had no minor or major bumps since inception. Creating a dedicated `/opsx:release` skill for these rare events would be over-engineering. A documented manual process in the release workflow documentation is sufficient and proportionate to the frequency of use.

## Decision
Document the manual process for minor/major releases in a docs page, rather than creating a dedicated skill.

## Rationale
Minor/major releases are rare enough that a documented manual process suffices. A dedicated skill would be over-engineering for current needs.

## Alternatives Considered
- Dedicated `/opsx:release` skill — over-engineering for the current frequency of minor/major releases

## Consequences

### Positive
- Proportionate solution matching the rarity of minor/major releases
- No additional skill to maintain

### Negative
- No significant negative consequences identified

## References
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-009: Patch-only auto-bump](adr-009-patch-only-auto-bump.md)
