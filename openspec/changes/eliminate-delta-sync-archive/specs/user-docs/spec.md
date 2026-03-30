## MODIFIED Requirements

### Requirement: Generate Enriched Capability Documentation

Additionally, when generating a capability doc, the agent SHALL look up completed change directories at `openspec/changes/*/` to find changes whose `proposal.md` Capabilities section lists the capability being documented. For each relevant change found, the agent SHALL read `proposal.md`, `research.md`, `design.md`, and `preflight.md` (where they exist) and enrich the capability doc with Purpose, Rationale, Known Limitations, and Future Enhancements sections as previously specified.

#### Scenario: Enriched doc with change data

- **GIVEN** a baseline spec exists at `openspec/specs/release-workflow/spec.md`
- **AND** a completed change at `openspec/changes/2026-03-04-release-workflow/` has a proposal listing `release-workflow` in its Capabilities section
- **AND** the change contains `design.md` with Non-Goals and `preflight.md` with an Assumption Audit
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the generated `docs/capabilities/release-workflow.md` includes enriched sections derived from the change's artifacts

#### Scenario: Capability with no relevant changes falls back to spec-only

- **GIVEN** a baseline spec exists at `openspec/specs/new-feature/spec.md`
- **AND** no completed change directory contains a proposal listing `new-feature`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the generated doc contains Overview, Features, Behavior, and Edge Cases sections only — no enriched sections

### Requirement: Incremental Capability Documentation Generation

The `/opsx:docs` command SHALL support incremental generation by default. Before generating each capability doc, the agent SHALL determine whether regeneration is needed by comparing change dates against the doc's `lastUpdated` frontmatter field.

**Change detection logic:** For each capability, the agent SHALL:
1. Read the existing `docs/capabilities/<capability>.md` and extract the `lastUpdated` value from YAML frontmatter. If the file does not exist, the capability needs generation.
2. Scan completed change directories at `openspec/changes/*/proposal.md` to find changes whose Capabilities section lists this capability.
3. Extract the date prefix (`YYYY-MM-DD`) from each matching change directory name.
4. If ANY change date is newer than (or equal to) the doc's `lastUpdated`, the capability needs regeneration.
5. If no change date is newer, skip this capability entirely.

**First run:** When no capability docs exist yet, all capabilities SHALL be generated.

**Single-capability mode:** When the user provides a single capability name argument, the agent SHALL only read changes relevant to that capability. The specified capability SHALL always be regenerated regardless of dates.

**Multi-capability mode:** When the user provides multiple capability names as a comma-separated list, the agent SHALL process only the listed capabilities. Each listed capability SHALL always be regenerated. This mode is designed for the post-apply workflow where the caller already knows which capabilities were affected.

**User Story:** As a user I want `/opsx:docs` to only regenerate documentation for capabilities that have newer completed changes, so that unchanged docs are not touched and timestamps remain accurate.

#### Scenario: Capability skipped when no newer changes exist

- **GIVEN** `docs/capabilities/release-workflow.md` exists with `lastUpdated: "2026-03-20"`
- **AND** all completed changes listing `release-workflow` in their proposals have date prefixes of `2026-03-04` or earlier
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent skips `release-workflow`

#### Scenario: Capability regenerated when newer change exists

- **GIVEN** `docs/capabilities/user-docs.md` exists with `lastUpdated: "2026-03-05"`
- **AND** a completed change `2026-03-23-improve-docs-efficiency/` has a proposal listing `user-docs`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent regenerates `docs/capabilities/user-docs.md`

## Edge Cases

- **No baseline specs exist**: If `openspec/specs/` is empty, the agent SHALL inform the user and suggest editing specs first.
- **Proposal without Capabilities section**: If a completed change's proposal lacks a Capabilities section, skip it for incremental detection.
- **Change directory without proposal.md**: Skip it for enrichment without error.

## Assumptions

- Baseline specs in `openspec/specs/` are the source of truth for documentation generation. <!-- ASSUMPTION: Docs generated from current specs -->
- Completed changes follow `YYYY-MM-DD-<feature-name>` naming under `openspec/changes/`. <!-- ASSUMPTION: Naming enforced by new skill -->
- The proposal's Capabilities section reliably indicates which specs were affected by a change. <!-- ASSUMPTION: Proposal-spec traceability -->
