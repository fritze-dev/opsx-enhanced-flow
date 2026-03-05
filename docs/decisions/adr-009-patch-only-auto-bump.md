# ADR-009: Patch-only auto-bump

## Status
Accepted (2026-03-04)

## Context
With the decision to auto-bump versions on archive (ADR-008), the question arose of which semver component to increment automatically. Research into the project's change history showed that 95%+ of changes are backwards-compatible patches: skill tweaks, documentation updates, and schema adjustments. Minor and major version bumps are rare and intentional, requiring human judgment about the scope and impact of changes. The core problem being solved was forgotten version bumps, not version classification — so automatic patch bumping addresses the root cause while leaving intentional version decisions to humans.

## Decision
Auto-bump only the patch version (X.Y.Z -> X.Y.Z+1) on archive. Minor and major bumps remain manual.

## Rationale
95%+ of changes are patches; minor/major are rare and intentional. Automatic patch bumping prevents forgotten bumps while preserving human control over significant version changes.

## Alternatives Considered
- Auto-detect version component from changelog — complex and unreliable for determining change significance

## Consequences

### Positive
- Version bumps are never forgotten for routine changes
- Minor/major version decisions remain under human control

### Negative
- Version inflation with many small patches; acceptable trade-off versus forgotten bumps
- No rollback mechanism for bad versions; consumers must wait for the next patch

## References
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-008: Convention in constitution, not skill modification](adr-008-convention-in-constitution-not-skill-modification.md)
