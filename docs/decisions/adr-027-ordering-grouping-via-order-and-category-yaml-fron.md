# ADR-027: Ordering + grouping via order and category YAML frontmatter in baseline specs

## Status
Accepted (2026-03-05)

## Context
The consolidated README needed to present capabilities in a meaningful order grouped by category (Setup, Change Workflow, Development, Finalization, Reference, Meta) rather than alphabetically. The ordering and grouping data needed to be deterministic and project-specific — different projects using the same plugin might want different orderings. Several options were considered: hardcoding a table in SKILL.md (violates skill immutability since SKILL.md is shared plugin code), using a constitution section (mixes data with rules), or letting the agent determine order at docs generation time (non-deterministic). Adding `order` (integer) and `category` (string) YAML frontmatter fields to baseline specs follows the data flow principle: specs contain the metadata, archives preserve it, and docs generation reads it.

## Decision
Use `order` and `category` YAML frontmatter fields in baseline specs for deterministic, project-specific capability ordering and grouping in documentation.

## Rationale
Project-specific, deterministic, set during spec creation. SKILL.md stays project-independent. Follows the data flow from specs through archives to docs.

## Alternatives Considered
- Hardcoded table in SKILL.md — violates skill immutability since SKILL.md is shared plugin code
- Constitution section — mixes data tables with governance rules
- Agent-determined ordering at docs time — non-deterministic, may vary between runs

## Consequences

### Positive
- Deterministic ordering that is consistent across runs
- Project-specific: different projects can define their own ordering
- SKILL.md remains generic and shareable

### Negative
- All 18 baseline specs need frontmatter added; one-time setup cost

## References
- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
