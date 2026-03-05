# ADR-025: Cleanup step in SKILL.md deletes stale files

## Status
Accepted (2026-03-05)

## Context
The consolidation of three documentation files into a single README (ADR-024) meant that `docs/architecture-overview.md` and `docs/decisions/README.md` would become stale after the next `/opsx:docs` run. Consumer projects running the updated plugin would also have these stale files. Manual deletion instructions are fragile and easily missed, especially by consumers who may not be aware of the structural change. The SKILL.md already controls the full documentation generation lifecycle, making it the natural place to add a cleanup step that removes files that no longer belong in the output structure.

## Decision
Add a cleanup step in SKILL.md that automatically deletes stale files from the previous documentation structure.

## Rationale
Consumer projects need automated migration from old 3-file to new 1-file structure. Manual deletion is fragile and consumers would miss it.

## Alternatives Considered
- Manual deletion only — fragile, consumers would miss it
- Migration guide only — automation is simple and more reliable

## Consequences

### Positive
- Automated transition for both the plugin and consumer projects
- No stale files left behind after docs generation

### Negative
- No significant negative consequences identified

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-024: Consolidated README replaces 3 separate files](adr-024-consolidated-readme-replaces-3-separate-files.md)
