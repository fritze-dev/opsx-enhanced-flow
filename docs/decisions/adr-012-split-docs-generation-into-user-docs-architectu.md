# ADR-012: Split docs-generation into user-docs, architecture-docs, decision-docs

## Status
Accepted (2026-03-04)

## Context
The `/opsx:docs` skill was being enriched to generate not just capability docs from baseline specs, but also architecture overviews and Architecture Decision Records (ADRs) from archived artifacts. The existing `docs-generation` capability spec bundled all documentation concerns into one specification: user-facing capability docs, changelog, and now architecture and decision documentation. This made the spec bloated and hard to test independently. Research into the archive structure showed that each documentation type draws from different source materials: capability docs from specs and proposal/research archives, architecture docs from constitution and design decisions, ADRs from design.md decision tables. Additionally, changelog logically belonged under `release-workflow` rather than general documentation.

## Decision
Split `docs-generation` into three focused capabilities: `user-docs` (enriched capability docs), `architecture-docs` (architecture overview), and `decision-docs` (ADRs). Move changelog generation to `release-workflow`.

## Rationale
Each concern is independently spec'd and testable. Changelog fits better under `release-workflow` than under general documentation.

## Alternatives Considered
- Keep everything in one bloated `docs-generation` spec — harder to test, maintain, and reason about independently

## Consequences

### Positive
- Each documentation type has a focused, independently testable spec
- Changelog is co-located with its logical home in release-workflow
- Clearer separation of concerns across documentation types

### Negative
- SKILL.md prompt length increases from approximately 150 to 300 lines; accepted because clear section headers maintain readability

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
