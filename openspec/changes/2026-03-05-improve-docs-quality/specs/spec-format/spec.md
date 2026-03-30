## ADDED Requirements

### Requirement: Spec Frontmatter Metadata
Baseline specs MAY include an optional YAML frontmatter block at the top of the file, delimited by `---` lines. The frontmatter SHALL support the following fields:
- `order` (integer): Display position in documentation TOC. Lower values appear first. The `order` value SHALL be assigned during spec creation (bootstrap or artifact pipeline) and persisted in the baseline spec after sync. The `/opsx:docs` command SHALL read this value to determine capability ordering.
- `category` (string, kebab-case): Workflow phase grouping for documentation TOC. Standard categories are: `setup`, `change-workflow`, `development`, `finalization`, `reference`, `meta`. Projects MAY define custom categories. The `/opsx:docs` command SHALL use this value to render category group headers in the capabilities table.

Both fields are optional. If `order` is absent, `/opsx:docs` SHALL fall back to agent-determined ordering. If `category` is absent, the capability SHALL appear in an "Other" group.

The frontmatter block SHALL appear before the `## Purpose` section. Existing spec content (Purpose, Requirements, Edge Cases, Assumptions) SHALL remain unchanged.

**User Story:** As a project maintainer I want deterministic, project-specific ordering and grouping of capabilities in generated documentation, so that the TOC follows my project's workflow sequence and stays consistent across doc regeneration runs.

#### Scenario: Baseline spec with frontmatter
- **GIVEN** a baseline spec at `openspec/specs/quality-gates/spec.md`
- **AND** the spec has frontmatter with `order: 8` and `category: development`
- **WHEN** `/opsx:docs` generates the capabilities table
- **THEN** quality-gates appears at position 8, under a "Development" group header

#### Scenario: Baseline spec without frontmatter falls back gracefully
- **GIVEN** a baseline spec with no YAML frontmatter
- **WHEN** `/opsx:docs` generates the capabilities table
- **THEN** the capability appears in an "Other" group with agent-determined ordering

#### Scenario: Frontmatter assigned during spec creation in artifact pipeline
- **GIVEN** a new capability being specified during the specs artifact phase
- **WHEN** the agent creates the delta spec
- **THEN** the delta spec SHALL include frontmatter with `order` and `category` values that position the new capability appropriately among existing capabilities

#### Scenario: Frontmatter preserved during sync
- **GIVEN** a baseline spec with existing frontmatter (`order: 5`, `category: change-workflow`)
- **AND** a delta spec that modifies a requirement but does not change the frontmatter
- **WHEN** `/opsx:sync` merges the delta into the baseline
- **THEN** the existing frontmatter values SHALL be preserved

## Edge Cases

- If a delta spec includes frontmatter that conflicts with the baseline frontmatter, the delta values SHALL take precedence (the change is intentionally reordering the capability).
- If two specs share the same `order` value, `/opsx:docs` SHALL use alphabetical capability name as tiebreaker.
- If a `category` value is not one of the standard categories, `/opsx:docs` SHALL still render it as a group header using title-case formatting.

## Assumptions

- YAML frontmatter parsing in markdown is supported by the agent reading the spec file. <!-- ASSUMPTION: Standard markdown convention, widely supported -->
- The `/opsx:sync` agent can handle frontmatter blocks when merging delta specs into baselines. <!-- ASSUMPTION: Agent-driven sync is intelligent enough to preserve/merge frontmatter -->
