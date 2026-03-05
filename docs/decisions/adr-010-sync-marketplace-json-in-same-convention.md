# ADR-010: Sync marketplace.json in same convention

## Status
Accepted (2026-03-04)

## Context
The plugin uses two JSON manifest files: `plugin.json` (plugin identity and version) and `marketplace.json` (self-hosted marketplace definition). These files had drifted out of sync, with marketplace.json at version 1.0.0 while plugin.json was at 1.0.3. Since both files contain version fields that must match, and the auto-bump convention (ADR-008) already touches plugin.json during archive, it was logical to sync marketplace.json in the same operation. A separate convention for marketplace sync would add unnecessary complexity and risk being forgotten independently.

## Decision
Sync marketplace.json version to match plugin.json as part of the same post-archive auto-bump convention.

## Rationale
One operation prevents version drift between the two files. A separate convention would add unnecessary complexity.

## Alternatives Considered
- Separate convention for marketplace.json sync — unnecessary complexity and risk of independent forgetting

## Consequences

### Positive
- Both manifest files are always in sync after every archive
- Single convention handles all version-related updates

### Negative
- No significant negative consequences identified

## References
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-008: Convention in constitution, not skill modification](adr-008-convention-in-constitution-not-skill-modification.md)
