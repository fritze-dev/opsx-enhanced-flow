---
title: "Architecture Docs"
capability: "architecture-docs"
description: "Cross-cutting architecture overview and documentation entry point via /opsx:docs."
lastUpdated: "2026-03-23"
---
# Architecture Docs

The `/opsx:docs` command generates a consolidated `docs/README.md` that serves as the single entry point for all project documentation, combining the architecture overview, key design decisions with ADR links, and a categorized capabilities index.

## Purpose

Without a central architecture document, understanding the system structure, technology choices, and key design decisions requires navigating across the constitution, individual specs, and archived design artifacts. A consolidated entry point gives developers and contributors a single place to understand the project and find detailed documentation.

## Rationale

The architecture overview is embedded in `docs/README.md` rather than generated as a separate file, eliminating unnecessary navigation between multiple index documents. The Key Design Decisions table links directly to individual ADR files and includes notable trade-offs, so readers can see both the decisions and their consequences without leaving the overview. Capabilities are grouped by workflow category using `order` and `category` metadata from baseline specs, producing a deterministic, project-specific table of contents that the skill itself does not need to hardcode. The README is only regenerated when capability docs, ADRs, or constitution content actually change, avoiding unnecessary overwrites and false update timestamps.

## Features

- **Consolidated README** — architecture overview, design decisions, and capabilities index in a single `docs/README.md`
- **System Architecture section** — describes the three-layer model (Constitution, Schema, Skills) from the constitution and specs
- **Tech Stack section** — extracted from the project constitution
- **Key Design Decisions table** — aggregates decisions from all archived design.md files with direct ADR links
- **Manual ADR support** — includes manually created ADRs (matching `adr-M*.md`) in the decisions table
- **Notable Trade-offs** — surfaces significant negative consequences from ADR Consequences sections
- **Conventions section** — project conventions from the constitution
- **Category-grouped capabilities** — capabilities ordered by workflow phase using spec frontmatter metadata
- **Concise capability descriptions** — each description is at most 80 characters or 15 words
- **Conditional regeneration** — README is only rebuilt when documentation content or constitution sections have changed
- **Stale file cleanup** — removes `docs/architecture-overview.md` and `docs/decisions/README.md` if they exist from previous runs
- **Language support** — all content can be generated in the language configured via `docs_language`

## Behavior

### Architecture Overview in Consolidated README

When you run `/opsx:docs`, the architecture overview content (System Architecture, Tech Stack, Key Design Decisions, Conventions) is written into `docs/README.md` along with the capabilities section — all in one file.

### Architecture Overview Without Design Artifacts

If no archived changes have design.md files, the architecture overview still includes System Architecture, Tech Stack, and Conventions sections, omitting Key Design Decisions.

### Design Decisions Table with ADR Links

Each row in the Key Design Decisions table includes an ADR column linking directly to the corresponding ADR file (for example, `[ADR-001](decisions/adr-001-slug.md)`).

### Manual ADRs in Design Decisions Table

Manual ADRs matching `docs/decisions/adr-M*.md` appear in the Key Design Decisions table after all generated ADRs. The agent extracts the Decision and Rationale from the manual ADR's `## Decision` and `## Rationale` sections.

### Notable Trade-offs

If ADR Consequences sections contain significant negative consequences, a Notable Trade-offs subsection surfaces trade-offs that affect documentation consumers or represent meaningful constraints. Every ADR with a substantive negative consequence is represented.

### Stale File Cleanup

If `docs/architecture-overview.md` or `docs/decisions/README.md` exist from a previous run, they are deleted during generation. This cleanup happens regardless of whether the README itself is regenerated.

### Conditional README Regeneration

The README is only regenerated when at least one of the following conditions is met: a capability doc was created or updated in this run, an ADR was created in this run, no `docs/README.md` exists yet (first run), or the constitution content (Tech Stack, Architecture Rules, Conventions) has diverged from the corresponding sections in the existing README. If none of these conditions apply, the README is skipped and a message reports it is up-to-date.

### Capabilities Grouped by Category

Capabilities appear under category group headers (for example, "Setup", "Change Workflow") based on the `category` frontmatter field from baseline specs. Within each category, capabilities are ordered by their `order` field.

### Capabilities Without Category

If a baseline spec has no `category` frontmatter, the capability appears under an "Other" group header.

### Concise Capability Descriptions

Each capability description in the table is one short phrase — at most 80 characters or 15 words.

### Architecture Overview in Configured Language

When `docs_language` is set to a non-English language, all section headings and descriptive content are translated. Table column headers in the Key Design Decisions table are also translated. Product names, commands, and file paths remain in English.

### Design Decisions Table Translated

When a non-English language is configured, column headers in the Key Design Decisions table are translated (for example, "Decision" becomes "Entscheidung" in German), while ADR link text like "ADR-001" remains in English.

## Known Limitations

- Does not detect spec-only changes without a new archive — the README is regenerated on the next archive that touches a related capability.
- Constitution drift detection compares key sections (Tech Stack, Architecture Rules, Conventions) but may miss subtle formatting-only changes.
- Does not generate a separate `docs/architecture-overview.md` or `docs/decisions/README.md` — the architecture overview and ADR discovery are always part of `docs/README.md`.

## Future Enhancements

- Preflight validation for decision granularity to prevent excessively fine-grained ADR entries at the source.

## Edge Cases

- If no constitution is found, the agent warns and skips architecture overview generation.
- If no three-layer-architecture spec exists, the agent generates a minimal System Architecture section from constitution Architecture Rules only.
- If an ADR has not yet been generated for a decision, the SKILL.md step ordering ensures ADRs are generated first, then referenced in the overview.
- If a manual ADR lacks `## Decision` or `## Rationale`, the agent uses the ADR title as the decision text and leaves the rationale column empty.
- Constitution content is always in English. The agent translates when generating the overview, not the constitution itself.
- Stale file cleanup runs even when README regeneration is skipped — the cleanup is independent of the conditional regeneration logic.
