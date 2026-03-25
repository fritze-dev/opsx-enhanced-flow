---
title: "Decision Docs"
capability: "decision-docs"
description: "Architecture Decision Records (ADRs) generated from archived design decisions."
lastUpdated: "2026-03-25"
---
# Decision Docs

The `/opsx:docs` command generates Architecture Decision Records (ADRs) from the Decisions tables found in archived design.md files. Each architectural decision becomes a formal, searchable record with context, rationale, alternatives, and consequences.

## Purpose

Without formal decision records, understanding why architectural choices were made requires digging through archived design artifacts and piecing together context from multiple files. ADRs provide a structured, searchable format where each decision is documented with its motivation, alternatives considered, and consequences. This makes architectural knowledge accessible without navigating the archive directory structure.

## Rationale

ADRs are generated from design.md Decisions tables because these tables already capture the essential elements of each decision (decision text, rationale, alternatives). Numbering is global and sequential across all archives sorted chronologically, providing a stable ordering. ADR Context sections are enriched with data from research.md and proposal.md to provide sufficient depth about what motivated the decision and what was investigated. Related decisions from single-topic archives are consolidated into one ADR with numbered sub-decisions, reducing noise while preserving detail. Generation is incremental by default — only new archives produce new ADR files, and existing ADRs are not regenerated or modified. References contain only internal relative links (archive backlinks, spec links, related ADR links), with post-generation validation ensuring all links point to existing paths.

## Features

- **ADR generation from Decisions tables** — each row in a design.md Decisions table becomes one ADR file (or part of a consolidated ADR)
- **Sequential numbering** — ADRs are numbered globally across all archives in chronological order
- **Inline rationale** — each decision includes its rationale inline using the em-dash pattern, with no separate Rationale section
- **Rich context** — ADR Context sections include the problem motivation, investigation findings, and key constraints (at least 4-6 sentences)
- **Split consequences** — each ADR has Positive and Negative consequence subsections
- **Internal-only references** — References sections link to source archives, related specs, and other ADRs using descriptive text, with no external URLs
- **Reference validation** — spec and archive links are verified to exist after generation, with broken links replaced or flagged
- **Cross-reference heuristic** — ADRs that modify a system established by an earlier ADR include a back-reference to that earlier record
- **Archive backlinks** — each ADR links back to its source archive directory as the first reference
- **ADR consolidation** — related decisions from the same archive are merged into a single ADR with numbered sub-decisions
- **Incremental generation** — only new archives produce new ADR files; existing ADRs are preserved
- **Deterministic slugs** — file names are derived from the decision text using a consistent algorithm
- **Manual ADR preservation** — files matching `adr-M*.md` are never deleted or overwritten during regeneration
- **ADR discovery via decisions index** — `docs/decisions.md` is the canonical entry point for browsing all architectural decisions
- **Manual ADR inclusion** — manual ADRs appear in the docs/decisions.md Key Design Decisions table
- **Skip rule for invalid Decisions sections** — archives with prose-only Decisions sections or non-Decisions tables are skipped
- **Language support** — ADR headings and content can be generated in the configured `docs_language`

## Behavior

### ADRs from Decisions Tables

For each archived design.md file containing a valid Decisions table (with pipe delimiters and Decision/Rationale columns), decisions become ADR files at `docs/decisions/adr-NNN-<slug>.md`. Related decisions from the same archive may be consolidated into a single ADR (see Consolidation below).

### ADR Numbering Across Archives

ADR numbering is global and sequential. Archives are sorted chronologically by their date prefix, and decisions within each archive are numbered in table row order (or consolidated group order). Consolidated ADRs reduce the total count — each consolidated group gets one sequential number instead of one per row.

### Consolidation of Related Decisions

When multiple decisions from the same archive share the same context and motivation, they are consolidated into a single ADR with numbered sub-decisions. Single-topic archives with 3 or more decision rows are consolidated by default. Archives where decisions address clearly different concerns produce separate ADRs. The consolidated ADR uses an overarching title derived from the archive name or the most significant decision, and merges alternatives and consequences from all sub-decisions.

### ADR Context Enriched with Research

For each archive, the agent reads the full design.md (Context, Architecture & Components, Risks & Trade-offs), along with research.md (Sections 2-3: External Research and Approaches) and proposal.md (Why section) where they exist. The Context section is at least 4-6 sentences, including what motivated the decision, what was investigated, and key constraints.

### ADR Consequences Split into Positive and Negative

Each ADR includes a Consequences section with a Positive subsection listing benefits and a Negative subsection listing drawbacks or trade-offs derived from the design.md Risks & Trade-offs section.

### Internal-Only References with Validation

The References section contains only internal relative links — no external URLs (GitHub issues, external docs). The source archive directory link appears as the first reference, using the format `[Archive: <name>]` with the archive name without the date prefix. Additional references include links to related specs (determined by checking the archive's `specs/` subdirectory) and related ADRs, all using descriptive text rather than raw file paths. After generating each ADR, every spec link is verified by globbing for the spec file, and every archive link is verified to point to an existing directory. Broken spec links are replaced with successor specs when identifiable. When a successor cannot be determined, the agent asks the user to identify the correct spec. Missing archive links are resolved by asking the user whether to remove the reference or provide the correct archive name. No `<!-- REVIEW -->` markers are left in generated ADR files.

### Cross-Referencing Related ADRs

When an ADR's archive modifies a system established by an earlier ADR, a cross-reference to that earlier record is included. The agent checks for explicit references to other changes in proposal.md or design.md, and looks for overlapping specs between archives. Cross-references are only added when a clear thematic relationship is evident — not speculatively.

### Incremental ADR Generation

By default, ADR generation is incremental. Before generating, the agent checks existing ADR files, identifies which archives have already been processed (via archive backlinks in References), and only generates new ADR files from unprocessed archives. Existing ADR files are not regenerated or modified. New ADRs are numbered sequentially starting after the highest existing number.

### No New Archives Skips Generation

When all archives with valid Decisions tables have already been processed and no new archives exist, ADR generation is skipped entirely.

### Skipping Invalid Decisions Sections

If a design.md has a Decisions section containing only prose (such as "No architectural changes") with no pipe-delimited table, no ADRs are generated for that archive. Tables that are not valid Decisions tables (such as Success Metrics tables lacking Decision and Rationale columns) are not misinterpreted as decisions.

### Deterministic Slug Generation

Slugs are derived from the Decision column text (or the consolidated title for merged ADRs) using a consistent algorithm: lowercase the string, replace any non-alphanumeric character with a hyphen, collapse consecutive hyphens, trim leading and trailing hyphens, and truncate to 50 characters.

### Manual ADR Preservation

Files matching `adr-M*.md` in the `docs/decisions/` directory are never deleted or overwritten during regeneration. They use the `adr-MNNN-slug.md` naming convention (M prefix with 3-digit zero-padded number) to distinguish them from generated ADRs.

### ADR Discovery via Decisions Index

All architectural decisions are browsable through `docs/decisions.md`, which lists every decision with its rationale and a link to the full ADR file. This file replaces the previous inline decision table that was embedded in `docs/README.md`.

### Manual ADRs in Decisions Index

Manual ADRs appear in the `docs/decisions.md` Key Design Decisions table after all generated ADRs, ordered numerically. The agent extracts the Decision and Rationale from the manual ADR's `## Decision` and `## Rationale` sections.

### Stale ADR Index Deleted

If `docs/decisions/README.md` exists from a previous run, it is deleted. ADR discovery is handled through `docs/decisions.md`.

### Self-Contained Enrichment Reads

ADR generation reads its own source materials independently. The agent does not assume that data loaded during an earlier step is still available. Each archive's design.md, research.md, and proposal.md are read fresh during ADR generation.

### Inline Rationale in Decision Section

Every ADR — whether consolidated or single-decision — includes rationale inline in the Decision section using the em-dash pattern. For consolidated ADRs, this is a numbered list where each sub-decision has its own rationale (for example, `1. **Sub-decision** — rationale`). For single-decision ADRs, this is a single statement with inline rationale (for example, `**Decision text** — rationale`). There is no separate Rationale section.

### ADRs in Configured Language

When `docs_language` is set to a non-English language, ADR section headings (Status, Context, Decision, Alternatives Considered, Consequences, References) and content are translated. File names remain in English, and the slug is always derived from the English Decision column text. Consequence subsection headings are also translated (for example, "Positivas" and "Negativas" in Spanish).

## Known Limitations

- No automated validation of ADR output quality — the QA method is manual regeneration and diff review.
- Does not detect spec-only changes without a new archive — the capability doc and ADRs for a capability are only regenerated when a new archive touches that capability.
- Consolidation heuristics may occasionally misjudge grouping for borderline cases with mixed-concern decisions.
- Incremental detection falls back to full ADR regeneration if existing ADR files lack archive backlinks (transition from older format).
- Cross-reference heuristics may miss some relationships between ADRs when the connection is not explicit in archive content.

## Future Enhancements

- Full per-step restructure for autonomous agent readiness, making every generation step a fully self-contained unit with its own read instructions.
- Preflight validation for decision granularity to flag excessively fine-grained decisions before they reach ADR generation.

## Edge Cases

- If no archives have design.md files, ADR generation is skipped entirely and no `docs/decisions/` directory is created.
- Both 3-column (`Decision | Rationale | Alternatives`) and 4-column (`# | Decision | Rationale | Alternatives Considered`) Decisions table formats are handled.
- If a Decisions table exists but is empty (no data rows), that archive is skipped for ADR generation.
- If no negative consequences are identifiable from the Risks section for a specific decision, the Negative subsection states "No significant negative consequences identified."
- If a decision is cross-cutting and not tied to a specific capability spec, the References section links to the constitution or the most relevant architectural spec.
- If a manual ADR lacks `## Decision` or `## Rationale`, the agent uses the ADR title as the decision text and leaves the rationale column empty in the README table.
- When consolidation logic is first applied, existing ADR numbers change. A full ADR regeneration is performed on the first run that applies consolidation.
- The slug for consolidated ADRs is derived from the overarching title, not individual sub-decisions. If the title exceeds 50 characters after slug conversion, it is truncated per the standard algorithm.
- The slug is always derived from the original English Decision column text, never from translated content, ensuring stable file names across language changes.
- If a referenced spec was renamed or split, the agent replaces the broken link with the correct successor spec(s). If the successor is unknown, the agent asks the user to identify the correct spec.
- If no earlier ADR exists for the system being modified, the cross-reference is skipped.
- When regenerating ADRs that previously contained external URLs, those links are omitted. The archive backlink provides traceability to issues via the archive's proposal.md.
