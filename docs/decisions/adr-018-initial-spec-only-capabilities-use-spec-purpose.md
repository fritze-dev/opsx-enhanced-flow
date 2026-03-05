# ADR-018: initial-spec-only capabilities use spec Purpose

## Status
Accepted (2026-03-04)

## Context
Nine of the 15 original capabilities were created during the initial-spec bootstrap and have never been modified by a subsequent change. The initial-spec proposal's "Why" section describes why baseline specifications are being created ("no specs exist, need a foundation for spec-driven development"), not why individual capabilities like `spec-format` or `three-layer-architecture` exist. Using the bootstrap proposal for these capabilities' "Why This Exists" section would be misleading — readers would see generic bootstrapping motivation instead of capability-specific purpose. The spec's Purpose section, however, directly describes what each capability does and why it matters.

## Decision
For capabilities whose only archive is initial-spec, derive "Why This Exists" from the spec Purpose section instead of the proposal "Why" section.

## Rationale
The bootstrap proposal "Why" is about spec creation, not individual capabilities. The spec Purpose section accurately describes each capability's reason for existence.

## Alternatives Considered
- Use bootstrap proposal anyway — misleading, provides generic bootstrapping context instead of capability-specific motivation

## Consequences

### Positive
- Each capability's documentation accurately reflects its own purpose
- No misleading generic bootstrapping language in individual capability docs

### Negative
- Missing archive artifacts (e.g., no design.md in fix-init-skill) require graceful fallback; docs skip enrichment from missing artifacts

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-017: "Why This Exists" uses newest archive's proposal](adr-017-why-this-exists-uses-newest-archive-s-proposal.md)
