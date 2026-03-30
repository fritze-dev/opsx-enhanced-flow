## ADDED Requirements

### Requirement: Agent-Driven Spec Merging
The `/opsx:sync` command SHALL use an agent-driven approach to merge delta specs from a completed change into their corresponding baseline specs under `openspec/specs/<capability>/spec.md`. The merge process SHALL be performed by the AI agent interpreting the delta operations (ADDED, MODIFIED, REMOVED, RENAMED) and applying them intelligently to the existing baseline content. The system SHALL NOT use programmatic string manipulation or mechanical find-and-replace merging. The agent SHALL read both the delta spec and the current baseline, understand the semantic intent of each operation, and produce a coherent merged result. If a baseline spec does not yet exist for a capability, the agent SHALL create it from the delta content.

**User Story:** As a developer I want spec syncing to be handled by the AI agent rather than a script, so that merges are context-aware and produce coherent, well-structured baseline specs even when deltas are complex or overlapping.

#### Scenario: Sync ADDED requirements into existing baseline
- **GIVEN** a completed change with a delta spec containing `## ADDED Requirements` for capability `user-auth`
- **WHEN** the developer runs `/opsx:sync`
- **THEN** the agent reads the existing baseline at `openspec/specs/user-auth/spec.md`, appends the new requirements under `## Requirements`, and writes the updated baseline without duplicating existing content

#### Scenario: Sync creates new baseline from delta
- **GIVEN** a completed change with a delta spec for capability `data-export` that has no existing baseline in `openspec/specs/`
- **WHEN** the agent processes the delta during `/opsx:sync`
- **THEN** the agent creates `openspec/specs/data-export/spec.md` with `## Purpose` and `## Requirements` sections derived from the delta content

#### Scenario: Sync MODIFIED requirements replaces existing requirement
- **GIVEN** a baseline spec containing `### Requirement: Session Timeout` with a 30-minute timeout
- **AND** a delta spec with `## MODIFIED Requirements` changing the timeout to 15 minutes with updated scenarios
- **WHEN** the agent performs the merge
- **THEN** the baseline requirement is replaced with the full updated content from the delta, preserving all other unmodified requirements

#### Scenario: Sync REMOVED requirements deletes from baseline
- **GIVEN** a baseline spec containing `### Requirement: Legacy Export`
- **AND** a delta spec with `## REMOVED Requirements` listing `Legacy Export` with a reason and migration path
- **WHEN** the agent performs the merge
- **THEN** the requirement is removed from the baseline and the agent confirms the removal in its output

### Requirement: Intelligent Partial Updates
The `/opsx:sync` process SHALL support adding individual scenarios, edge cases, or assumptions to existing requirements without requiring the delta to copy the entire requirement block. A delta spec SHALL represent the author's intent — not a wholesale replacement of the baseline. When a delta adds a new scenario to an existing requirement, the agent SHALL locate that requirement in the baseline and append the scenario without disturbing existing scenarios or the requirement's normative description. The agent SHALL resolve conflicts by preferring the delta's intent while preserving baseline content that the delta does not address.

**User Story:** As a spec author I want to add a single scenario to an existing requirement without copying the entire requirement into my delta, so that delta specs stay minimal and focused on what actually changed.

#### Scenario: Add scenario to existing requirement without full copy
- **GIVEN** a baseline spec with `### Requirement: User Login` containing two scenarios
- **AND** a delta spec that references `### Requirement: User Login` and adds only `#### Scenario: Login with expired password`
- **WHEN** the agent syncs the delta into the baseline
- **THEN** the baseline retains the original two scenarios and gains the new third scenario under the same requirement

#### Scenario: Add edge case to existing spec
- **GIVEN** a baseline spec with an `## Edge Cases` section containing two items
- **AND** a delta spec that adds a third edge case under `## Edge Cases`
- **WHEN** the agent syncs the delta
- **THEN** the baseline `## Edge Cases` section contains all three items without duplicating the original two

#### Scenario: Delta intent preserved over mechanical merge
- **GIVEN** a delta spec that refines the normative description of an existing requirement to add a new constraint
- **AND** the baseline contains the original description
- **WHEN** the agent merges
- **THEN** the merged description includes both the original content and the new constraint, integrated naturally rather than appended verbatim

### Requirement: Baseline Format Enforcement
After sync, all merged baseline specs SHALL conform to the baseline format: a `## Purpose` section followed by a `## Requirements` section. Baseline specs SHALL NOT contain delta operation prefixes such as `ADDED`, `MODIFIED`, `REMOVED`, or `RENAMED` in their section headers. The agent SHALL strip these prefixes during the merge and organize all requirements under a single `## Requirements` heading. Each requirement in the baseline SHALL maintain the strict ordering: `### Requirement: <name>` header, normative description, optional User Story, and `#### Scenario:` blocks.

**User Story:** As a developer reading baseline specs I want them to have a clean, consistent format without delta operation markers, so that baselines serve as a clear, authoritative reference for what the system does today.

#### Scenario: Operation prefixes stripped during sync
- **GIVEN** a delta spec with sections `## ADDED Requirements` and `## MODIFIED Requirements`
- **WHEN** the agent merges the delta into the baseline
- **THEN** the resulting baseline contains a single `## Requirements` section with no `ADDED` or `MODIFIED` prefixes in any heading

#### Scenario: Purpose section present in merged baseline
- **GIVEN** a new capability being synced for the first time from a delta spec
- **WHEN** the agent creates the baseline
- **THEN** the baseline begins with a `## Purpose` section that summarizes the capability's role, followed by `## Requirements`

#### Scenario: Requirement ordering preserved in baseline
- **GIVEN** a baseline with three requirements in a specific order
- **AND** a delta that modifies the second requirement and adds a fourth
- **WHEN** the agent syncs
- **THEN** the merged baseline preserves the original order for existing requirements and appends new requirements at the end, each following the strict format (header, description, optional User Story, scenarios)

## Edge Cases

- **Conflicting modifications**: Two changes modify the same requirement differently. The agent SHALL flag the conflict and ask the user to resolve it rather than silently overwriting.
- **Empty delta sections**: A delta spec contains `## MODIFIED Requirements` with no content beneath it. The agent SHALL ignore empty sections and not alter the baseline.
- **Baseline does not exist and delta has MODIFIED operations**: The agent SHALL treat MODIFIED operations on a non-existent baseline as errors and report them to the user.
- **Renamed requirement with references**: If a requirement is renamed, other specs or documents referencing the old name are not automatically updated. The agent SHALL warn about potential stale references.
- **Concurrent changes**: Two changes in flight modify the same capability. The second sync SHALL detect that the baseline has changed since the delta was authored and prompt for re-review.

## Assumptions

- The agent has read access to both `openspec/specs/` (baselines) and `openspec/changes/<feature>/specs/` (deltas) at sync time. <!-- ASSUMPTION: Agent operates within the project working directory -->
- Only one sync operation runs at a time; there is no concurrent merge protection beyond sequential execution. <!-- ASSUMPTION: Single-agent workflow — no parallel syncs -->
- Sync is an explicit workflow step after approval and before archive (apply → QA → sync → archive). Archive retains a safety-net prompt for unsynced delta specs. <!-- ASSUMPTION: Sync is invoked explicitly by the user, archive prompts only as fallback -->
