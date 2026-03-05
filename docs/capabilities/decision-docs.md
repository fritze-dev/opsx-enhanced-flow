---
title: "Decision Docs"
capability: "decision-docs"
description: "Architecture Decision Records (ADRs) generated from archived design decisions."
lastUpdated: "2026-03-05"
---
# Decision Docs

The `/opsx:docs` command generates Architecture Decision Records (ADRs) from the Decisions tables found in archived design.md files. Each architectural decision becomes a formal, searchable record with context, rationale, alternatives, and consequences at `docs/decisions/adr-NNN-<slug>.md`.

## Purpose

Without formal decision records, understanding why architectural choices were made requires digging through archived design artifacts and piecing together context from multiple files. ADRs provide a structured, searchable format where each decision is documented with its motivation, alternatives considered, and consequences — positive and negative.

## Rationale

ADRs are generated from design.md Decisions tables because these tables already capture the essential elements of each decision (decision text, rationale, alternatives). Numbering is global and sequential across all archives sorted chronologically, and ADRs are fully regenerated on each run to ensure deterministic, reproducible output without state tracking. The slug is derived using a deterministic algorithm that handles all special characters uniformly, ensuring stable file names across regeneration cycles. ADR Context sections are enriched with data from research.md and proposal.md to provide sufficient depth about what motivated the decision and what was investigated.

## Features

- **ADR generation from Decisions tables** — each row in a design.md Decisions table becomes one ADR file
- **Sequential numbering** — ADRs are numbered globally across all archives in chronological order
- **Rich context** — ADR Context sections include the problem motivation, investigation findings, and key constraints (at least 4-6 sentences)
- **Split consequences** — each ADR has Positive and Negative consequence subsections
- **Semantic references** — References sections link to related specs, other ADRs, and GitHub Issues using descriptive text
- **Deterministic slugs** — file names are derived from the decision text using a consistent algorithm
- **Manual ADR preservation** — files matching `adr-M*.md` are never deleted or overwritten during regeneration
- **Manual ADR inclusion** — manual ADRs appear in the docs/README.md Key Design Decisions table
- **Skip rule for invalid Decisions sections** — archives with prose-only Decisions sections or non-Decisions tables are skipped
- **Full regeneration** — ADRs are fully regenerated on each `/opsx:docs` run for deterministic output
- **Language support** — ADR headings and content can be generated in the configured `docs_language`

## Behavior

### ADRs from Decisions Tables

For each archived design.md file containing a valid Decisions table (with pipe delimiters and Decision/Rationale columns), each row becomes one ADR file at `docs/decisions/adr-NNN-<slug>.md`.

### ADR Numbering Across Archives

ADR numbering is global and sequential. Archives are sorted chronologically by their date prefix, and decisions within each archive are numbered in table row order. For example, if archive `2026-03-02` has 3 decisions and `2026-03-04` has 4, they are numbered ADR-001 through ADR-007.

### ADR Context Enriched with Research

For each archive, the agent reads the full design.md (Context, Architecture & Components, Risks & Trade-offs), along with research.md (Sections 2-3: External Research and Approaches) and proposal.md (Why section) where they exist. The Context section is at least 4-6 sentences, including what motivated the decision, what was investigated, and key constraints.

### ADR Consequences Split into Positive and Negative

Each ADR includes a Consequences section with a Positive subsection listing benefits and a Negative subsection listing drawbacks or trade-offs derived from the design.md Risks & Trade-offs section.

### ADR References with Semantic Link Text

The References section includes links with descriptive text (for example, `[Spec: release-workflow]`) rather than raw file paths. References are determined by checking the archive's `specs/` subdirectory to find which capabilities were affected and cross-referencing related ADRs from the same archive.

### Archive Without design.md

If an archived change has no design.md file, no ADRs are generated for that archive.

### Prose-Only Decisions Section Skipped

If a design.md has a Decisions section containing only prose (such as "No architectural changes") with no pipe-delimited table, no ADRs are generated for that archive.

### Non-Decisions Table Skipped

If a design.md has a table (such as Success Metrics) that is not a valid Decisions table (lacking Decision and Rationale columns), it is not misinterpreted as decisions.

### Deterministic Slug Generation

Slugs are derived from the Decision column text using a consistent algorithm: lowercase the string, replace any non-alphanumeric character with a hyphen, collapse consecutive hyphens, trim leading and trailing hyphens, and truncate to 50 characters.

### Manual ADR Preservation

Files matching `adr-M*.md` in the `docs/decisions/` directory are never deleted or overwritten during regeneration. They use the `adr-MNNN-slug.md` naming convention (M prefix with 3-digit zero-padded number) to distinguish them from generated ADRs.

### Manual ADR in README Table

Manual ADRs appear in the docs/README.md Key Design Decisions table after all generated ADRs. The agent extracts the Decision and Rationale from the manual ADR's `## Decision` and `## Rationale` sections.

### Multiple Manual ADRs Ordered

If multiple manual ADRs exist, they appear in numerical order (ADR-M001 before ADR-M002) after all generated ADRs.

### Stale ADR Index Deleted

If `docs/decisions/README.md` exists from a previous run, it is deleted. ADR discovery is handled through inline links in the consolidated `docs/README.md`.

### ADR Template

The agent reads the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` and uses it as the structural format for the output.

### Self-Contained Enrichment Reads

ADR generation reads its own source materials independently. The agent does not assume that data loaded during an earlier step is still available. Each archive's design.md, research.md, and proposal.md are read fresh during ADR generation.

### References from Archive Specs Directory

The agent checks the archive's `specs/` subdirectory to find which capabilities were affected by that change. For example, if `archive/2026-03-04-release-workflow/specs/release-workflow/` exists, the References section includes `[Spec: release-workflow]` pointing to the baseline spec.

### ADRs in Configured Language

When `docs_language` is set to a non-English language, ADR section headings (Context, Decision, Rationale, Alternatives Considered, Consequences) and content are translated. File names remain in English, and the slug is always derived from the English Decision column text.

### ADR Consequences Translated

When a non-English language is configured, consequence subsection headings are translated (for example, "Positivas" and "Negativas" in Spanish).

## Known Limitations

- Does not support incremental ADR generation — all ADRs are fully regenerated on each run, which means numbering may shift if archives are added or removed.
- No automated validation of ADR output quality — the QA method is manual regeneration and diff review.

## Future Enhancements

- Full per-step restructure for autonomous agent readiness, making every generation step a fully self-contained unit with its own read instructions.

## Edge Cases

- If no archives have design.md files, ADR generation is skipped entirely and no `docs/decisions/` directory is created.
- Both 3-column (`Decision | Rationale | Alternatives`) and 4-column (`# | Decision | Rationale | Alternatives Considered`) Decisions table formats are handled.
- If a Decisions table exists but is empty (no data rows), that archive is skipped for ADR generation.
- If no negative consequences are identifiable from the Risks section for a specific decision, the Negative subsection states "No significant negative consequences identified."
- If a decision is cross-cutting and not tied to a specific capability spec, the References section links to the constitution or the most relevant architectural spec.
- If a manual ADR lacks `## Decision` or `## Rationale`, the agent uses the ADR title as the decision text and leaves the rationale column empty in the README table.
- If an archive has design.md and research.md but no proposal.md, ADRs are still generated using the available data. Missing enrichment files reduce Context depth but do not prevent generation.
- The slug is always derived from the original English Decision column text, never from translated content. This ensures stable file names across language changes.
