# ADR-027: Split README into Hub + Architecture + Decisions

## Status

Accepted (2026-03-25)

## Context

The `docs/README.md` had grown to 148 lines as a monolithic auto-generated document. The Key Design Decisions table (26 ADRs) and Notable Trade-offs section together consumed nearly half the document and grew with every archived change. This made the documentation entry point increasingly hard to scan — developers looking for the capabilities table had to scroll past extensive decision reference material, and the decisions table itself was difficult to browse in the middle of an architecture overview.

The previous design (ADR-009) established a "Consolidated README" as a deliberate architectural choice, merging architecture overview, decision tables, and capabilities into one file. While this eliminated navigation hops, it conflated navigation (finding capabilities) with reference material (decision history). Each concern also had different change frequencies: architecture and conventions change rarely, decisions grow with every archive, and capabilities change when specs are modified.

Additionally, `/opsx:discover` was building research context from only the constitution and baseline specs, missing the existing body of architectural decisions. Relevant ADRs explain constraints, established patterns, and rejected alternatives that directly inform new research — but reading all 26+ ADR files for every discovery run would be wasteful.

The investigation identified `docs/decisions.md` as a natural solution for both problems: as a standalone decisions index it removes the growing table from the README, and as a lightweight index for discover it enables selective ADR reading without loading all files.

## Decision

1. **Split README into hub + architecture.md + decisions.md** — three files provides clean separation while keeping capabilities as the natural browsing entry point in the hub. Decisions table (26+ entries) and trade-offs grow with every change; architecture and conventions change rarely; capabilities are the primary browsing interface.
2. **Per-file conditional regeneration with independent triggers** — architecture.md triggers on constitution drift, decisions.md on ADR changes, README on capability/sub-file changes. Minimizes unnecessary regeneration; each file has a single clear responsibility and trigger.
3. **Discover reads decisions.md index then selects specific ADRs** — two-step process avoids reading all ADR files. decisions.md is lightweight (~30 lines of table); reading 26+ individual ADR files for every discover run is wasteful; index provides enough context for relevance filtering.
4. **Add optional "Related Decisions" section to research template** — section 0, before Current State. Makes ADR references structured and visible; optional so trivial changes aren't burdened; positioned first because decisions set the architectural context for research.

## Alternatives Considered

- **Keep monolithic README (ADR-009)** — preserves single-file simplicity but document keeps growing and conflates navigation with reference material
- **Split into 4+ files** — moving capabilities to a separate index too, but capabilities are compact (~50 lines) and serve as the natural browsing entry point
- **Use collapsible HTML sections** — keeps single file but `<details>/<summary>` doesn't render everywhere and doesn't address the structural issue
- **Single trigger for all files** — simpler conditional regeneration but causes unnecessary rewrites when only one concern changes
- **Read all ADR files directly in discover** — simpler implementation but wasteful for every discovery run
- **Use ADR file names only for matching** — too imprecise for thematic relevance
- **Skip ADR awareness entirely** — misses valuable context that explains constraints and rejected alternatives
- **Inline ADR references in Current State** — less structured than a dedicated section
- **Mandatory Related Decisions section** — burdens simple changes unnecessarily

## Consequences

### Positive

- README stays compact (~40 lines) as a hub with navigation links and capabilities table
- Each documentation file has a focused concern with independent regeneration triggers
- Decisions index serves double duty: standalone reference and lightweight index for discover
- Discover gains architectural context without reading all ADR files
- Research output captures related decisions in a visible, structured section

### Negative

- **Reverses ADR-009 (Consolidated README)** — the established "single entry point" design is superseded. Accepted because the new structure provides better separation while maintaining a clear entry point via the hub.
- **Three files instead of one** — more files to track, though each has independent triggers so maintenance is simpler (only changed files regenerate).
- **Keyword-based ADR relevance in discover** — may miss some relevant ADRs or include irrelevant ones. False negatives mean less context (same as today); false positives are low-cost.
- **Old monolithic README overwritten on first run** — one-time migration, but no rollback needed since the README is auto-generated.

## References

- [Archive: adr-aware-docs-restructure](../../openspec/changes/archive/2026-03-25-adr-aware-docs-restructure/)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: interactive-discovery](../../openspec/specs/interactive-discovery/spec.md)
- [ADR-009: Improve docs output quality](adr-009-improve-docs-output-quality.md)
