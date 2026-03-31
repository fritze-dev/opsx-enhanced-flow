# ADR-021: Constitution Template Extraction

## Status

Accepted (2026-03-25)

## Context

The constitution section structure (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks) was hardcoded inline in the bootstrap skill. Every other generated artifact in the schema already had a dedicated template file under `openspec/schemas/opsx-enhanced/templates/`, creating an inconsistency. This meant the constitution structure could not vary per schema and was harder to maintain independently of the skill logic. The research phase confirmed that extracting to a template was low risk — the template defines structure only, not content, and the bootstrap skill already resolves the schema path in its Step 0. Two approaches were considered: extracting to a template file (consistent with the existing pattern) or keeping sections inline with a shared constant (rejected as still hardcoded and inconsistent).

## Decision

1. **Template contains section headings and parenthetical guidance comments** — matches the current inline format and helps the bootstrap agent understand what to fill in for each section
2. **Bootstrap references template by schema path** — the schema path is already resolved in Step 0 via `openspec schema which`, making it natural to reuse rather than hardcoding a path (which would break per-schema extensibility)
3. **Keep `# Project Constitution` heading in the template** — the template represents the complete constitution structure and should be self-contained rather than splitting the heading into the bootstrap skill

## Alternatives Considered

- Full Gherkin-style template (rejected: constitution is freeform, not structured like specs)
- Hardcoded path instead of schema-resolved path (rejected: breaks per-schema extensibility)
- Heading only in bootstrap, not in template (rejected: template should be self-contained)

## Consequences

### Positive

- Constitution section structure is now consistent with the existing template system
- Single source of truth for section structure — the inline block in the skill is removed entirely, eliminating drift
- Enables per-schema constitution variants in the future (different schemas can define different section structures)
- Template is a flexible starting point — bootstrap can adapt sections per project

### Negative

- No significant negative consequences identified. The change is a straightforward extraction with no new infrastructure required.

## References

- [Change: constitution-template](../../openspec/changes/2026-03-25-constitution-template/)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [ADR-020: Bootstrap Standard Tasks Section Placement](adr-020-bootstrap-standard-tasks-section-placement.md)
