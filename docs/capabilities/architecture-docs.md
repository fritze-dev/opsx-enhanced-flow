---
title: "Architecture Documentation"
capability: "architecture-docs"
description: "Cross-cutting architecture overview as part of the consolidated docs/README.md"
lastUpdated: "2026-03-05"
---

# Architecture Documentation

The `/opsx:docs` command generates a cross-cutting architecture overview as part of the consolidated `docs/README.md`, synthesized from the project constitution, the three-layer-architecture spec, and archived design decisions.

## Purpose

Understanding a project's architecture typically requires reading the constitution, schema, multiple design documents, and scattered decision records. Without a synthesized overview, new contributors must piece together the architecture from fragments. This capability produces a single, coherent view of system architecture, tech stack, key decisions, and conventions.

## Rationale

The architecture overview is embedded in `docs/README.md` rather than generated as a separate file to provide a single entry point for all documentation. Key Design Decisions include direct ADR links so readers can drill into the reasoning behind each decision without searching for the relevant record.

## Features

- System Architecture section describing the three-layer model
- Tech Stack section from the constitution
- Key Design Decisions table aggregating decisions across all archived changes
- ADR column linking directly to corresponding Architecture Decision Records
- Notable trade-offs surfaced from ADR Consequences sections
- Conventions section from the constitution
- Fully regenerated on each `/opsx:docs` run

## Behavior

### Architecture Overview Generation

When you run `/opsx:docs`, the system reads the constitution, the three-layer-architecture spec, and all Decisions tables from archived design.md files. It synthesizes this into the architecture section of `docs/README.md`, covering system architecture, tech stack, key decisions with ADR links, and conventions.

### Key Design Decisions

The system aggregates all decisions from archived design.md files into a deduplicated table. Each row includes an ADR link column pointing to the corresponding ADR file. If a decision has significant negative consequences, the trade-off is mentioned as a note in the table or in a Notable Trade-offs subsection.

### Stale File Cleanup

If `docs/architecture-overview.md` exists from a previous run, the system deletes it. The architecture overview now lives exclusively in `docs/README.md`.

## Known Limitations

- Does not generate a separate architecture document — all content is embedded in `docs/README.md`

## Edge Cases

- If the constitution is not found, the system warns you and skips architecture overview generation.
- If the three-layer-architecture spec is missing, the system generates a minimal System Architecture section from constitution Architecture Rules only.
- If no archived changes have design.md files, the Key Design Decisions section is omitted.
