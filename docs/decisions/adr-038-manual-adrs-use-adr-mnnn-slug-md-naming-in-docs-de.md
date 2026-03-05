# ADR-038: Manual ADRs use adr-MNNN-slug.md naming in docs/decisions/ (same directory)

## Status
Accepted (2026-03-05)

## Context
A full docs regeneration test revealed that manually created ADRs (not derived from design.md Decisions tables) were lost during regeneration because the cleanup step removed all ADR files before regenerating. The project had one manual ADR (`adr-M001-init-model-invocable.md`) that needed to survive the regeneration cycle. Three preservation strategies were evaluated: a separate `docs/decisions/manual/` subdirectory (unnecessary complexity, requires README to discover two locations), an `adr-MNNN-slug.md` naming convention in the same directory (M prefix unambiguously distinguishes manual from generated `adr-NNN`, single glob location), and a SKILL.md preservation rule for unmatched ADRs (fuzzy matching risks numbering conflicts). Research confirmed that the M prefix convention is simple, unambiguous, and requires only a single glob pattern for README discovery.

## Decision
Manual ADRs use the `adr-MNNN-slug.md` naming convention in the same `docs/decisions/` directory as generated ADRs, with the M prefix distinguishing them.

## Rationale
No extra directory needed. The M prefix unambiguously distinguishes manual ADRs from generated `adr-NNN` files. Single glob location for README discovery.

## Alternatives Considered
- Separate `manual/` subdirectory — unnecessary complexity, requires discovering two locations
- Preservation rule for unmatched ADRs — fuzzy matching, numbering conflicts with generated range

## Consequences

### Positive
- Simple naming convention that is easy to understand and implement
- Single directory for all ADRs simplifies discovery
- Manual ADRs survive regeneration via the M prefix pattern

### Negative
- No significant negative consequences identified

## References
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
