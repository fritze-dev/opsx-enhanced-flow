# ADR-016: Streamline ADR Format

## Status

Accepted (2026-03-23)

## Context

The ADR template (`openspec/schemas/opsx-enhanced/templates/docs/adr.md`) defined a 7-section structure including a separate `## Rationale` section. When ADR-012 introduced consolidation heuristics (grouping related decisions from the same archive into a single ADR with numbered sub-decisions), the consolidated format instructions told agents to put "individual rationale inline" in the Decision section using the em-dash pattern. However, those instructions never explicitly addressed the template's separate Rationale section — it was simply ignored by agents generating consolidated ADRs.

Since the consolidation heuristics applied to nearly all archives (3+ decision rows in a single-topic change), the consolidated format became the de facto standard. As a result, 14 of 15 generated ADRs had no separate Rationale section — an unintentional side effect rather than a deliberate design choice. Only ADR-015 retained a separate Rationale, likely because the generating agent followed the template more literally than the SKILL.md consolidation instructions.

Research into pre-consolidation ADRs revealed that the separate Rationale sections were always 100% redundant copies of the Decision text. For example, ADR-009's Decision stated "Patch-only auto-bump. 95%+ of changes are patches; minor/major are rare and intentional" while its Rationale was simply "95%+ of changes are patches; minor/major are rare and intentional." This redundancy occurred because the source data — the design.md Decisions table — has Decision and Rationale columns where the rationale often IS the decision statement. The inline pattern introduced by consolidation was strictly better: each decision is paired directly with its specific reasoning.

Separately, the Key Design Decisions table in `docs/README.md` was sourcing its data from `design.md` archives (for Decision/Rationale text) and ADR files (for links only) — two different extraction paths. Since ADRs are the canonical output of the decision documentation process, reading everything from ADR files eliminates the indirection and unifies the extraction path for both generated and manual ADRs.

## Decision

1. **Remove `## Rationale` section from ADR template and replace with inline-rationale in Decision section** — the section was always a redundant copy of the Decision text (verified across all pre-consolidation ADRs); the inline pattern is already the de facto standard in 14/15 ADRs
2. **Generalize the consolidated format's inline-rationale to all ADR types** — single-decision ADRs benefit from the same pattern; avoids having two different Decision section formats
3. **Update Language-Aware heading list to 6 headings (drop Rationale)** — the translated heading list must match the actual template sections
4. **README Key Design Decisions table sources data from ADR files instead of design.md archives** — ADRs are the canonical output; reading from them eliminates the indirection through design.md and unifies extraction for generated and manual ADRs

## Alternatives Considered

- Keep Rationale as optional section (causes inconsistency between ADRs)
- Move Rationale into Context section (wrong semantic home — Context explains the problem, not the reasoning for the solution)
- Keep separate formats for consolidated vs. single-decision ADRs (unnecessary complexity and inconsistency)
- Keep 7 headings including Rationale translation (template/heading mismatch when Rationale section no longer exists)
- Keep design.md as source for README table (works but adds unnecessary indirection; two different extraction paths for generated vs. manual ADRs)

## Consequences

### Positive

- ADR template and actual practice are now aligned — agents receive consistent instructions
- Inline rationale pairs each decision directly with its specific reasoning, which is more informative than a redundant copy at the bottom
- Single canonical source (ADR files) for the Key Design Decisions table eliminates the design.md indirection
- Unified extraction path for generated and manual ADRs simplifies the README generation logic
- Language-aware heading list matches the actual template structure

### Negative

- Manual ADRs may still use a separate `## Rationale` section. The README table extraction handles this via a separate code path for manual ADRs. Accepted trade-off: manual ADRs are user-authored and can use any format.
- Inline rationale extraction for the README table requires the agent to parse the em-dash pattern from ADR Decision sections. For consolidated ADRs with multiple sub-decisions, the agent summarizes the overarching decision. This is a summarization task that LLM agents handle well.

## References

- [Change: streamline-adr-format](../../openspec/changes/2026-03-23-streamline-adr-format/)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [ADR-012: Incremental Docs Generation](adr-012-incremental-docs-generation.md)
