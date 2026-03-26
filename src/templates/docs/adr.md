---
id: docs-adr
description: Architecture Decision Record template
generates: "docs/decisions/adr-*.md"
requires: []
instruction: |
  Generate ADRs from archived design.md Decisions tables.
  Use inline rationale via em-dash in the Decision section.
  Use semantic link text for references.
  Context should be minimum 4-6 sentences.
---
# ADR-NNN: [Decision Title]

## Status

Accepted (YYYY-MM-DD)

## Context

<!-- Minimum 4-6 sentences. Include:
     - What motivated the decision (the problem being solved)
     - What was investigated or researched
     - Key constraints or trade-offs that shaped the decision
     Enrich with research.md "## 3. Approaches" from the same archive if available.
     Do NOT write thin contexts like "we chose X over Y because Z". -->

[Context text]

## Decision

<!-- For consolidated ADRs (multiple sub-decisions):
     Use a numbered list with inline rationale via em-dash:
     1. **Sub-decision text** — rationale explaining why
     2. **Sub-decision text** — rationale explaining why

     For single-decision ADRs:
     **Decision text** — rationale explaining why

     Rationale is always inline. There is no separate Rationale section. -->

[From the Decisions table. Each decision includes its rationale inline via em-dash.]

## Alternatives Considered

- [From the Decisions table "Alternatives" column, expanded into bullet points]

## Consequences

### Positive

- [Benefits of this decision, derived from rationale, context, and positive outcomes]

### Negative

- [Drawbacks, risks, or trade-offs from design.md "Risks & Trade-offs",
   filtered to relevance for this specific decision where possible.
   If no relevant negative consequences: "No significant negative consequences identified."]

## References

<!-- Use semantic link text that describes what the reference IS, not the file path.
     ALWAYS use proper markdown link syntax: [descriptive text](path).

     CORRECT:
     - [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
     - [ADR-019: Constitution Convention Only](adr-019-constitution-convention-only.md)
     - [GitHub Issue #21](https://github.com/owner/repo/issues/21)

     WRONG (raw path as link text):
     - [../../openspec/specs/three-layer-architecture/spec.md](../../openspec/specs/three-layer-architecture/spec.md)
-->

- [Spec: <capability-name>](../../openspec/specs/<capability>/spec.md)
- [ADR-NNN: <decision-title>](adr-NNN-slug.md)
- [GitHub Issue #N](https://github.com/owner/repo/issues/N)
