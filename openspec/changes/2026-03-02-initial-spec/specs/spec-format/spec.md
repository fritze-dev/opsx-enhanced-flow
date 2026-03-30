## ADDED Requirements

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

### Requirement: Delta Spec Operations
Delta specs (specs within `openspec/changes/<feature>/specs/`) SHALL use operation-prefixed section headers to indicate the type of change. The supported operations SHALL be: `## ADDED Requirements` for new capabilities, `## MODIFIED Requirements` for changes to existing capabilities, `## REMOVED Requirements` for deprecated capabilities, and `## RENAMED Requirements` for name-only changes. MODIFIED requirements MUST include the full updated content of the requirement (not partial diffs), because partial content loses detail when the delta is archived into the baseline. REMOVED requirements MUST include a `**Reason**` and a `**Migration**` path. RENAMED requirements SHALL use `FROM: <old name>` / `TO: <new name>` format.

**User Story:** As a spec maintainer I want delta specs to clearly categorize changes by operation type, so that the sync process can correctly merge deltas into baseline specs.

#### Scenario: Delta spec with ADDED requirements
- **GIVEN** a new feature that introduces two new capabilities
- **WHEN** the delta spec is created
- **THEN** both new requirements SHALL appear under the `## ADDED Requirements` section

#### Scenario: Delta spec with MODIFIED requirements
- **GIVEN** an existing requirement whose behavior is changing
- **WHEN** the delta spec is created for the modification
- **THEN** the full updated requirement (header, description, User Story if present, and all scenarios) SHALL appear under `## MODIFIED Requirements`

#### Scenario: Delta spec with REMOVED requirements
- **GIVEN** a requirement that is being deprecated
- **WHEN** the delta spec is created for the removal
- **THEN** the requirement SHALL appear under `## REMOVED Requirements` with a `**Reason**` explaining why and a `**Migration**` path for users

#### Scenario: MODIFIED with partial content is flagged
- **GIVEN** a delta spec where a MODIFIED requirement only includes the changed scenario and omits the normative description
- **WHEN** the spec is reviewed during preflight
- **THEN** the preflight check SHALL flag the partial content as a risk, because archiving will replace the full baseline requirement with the incomplete delta

### Requirement: Baseline Spec Format
Baseline specs (specs at `openspec/specs/<capability>/spec.md`) SHALL use a `## Purpose` section followed by a `## Requirements` section. Baseline specs SHALL NOT use operation prefixes (ADDED, MODIFIED, REMOVED, RENAMED) because they represent the current merged state of all requirements, not a set of changes. Each requirement within the baseline SHALL follow the same format as delta specs: `### Requirement: <name>`, normative description, optional User Story, and `#### Scenario:` blocks.

**User Story:** As a developer reading the baseline specs I want a clean format without change-tracking prefixes, so that I see the current state of requirements without historical delta noise.

#### Scenario: Baseline spec structure
- **GIVEN** a merged baseline spec for the `project-setup` capability
- **WHEN** the spec file is opened
- **THEN** it SHALL contain a `## Purpose` section describing the capability, followed by a `## Requirements` section with all current requirements

#### Scenario: Baseline does not use operation prefixes
- **GIVEN** a baseline spec that has been synced from multiple delta specs
- **WHEN** the spec file content is inspected
- **THEN** the section header SHALL be `## Requirements` (not `## ADDED Requirements` or any operation prefix)

#### Scenario: Baseline requirements follow standard format
- **GIVEN** a requirement within a baseline spec
- **WHEN** the requirement block is inspected
- **THEN** it SHALL have a `### Requirement:` header, normative description, optional User Story, and one or more `#### Scenario:` blocks, following the same format rules as delta specs

## Edge Cases

- If a delta spec contains both ADDED and MODIFIED sections, the sync process SHALL handle each operation independently -- adding new requirements and updating existing ones.
- If a delta spec uses an unrecognized operation prefix (e.g., `## UPDATED Requirements`), the sync process SHALL flag it as an error and refuse to merge.
- If a requirement in a delta spec has zero scenarios, the spec SHALL be considered invalid and flagged during preflight.
- If the same requirement name appears in both ADDED and MODIFIED sections of the same delta spec, this SHALL be treated as a conflict and flagged during preflight.
- If a RENAMED requirement's `TO:` name conflicts with an existing requirement in the baseline, the sync process SHALL flag the naming collision.

## Assumptions

<!-- ASSUMPTION: The OpenSpec CLI's programmatic archive merge expects baseline specs to use `## Purpose` + `## Requirements` format. This assumption is based on the research findings about CLI merge behavior. -->
<!-- ASSUMPTION: The sync process (`/opsx:sync`) is agent-driven and performs intelligent merging, so it can handle the delta operation semantics described here without requiring exact programmatic parsing. -->
No further assumptions beyond those marked above.
