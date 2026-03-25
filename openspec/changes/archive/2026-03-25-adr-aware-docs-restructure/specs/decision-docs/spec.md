## ADDED Requirements

### Requirement: ADR Discovery via Decisions Index
The `/opsx:docs` command SHALL generate a decisions index at `docs/decisions.md` as the canonical entry point for ADR discovery. This file replaces the previous inline ADR links in the consolidated `docs/README.md`. The agent SHALL NOT generate an ADR index at `docs/decisions/README.md` — the index lives in the parent directory at `docs/decisions.md`.

ADR discovery is handled via `docs/decisions.md`, not via inline links in `docs/README.md`. The decisions index is generated as part of Step 5b of the docs skill (owned by the architecture-docs spec). The decision-docs spec is responsible for defining that `docs/decisions.md` is the canonical ADR discovery mechanism.

**User Story:** As a developer I want a dedicated decisions index that I can open directly to browse all architectural decisions, so that I don't have to scroll through the main README or remember individual ADR file names.

#### Scenario: ADR discovery via decisions index
- **GIVEN** ADR files have been generated at `docs/decisions/adr-*.md`
- **WHEN** the developer wants to find an architectural decision
- **THEN** the developer opens `docs/decisions.md` which lists all decisions with rationale and links to individual ADR files

#### Scenario: No ADR index at docs/decisions/README.md
- **GIVEN** the `/opsx:docs` command runs
- **WHEN** the agent generates documentation
- **THEN** the agent does NOT create `docs/decisions/README.md`
- **AND** if `docs/decisions/README.md` exists from a previous run, the agent deletes it

## Edge Cases

- **decisions.md without any ADR files**: If no ADR files exist in `docs/decisions/`, `docs/decisions.md` is not generated (handled by architecture-docs spec conditional regeneration).
- **Transition from old format**: On first run after this change, `docs/README.md` loses its inline ADR table (moved to `docs/decisions.md`). No manual migration needed.

## Assumptions

- The decisions index generation logic is owned by the architecture-docs spec (Step 5b). This spec defines the policy (decisions.md is canonical), architecture-docs defines the implementation. <!-- ASSUMPTION: Ownership split between specs -->
