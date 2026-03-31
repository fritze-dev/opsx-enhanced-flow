# ADR-020: Bootstrap Standard Tasks Section Placement

## Status

Accepted (2026-03-25)

## Context

The standard-tasks feature (ADR-018) introduced a two-layer system for post-implementation steps: universal steps defined in the schema template and project-specific extras defined in the constitution's `## Standard Tasks` section. Task generation already reads this section from the constitution and appends items after the universal steps. However, the bootstrap skill's constitution template only generated five sections (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions), leaving new projects unaware that the Standard Tasks feature exists or where to define project-specific steps. The fix needed to be minimal — adding the section to the template without inventing content, since bootstrap should only reflect observed patterns and provide structure for user-defined rules.

## Decision

1. **Place `## Standard Tasks` after `## Conventions` in the bootstrap constitution template** — logical grouping where conventions define patterns and standard tasks define post-implementation workflow
2. **Use an HTML comment explaining the feature's purpose rather than a placeholder item** — bootstrap should not invent rules; the comment clearly explains the relationship to the schema template

## Alternatives Considered

- Place Standard Tasks before Conventions — rejected as less intuitive ordering
- Use a placeholder checkbox item — rejected because bootstrap should not invent rules that were not observed in the codebase

## Consequences

### Positive

- New projects immediately see the Standard Tasks section and understand where to define project-specific post-implementation steps
- Consistent with the two-layer design established in ADR-018

### Negative

- No significant negative consequences identified.

## References

- [Change: bootstrap-standard-tasks-section](../../openspec/changes/2026-03-25-bootstrap-standard-tasks-section/)
- [Spec: project-bootstrap](../../openspec/specs/project-bootstrap/spec.md)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-018: Standard Tasks Two-Layer Design](adr-018-standard-tasks-two-layer-design.md)
