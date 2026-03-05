# ADR-024: Consolidated README replaces 3 separate files

## Status
Accepted (2026-03-05)

## Context
The documentation output had three files serving overlapping purposes: `docs/README.md` (thin table of contents), `docs/architecture-overview.md` (system architecture, tech stack, key decisions), and `docs/decisions/README.md` (ADR index that duplicated the architecture overview's Key Design Decisions table). Users had to navigate between three files to get a complete picture of the project. Research confirmed that the architecture overview IS the natural entry point for documentation, and the ADR index is simply a table that fits within the overview. Consolidating into a single `docs/README.md` eliminates navigation hops and creates one authoritative entry point. Consumer projects need automated migration from the 3-file to 1-file structure.

## Decision
Consolidate `docs/README.md`, `docs/architecture-overview.md`, and `docs/decisions/README.md` into a single `docs/README.md` entry point.

## Rationale
Eliminates navigation hops. The architecture overview IS the entry point, and the ADR index is just a table that fits within it.

## Alternatives Considered
- Keep separate files with better cross-linking — still requires maintaining 3 files and navigating between them

## Consequences

### Positive
- Single entry point for all documentation
- No duplicate content across multiple index files
- Simpler navigation for users

### Negative
- Breaking external links to `docs/architecture-overview.md` and `docs/decisions/README.md`; low impact since docs are internal to the repo

## References
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [ADR-025: Cleanup step in SKILL.md deletes stale files](adr-025-cleanup-step-in-skill-md-deletes-stale-files.md)
