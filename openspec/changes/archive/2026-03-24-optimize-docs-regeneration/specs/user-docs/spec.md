---
order: 16
category: meta
---

## MODIFIED Requirements

### Requirement: Incremental Capability Documentation Generation
The `/opsx:docs` command SHALL support incremental generation by default. Before generating each capability doc, the agent SHALL determine whether regeneration is needed by comparing archive dates against the doc's `lastUpdated` frontmatter field.

**Change detection logic:** For each capability, the agent SHALL:
1. Read the existing `docs/capabilities/<capability>.md` and extract the `lastUpdated` value from YAML frontmatter. If the file does not exist, the capability needs generation.
2. Glob `openspec/changes/archive/*/specs/<capability>/` to find all archives that touched this capability.
3. Extract the date prefix (`YYYY-MM-DD`) from each matching archive directory name.
4. If ANY archive date is newer than (or equal to) the doc's `lastUpdated`, the capability needs regeneration.
5. If no archive date is newer, skip this capability entirely.

**First run:** When no capability docs exist yet, all capabilities SHALL be generated (equivalent to full generation).

**Single-capability mode:** When the user provides a single capability name argument (e.g., `/opsx:docs auth`), the agent SHALL only read archives matching that capability's glob pattern — not archives for other capabilities. The specified capability SHALL always be regenerated regardless of dates.

**Multi-capability mode:** When the user provides multiple capability names as a comma-separated list (e.g., `/opsx:docs artifact-pipeline,artifact-generation`), the agent SHALL process only the listed capabilities. Each listed capability SHALL always be regenerated regardless of archive dates (same as single-capability mode). The agent SHALL NOT perform the full archive date scan for unlisted capabilities. Archives SHALL only be read for the listed capabilities. If a listed capability does not exist in `openspec/specs/`, the agent SHALL warn and skip it. This mode is designed for the post-archive workflow where the caller already knows which capabilities were affected.

**Content-aware writes:** After generating a capability doc, the agent SHALL compare the generated content against the existing file content, excluding the `lastUpdated` frontmatter field. If the content is identical, the agent SHALL NOT write the file and SHALL NOT bump the `lastUpdated` timestamp. This prevents false timestamp updates when regeneration produces unchanged output.

**Output summary:** The agent SHALL report which capabilities were regenerated, which were skipped (no newer archives), and which had unchanged content (regenerated but not written).

**User Story:** As a user I want `/opsx:docs` to only regenerate documentation for capabilities that have new archive data, so that unchanged docs are not touched and timestamps remain accurate.

#### Scenario: Capability skipped when no newer archives exist
- **GIVEN** `docs/capabilities/release-workflow.md` exists with `lastUpdated: "2026-03-20"`
- **AND** all archives touching `release-workflow` have date prefixes of `2026-03-04` or earlier
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent skips `release-workflow` and does not read its archives or regenerate its doc

#### Scenario: Capability regenerated when newer archive exists
- **GIVEN** `docs/capabilities/user-docs.md` exists with `lastUpdated: "2026-03-05"`
- **AND** a new archive `2026-03-23-improve-docs-efficiency/specs/user-docs/` exists
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent regenerates `docs/capabilities/user-docs.md`

#### Scenario: First run generates all capabilities
- **GIVEN** no capability doc files exist under `docs/capabilities/`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent generates documentation for all capabilities

#### Scenario: Content-aware write prevents false timestamp bump
- **GIVEN** `docs/capabilities/change-workspace.md` exists with `lastUpdated: "2026-03-20"`
- **AND** a newer archive touches `change-workspace` but only changes assumption comments in the spec
- **WHEN** the agent regenerates the capability doc
- **AND** the generated content (excluding `lastUpdated`) is identical to the existing file
- **THEN** the agent does NOT write the file and `lastUpdated` remains `"2026-03-20"`

#### Scenario: Single-capability mode scopes archive reading
- **GIVEN** the developer runs `/opsx:docs release-workflow`
- **WHEN** the agent looks up archive enrichment
- **THEN** the agent only reads archives matching `openspec/changes/archive/*/specs/release-workflow/`
- **AND** the agent does NOT read archives for other capabilities

#### Scenario: Multi-capability mode processes only listed capabilities
- **GIVEN** the developer runs `/opsx:docs artifact-pipeline,artifact-generation`
- **WHEN** the agent performs change detection
- **THEN** the agent processes only `artifact-pipeline` and `artifact-generation`
- **AND** both capabilities are always regenerated regardless of archive dates
- **AND** the agent does NOT scan archives for the other 16 capabilities

#### Scenario: Multi-capability mode with nonexistent capability
- **GIVEN** the developer runs `/opsx:docs artifact-pipeline,nonexistent-cap`
- **WHEN** the agent processes the list
- **THEN** the agent regenerates `artifact-pipeline`
- **AND** the agent warns that `nonexistent-cap` does not exist in `openspec/specs/` and skips it

#### Scenario: Output summary shows skipped and unchanged capabilities
- **GIVEN** 18 capabilities exist, 2 have newer archives, and 1 of those produces identical content
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the output shows 1 capability regenerated, 1 skipped (unchanged content), and 16 skipped (no newer archives)

## Edge Cases

- If an empty string is provided as argument (e.g., `/opsx:docs ""`), the agent SHALL treat it as no argument and perform the full incremental scan.
- If the comma-separated list contains duplicates (e.g., `/opsx:docs auth,auth`), the agent SHALL deduplicate and process each capability only once.
- If the comma-separated list contains whitespace around names (e.g., `/opsx:docs auth , export`), the agent SHALL trim whitespace from each capability name.

## Assumptions

<!-- ASSUMPTION: The post-archive workflow caller (agent or user) can determine affected capabilities from the archived change's specs/ directory and pass them as arguments. -->
No further assumptions beyond those marked above.
