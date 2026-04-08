---
order: 14
category: reference
status: stable
version: 1
lastModified: 2026-04-08
---
## Purpose

Defines the format rules for specifications including normative descriptions with RFC 2119 keywords, User Stories, Gherkin scenarios, and spec structure.

## Requirements

### Requirement: Normative Description Format
Every requirement SHALL have a normative description as its primary content, placed immediately after the `### Requirement: <name>` header. The normative description SHALL use RFC 2119 keywords (SHALL, MUST, SHOULD, MAY) to express obligation levels. The normative description is the formal, binding specification of the requirement. An optional User Story MAY follow the normative description using the format `**User Story:** As a [role] I want [goal], so that [benefit]`. The description MUST always come before the User Story; reversing this order is a format violation.

**User Story:** As a spec author I want a clear ordering rule for requirement content, so that every spec has a consistent structure where the binding requirement always comes first.

#### Scenario: Requirement with description and User Story
- **GIVEN** a spec author writing a new requirement
- **WHEN** they create the requirement block
- **THEN** the normative description using SHALL/MUST SHALL appear immediately after the `### Requirement:` header, followed optionally by the User Story

#### Scenario: Requirement with description only
- **GIVEN** a purely technical or non-functional requirement
- **WHEN** the spec author omits the User Story
- **THEN** the requirement SHALL still be valid with just the normative description and scenarios

#### Scenario: User Story placed before description is rejected
- **GIVEN** a spec where the User Story appears before the normative description
- **WHEN** the spec is reviewed during preflight
- **THEN** the preflight check SHALL flag this as a format violation requiring correction

### Requirement: Gherkin Scenario Format
Every requirement SHALL have at least one scenario using Gherkin format. Scenarios SHALL use the heading `#### Scenario: <name>` with exactly 4 hashtags. Each scenario SHALL contain GIVEN (preconditions), WHEN (trigger/action), and THEN (expected outcome) clauses formatted as bold-prefixed list items: `- **GIVEN** ...`, `- **WHEN** ...`, `- **THEN** ...`. Using 3 hashtags for scenarios SHALL be treated as a silent failure -- the scenario will render as a subsection heading instead of a scenario block, breaking automated parsing.

**User Story:** As a developer I want scenarios in a strict Gherkin format with enforced heading levels, so that scenarios are both human-readable and machine-parseable for test generation.

#### Scenario: Correctly formatted scenario
- **GIVEN** a requirement with a scenario using `#### Scenario:` (4 hashtags)
- **WHEN** the scenario block is parsed
- **THEN** the system SHALL recognize it as a valid scenario with GIVEN, WHEN, and THEN clauses

#### Scenario: Scenario with wrong heading level fails silently
- **GIVEN** a requirement where a scenario uses `### Scenario:` (3 hashtags) instead of `####`
- **WHEN** the spec is processed
- **THEN** the scenario SHALL be misinterpreted as a requirement-level heading, and the GIVEN/WHEN/THEN content SHALL be orphaned from its intended scenario context

#### Scenario: Multiple scenarios per requirement
- **GIVEN** a requirement that has three distinct behavioral cases
- **WHEN** the spec author writes three scenarios
- **THEN** each scenario SHALL use `#### Scenario: <unique name>` and all three SHALL be associated with the parent requirement

#### Scenario: AND clauses in Gherkin steps
- **GIVEN** a scenario that requires multiple preconditions
- **WHEN** the spec author needs to express additional conditions
- **THEN** they SHALL use `- **AND** ...` after the relevant GIVEN, WHEN, or THEN clause to add supplementary conditions

### Requirement: Spec Frontmatter Metadata
Specs MAY include an optional YAML frontmatter block at the top of the file, delimited by `---` lines. The frontmatter SHALL support the following fields:

**Documentation fields** (optional):
- `order` (integer): Display position in documentation TOC. Lower values appear first. The `order` value SHALL be assigned during spec creation and persisted in the spec. The `/opsx:docs` command SHALL read this value to determine capability ordering.
- `category` (string, kebab-case): Workflow phase grouping for documentation TOC. Standard categories are: `setup`, `change-workflow`, `development`, `finalization`, `reference`, `meta`. Projects MAY define custom categories. The `/opsx:docs` command SHALL use this value to render category group headers in the capabilities table.

**Tracking fields** (managed by skills):
- `status` (string, `stable` or `draft`): Indicates whether the spec is actively being edited by a change. Default: `stable`. Skills SHALL set `status: draft` when modifying a spec during the specs stage and flip back to `stable` during verify completion.
- `change` (string): The change directory name (e.g., `2026-04-08-spec-frontmatter-tracking`) that is currently editing this spec. SHALL only be present when `status: draft`. Skills SHALL remove this field when flipping to `stable`.
- `version` (integer): Monotonically increasing version number. Starts at `1` on creation. Skills SHALL increment by 1 each time a change modifies the spec and completes successfully (during verify completion).
- `lastModified` (string, `YYYY-MM-DD`): The date the spec was last modified. Skills SHALL set this to the current date when editing the spec during the specs stage and again during verify completion.

The `order` and `category` fields are optional. If `order` is absent, `/opsx:docs` SHALL fall back to agent-determined ordering. If `category` is absent, the capability SHALL appear in an "Other" group. The tracking fields (`status`, `version`, `lastModified`) are optional for backward compatibility — skills SHALL handle their absence gracefully by treating missing `status` as `stable`, missing `version` as `1`, and missing `lastModified` as requiring regeneration.

The frontmatter block SHALL appear before the `## Purpose` section. Existing spec content (Purpose, Requirements, Edge Cases, Assumptions) SHALL remain unchanged.

**User Story:** As a project maintainer I want deterministic ordering in docs, change-level tracking for collision detection, and version-based incremental detection, so that skills can reliably identify which specs are affected by a change without fragile text parsing.

#### Scenario: Spec with documentation frontmatter
- **GIVEN** a spec at `openspec/specs/quality-gates/spec.md`
- **AND** the spec has frontmatter with `order: 8` and `category: development`
- **WHEN** `/opsx:docs` generates the capabilities table
- **THEN** quality-gates appears at position 8, under a "Development" group header

#### Scenario: Spec without frontmatter falls back gracefully
- **GIVEN** a spec with no YAML frontmatter
- **WHEN** `/opsx:docs` generates the capabilities table
- **THEN** the capability appears in an "Other" group with agent-determined ordering

#### Scenario: Frontmatter assigned during spec creation
- **GIVEN** a new capability being specified during the specs artifact phase
- **WHEN** the agent creates the spec at `openspec/specs/<capability>/spec.md`
- **THEN** the spec SHALL include frontmatter with `order`, `category`, `status: draft`, `change`, `version: 1`, and `lastModified` values

#### Scenario: Tracking fields set during spec editing
- **GIVEN** a stable spec at `openspec/specs/quality-gates/spec.md` with `status: stable` and `version: 3`
- **WHEN** a change edits this spec during the specs stage
- **THEN** the frontmatter SHALL be updated to `status: draft`, `change: <change-dir>`, and `lastModified: <today>`
- **AND** `version` SHALL remain `3` (not bumped until completion)

#### Scenario: Tracking fields reset during verify completion
- **GIVEN** a spec with `status: draft`, `change: 2026-04-08-my-change`, and `version: 3`
- **WHEN** verify completion runs for that change
- **THEN** the frontmatter SHALL be updated to `status: stable`, `change` field removed, `version: 4`, and `lastModified: <today>`

#### Scenario: Collision detection via draft status
- **GIVEN** a spec with `status: draft` and `change: 2026-04-08-feature-a`
- **WHEN** a different change (`2026-04-08-feature-b`) attempts to edit the same spec
- **THEN** the agent SHALL detect the conflict via mismatched `change` values
- **AND** SHALL warn the user about the collision before proceeding

#### Scenario: Missing tracking fields treated as defaults
- **GIVEN** a spec with only `order` and `category` in frontmatter (no tracking fields)
- **WHEN** a skill reads the spec
- **THEN** the skill SHALL treat the spec as `status: stable`, `version: 1`, and `lastModified` as unset (requiring regeneration)

### Requirement: Spec Format
Specs (specs at `openspec/specs/<capability>/spec.md`) SHALL use a `## Purpose` section followed by a `## Requirements` section. Each requirement SHALL follow the standard format: `### Requirement: <name>`, normative description, optional User Story, and `#### Scenario:` blocks.

**User Story:** As a developer reading the specs I want a clean format without change-tracking prefixes, so that I see the current state of requirements clearly.

#### Scenario: Spec structure
- **GIVEN** a spec for the `project-setup` capability
- **WHEN** the spec file is opened
- **THEN** it SHALL contain a `## Purpose` section describing the capability, followed by a `## Requirements` section with all current requirements

#### Scenario: Requirements follow standard format
- **GIVEN** a requirement within a spec
- **WHEN** the requirement block is inspected
- **THEN** it SHALL have a `### Requirement:` header, normative description, optional User Story, and one or more `#### Scenario:` blocks

### Requirement: Assumption Marker Format

Specs and design artifacts SHALL mark assumptions as a visible list item describing the assumption, followed by an HTML comment tag for machine parsing. The format SHALL be: `- Visible assumption text. <!-- ASSUMPTION: short tag -->`. The visible text SHALL be a complete, readable statement of the assumption. The HTML comment tag SHALL be a brief identifier for preflight grep.

Assumptions written entirely inside an HTML comment with no visible text (e.g., `<!-- ASSUMPTION: full text here -->`) are invisible in Markdown preview and SHALL be flagged as format violations during preflight.

The `## Assumptions` section at the end of specs and design documents SHALL collect all assumptions using this format. If no assumptions were made, the section SHALL state "No assumptions made."

**User Story:** As a reviewer I want assumptions to be visible in Markdown preview, so that I can audit them during review without reading raw source.

#### Scenario: Assumption written in correct format
- **GIVEN** a spec author documenting an assumption about external API behavior
- **WHEN** they write the assumption in the `## Assumptions` section
- **THEN** it SHALL use the format `- External API returns paginated results. <!-- ASSUMPTION: Pagination support -->`
- **AND** the text "External API returns paginated results." SHALL be visible in GitHub and IDE Markdown preview

#### Scenario: Invisible assumption is flagged as format violation
- **GIVEN** a spec containing only `<!-- ASSUMPTION: External API returns paginated results -->`
- **AND** no visible list item accompanies the HTML comment tag
- **WHEN** the spec is reviewed during preflight
- **THEN** the preflight check SHALL flag the invisible assumption as a format violation

#### Scenario: No assumptions section states explicitly
- **GIVEN** a spec where the author made no assumptions
- **WHEN** the `## Assumptions` section is written
- **THEN** it SHALL contain the text "No assumptions made." instead of being left empty

## Edge Cases

- If a requirement has zero scenarios, the spec SHALL be considered invalid and flagged during preflight.
- If two specs share the same `order` value, `/opsx:docs` SHALL use alphabetical capability name as tiebreaker.
- If a `category` value is not one of the standard categories, `/opsx:docs` SHALL still render it as a group header using title-case formatting.
- If a spec has `status: draft` but no `change` field, the spec SHALL be treated as having an unknown change owner — preflight SHALL flag this as a warning.
- If a spec has `status: stable` with a `change` field present, the `change` field SHALL be ignored (stale data).

## Assumptions

- YAML frontmatter parsing in markdown is supported by the agent reading the spec file. <!-- ASSUMPTION: Standard markdown convention, widely supported -->
No further assumptions beyond those marked above.
