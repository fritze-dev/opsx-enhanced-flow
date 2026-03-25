---
title: "Architecture Docs"
capability: "architecture-docs"
description: "Architecture overview, decisions index, and documentation hub via /opsx:docs."
lastUpdated: "2026-03-25"
---
# Architecture Docs

The `/opsx:docs` command generates three documentation files: `docs/architecture.md` for the architecture overview, `docs/decisions.md` for the design decisions index, and `docs/README.md` as a compact hub linking to both plus a categorized capabilities table.

## Purpose

Without structured documentation, understanding the system structure, technology choices, and key design decisions requires navigating across the constitution, individual specs, and archived design artifacts. Separate focused documents give developers a clear entry point for each concern — architecture, decisions, and capability browsing — without scrolling through a monolithic file.

## Rationale

The documentation is split into three files with independent conditional regeneration triggers: the architecture overview only regenerates when the constitution changes, the decisions index only when ADRs change, and the README hub when capabilities or sub-files change. This avoids unnecessary rewrites and keeps each file focused on one concern. The README serves as a compact hub with navigation links rather than embedding all content inline, making it easy to scan while keeping detailed reference material accessible via one click.

## Features

- **Architecture overview** — `docs/architecture.md` with System Architecture, Tech Stack, and Conventions
- **Decisions index** — `docs/decisions.md` with Key Design Decisions table and Notable Trade-offs
- **README hub** — `docs/README.md` as compact navigation hub with capabilities table
- **Per-file conditional regeneration** — each file has its own trigger, minimizing unnecessary rewrites
- **Manual ADR support** — includes manually created ADRs (matching `adr-M*.md`) in the decisions table
- **Notable Trade-offs** — surfaces significant negative consequences from ADR Consequences sections
- **Category-grouped capabilities** — ordered by workflow phase using spec frontmatter metadata
- **Concise capability descriptions** — each description is at most 80 characters or 15 words
- **Stale file cleanup** — removes `docs/architecture-overview.md` and `docs/decisions/README.md` if they exist
- **Language support** — all content can be generated in the language configured via `docs_language`

## Behavior

### Architecture Overview as Standalone File

When you run `/opsx:docs`, the architecture overview (System Architecture, Tech Stack, Conventions) is written to `docs/architecture.md` as a standalone file, synthesized from the constitution and the three-layer-architecture spec.

### Architecture File Conditional Regeneration

The architecture file is only regenerated when it doesn't exist yet (first run) or when the constitution content (Tech Stack, Architecture Rules, Conventions) has diverged from what's in the existing file. If nothing changed, the file is skipped.

### Architecture Overview Without Three-Layer Spec

If the three-layer-architecture spec doesn't exist, a minimal System Architecture section is generated from the constitution Architecture Rules only.

### Decisions Index from ADR Files

The decisions index at `docs/decisions.md` is built by reading all ADR files in `docs/decisions/` (both generated and manual). For each ADR, the decision summary and rationale are extracted from the `## Decision` section content. Each row includes a direct ADR link.

### Decisions Index Conditional Regeneration

The decisions index is only regenerated when new ADRs were created in the current run or the file doesn't exist yet. If no new ADRs were generated, the file is skipped.

### Manual ADRs in Decisions Index

Manual ADRs matching `docs/decisions/adr-M*.md` appear in the Key Design Decisions table after all generated ADRs.

### Notable Trade-offs

If ADR Consequences sections contain significant negative consequences, a Notable Trade-offs subsection surfaces trade-offs that affect documentation consumers or represent meaningful constraints.

### No ADR Files Found

If no ADR files exist in `docs/decisions/`, the decisions index file is not generated.

### Compact README Hub

The README at `docs/README.md` is a compact hub containing a brief project description, navigation links to `docs/architecture.md` and `docs/decisions.md`, and a category-grouped capabilities table.

### README Conditional Regeneration

The README is regenerated when capability docs were written, when `docs/architecture.md` or `docs/decisions.md` was written, or on first run. Otherwise it is skipped.

### Capabilities Grouped by Category

Capabilities appear under category group headers (for example, "Setup", "Change Workflow") based on the `category` frontmatter field from baseline specs. Within each category, capabilities are ordered by their `order` field.

### Stale File Cleanup

If `docs/architecture-overview.md` or `docs/decisions/README.md` exist from a previous run, they are deleted during generation.

### Architecture Overview in Configured Language

When `docs_language` is set to a non-English language, all headings and content in architecture.md, decisions.md, and the README hub are translated. Product names, commands, and file paths remain in English.

## Known Limitations

- Does not detect spec-only changes without a new archive — documentation regenerates on the next archive.
- Constitution drift detection compares key sections but may miss subtle formatting-only changes.

## Future Enhancements

- Preflight validation for decision granularity to prevent excessively fine-grained ADR entries at the source.

## Edge Cases

- If no constitution is found, the agent warns and skips architecture overview generation.
- If a manual ADR lacks `## Decision` or `## Rationale`, the agent uses the ADR title as the decision text and leaves the rationale column empty.
- On first run after the docs restructure, the existing monolithic `docs/README.md` is overwritten with the new hub format. Architecture and decisions content moves to their respective files.
- Constitution content is always in English. The agent translates when generating the overview, not the constitution itself.
