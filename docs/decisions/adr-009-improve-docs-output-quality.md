# ADR-009: Improve Docs Output Quality

## Status

Accepted — 2026-03-05

## Context

The first production run of `/opsx:docs` (v1.0.5) exposed 11 quality gaps across three areas: docs structure (three overlapping entry-point files), content quality (weak initial-spec-only docs, thin ADR context, missing trade-offs), and missing infrastructure (no standalone doc templates). Nine of 18 capability docs were initial-spec-only, producing noticeably weaker documentation than their enriched counterparts because the generation prompt lacked fallback guidance for specs without dedicated archives. The docs structure had `docs/README.md`, `docs/architecture-overview.md`, and `docs/decisions/README.md` serving overlapping purposes, forcing readers through unnecessary navigation hops. The project README (462 lines) also duplicated content that now lived in auto-generated docs. Research confirmed that all 11 items were highly interdependent — consolidation changes affected where trade-offs appeared, and template extraction restructured how all items were expressed — so a single coordinated change was the only practical approach.

## Decision

1. **SKILL.md references doc templates via Read at runtime** — Consistent with pipeline artifact templates; format changes do not require prompt edits; maintains a single source of truth for doc structure.
2. **Consolidated README replaces three separate files** — Eliminates navigation hops between `docs/README.md`, `docs/architecture-overview.md`, and `docs/decisions/README.md`; the architecture overview is the natural entry point, and the ADR index fits as an inline table.
3. **Cleanup step in SKILL.md deletes stale files** — Consumer projects need automated migration from the old three-file to the new one-file structure; manual deletion is fragile and easy to miss.
4. **ADR generation runs BEFORE README generation** — The README needs ADR file paths for inline links; reversing the order would require a two-pass approach that adds unnecessary complexity.
5. **Ordering and grouping via `order` and `category` YAML frontmatter in baseline specs** — Provides project-specific, deterministic ordering set during spec creation rather than docs generation; keeps SKILL.md project-independent; follows the natural data flow from specs through archives to docs.
6. **README shortening is a separate implementation task from docs regeneration** — The README is hand-written, so changes are independent of auto-generated docs and benefit from separate review.

## Alternatives Considered

- Inline format definitions in SKILL.md instead of external templates (rejected: harder to maintain, bloats the prompt)
- Keep separate files with better cross-linking instead of consolidation (rejected: still requires maintaining three files)
- Manual deletion only for stale files (rejected: fragile, consumers would miss it)
- Migration guide only without automated cleanup (rejected: automation is simple and more reliable)
- Generate README first, then backfill ADR links (rejected: adds two-pass complexity)
- Hardcoded capability table in SKILL.md (rejected: violates skill immutability)
- Constitution section for ordering data (rejected: ordering data is a data table, not a rule)
- Agent-determined ordering at docs time (rejected: non-deterministic results)
- Include README shortening in docs regeneration task (rejected: mixes auto-generated and hand-written concerns)

## Consequences

### Positive

- Single entry point (`docs/README.md`) eliminates reader confusion and navigation overhead
- Doc templates provide a single source of truth for structural format, decoupled from prompt logic
- Frontmatter-based ordering ensures deterministic, project-specific capability grouping
- Consumer projects get automatic migration via the cleanup step
- SKILL.md prompt length actually decreases due to template extraction, improving prompt effectiveness

### Negative

- External links to `docs/architecture-overview.md` and `docs/decisions/README.md` will break (mitigated: docs are internal to the repo, low external link risk)
- Initial-spec research.md may be thin, limiting Design Rationale quality for spec-only docs (mitigated: SKILL.md instructs to omit the section if data is insufficient)
- Consumer projects running `/opsx:docs` after plugin update will get the new structure without explicit warning (mitigated: docs are fully regenerated each run with no state to migrate)

## References

- [Archive: improve-docs-quality](../../openspec/changes/archive/2026-03-05-improve-docs-quality/)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
- [ADR-003: Documentation Ecosystem](adr-003-documentation-ecosystem.md)
