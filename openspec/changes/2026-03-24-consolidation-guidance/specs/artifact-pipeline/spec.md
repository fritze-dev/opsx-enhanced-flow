---
order: 4
category: change-workflow
---

## ADDED Requirements

### Requirement: Capability Granularity Guidance
The proposal `instruction` in the schema SHALL include explicit rules defining what constitutes a capability versus a feature detail. A "capability" SHALL be defined as a cohesive domain of behavior that a user or system exercises independently, typically containing 3-8 requirements and mapping to one testable surface area. A "feature detail" SHALL be defined as a single behavior, option, or edge case within a capability that belongs as a requirement inside an existing spec, not as a separate spec. The instruction SHALL state that if two proposed capabilities share the same actor, trigger, or data model, they are likely one capability and SHOULD be merged. The instruction SHALL state that a proposed capability producing fewer than ~100 lines (1-2 requirements) SHOULD be folded into a related existing capability.

**User Story:** As a developer creating a proposal I want clear rules on what qualifies as a new capability, so that I create cohesive domain specs instead of micro-specs for individual feature details.

#### Scenario: Guidance defines capability vs feature detail
- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `proposal.instruction` field is inspected
- **THEN** it SHALL contain a definition distinguishing capabilities (cohesive behavior domains) from feature details (individual behaviors within a domain)
- **AND** it SHALL include heuristics for merging (shared actor/trigger/data model) and minimum scope (3+ requirements)

#### Scenario: Agent consolidates related feature details into one capability
- **GIVEN** a user requesting three related UX changes (pagination, clickable rows, status labels) for a table view
- **WHEN** the agent creates the proposal's Capabilities section
- **THEN** the agent SHALL list one capability (e.g., `table-view`) with the individual changes as requirements, not three separate capabilities

### Requirement: Mandatory Consolidation Check
The proposal `instruction` in the schema SHALL include a mandatory consolidation check that the agent MUST perform before finalizing the Capabilities section. The consolidation check SHALL require the agent to: (1) list all existing specs in `openspec/specs/` and read their Purpose sections, (2) for each proposed new capability, check whether an existing spec already covers the domain and use Modified Capabilities if so, (3) for each pair of proposed new capabilities, check whether they share an actor, trigger, or data model and merge them if so, and (4) verify each proposed capability will have 3 or more distinct requirements, folding single-requirement capabilities into related specs.

**User Story:** As a project maintainer I want the proposal stage to enforce a consolidation check against existing specs, so that spec fragmentation is caught at the earliest possible point rather than post-hoc in preflight.

#### Scenario: Consolidation check is present in proposal instruction
- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `proposal.instruction` field is inspected
- **THEN** it SHALL contain a mandatory consolidation check with steps for reviewing existing specs, checking domain overlap, checking pair-wise overlap between new capabilities, and verifying minimum requirement count

#### Scenario: Agent identifies overlap with existing spec
- **GIVEN** a proposal for a feature that overlaps with the existing `quality-gates` spec
- **WHEN** the agent performs the consolidation check
- **THEN** the agent SHALL classify the feature as a Modified Capability on `quality-gates` rather than a New Capability

#### Scenario: Agent merges overlapping new capabilities
- **GIVEN** a proposal listing `admin-pagination` and `admin-clickable-rows` as separate new capabilities
- **WHEN** the agent performs the consolidation check
- **THEN** the agent SHALL merge them into a single capability (e.g., `admin-table-view`) because they share the same actor and data context

### Requirement: Proposal Template Consolidation Check Section
The proposal template SHALL include a `### Consolidation Check` section between the Modified Capabilities subsection and the `## Impact` section. This section SHALL require the agent to document: which existing specs were reviewed, the overlap assessment for each new capability (closest existing spec and why this is distinct or why Modified was chosen), and the merge assessment for pairs of new capabilities. If no new capabilities are proposed, the section SHALL contain "N/A — no new specs proposed."

**User Story:** As a reviewer reading a proposal I want to see the agent's consolidation reasoning documented, so that I can verify the capability boundaries are well-considered before specs are created.

#### Scenario: Proposal template includes Consolidation Check section
- **GIVEN** the proposal template at `openspec/schemas/opsx-enhanced/templates/proposal.md`
- **WHEN** the template is inspected
- **THEN** it SHALL contain a `### Consolidation Check` section with instructions for documenting existing specs reviewed, overlap assessment, and merge assessment

#### Scenario: Agent fills Consolidation Check for new capabilities
- **GIVEN** a proposal introducing two new capabilities
- **WHEN** the agent creates the proposal
- **THEN** the Consolidation Check section SHALL list which existing specs were reviewed, state the closest existing spec for each new capability, and document whether any pair of new capabilities was merged

#### Scenario: Consolidation Check for modification-only proposals
- **GIVEN** a proposal that only modifies existing capabilities with no new capabilities
- **WHEN** the agent creates the proposal
- **THEN** the Consolidation Check section SHALL contain "N/A — no new specs proposed."

### Requirement: Specs Overlap Verification
The specs `instruction` in the schema SHALL include an overlap verification step that the agent MUST perform before creating any spec files. The verification SHALL require the agent to: (1) read the proposal's Consolidation Check section, (2) scan existing specs in `openspec/specs/` for requirements with overlapping scope (same actor, trigger, or data model) for each new capability, and (3) if overlap is found, STOP and reclassify the capability as a Modified Capability on the existing spec before proceeding. The agent SHALL update the proposal's Capabilities section to reflect the reclassification.

**User Story:** As a developer I want the specs creation stage to double-check for overlap before creating files, so that any consolidation opportunities missed during proposal creation are caught before spec files are written.

#### Scenario: Overlap verification is present in specs instruction
- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `specs.instruction` field is inspected
- **THEN** it SHALL contain an overlap verification step before the "Create one spec file per capability" instruction

#### Scenario: Agent catches overlap during specs creation
- **GIVEN** a proposal that listed `admin-filters` as a new capability, but the baseline `admin-table-view` spec already covers filter behavior
- **WHEN** the agent begins the specs artifact phase and performs overlap verification
- **THEN** the agent SHALL reclassify `admin-filters` as a Modified Capability on `admin-table-view` and update the proposal before creating the spec file

## Edge Cases

- If a project has zero existing specs (greenfield), the consolidation check still applies between proposed new capabilities but skip the existing-spec overlap scan.
- If an agent determines that an existing spec is too large (exceeding ~500 lines / 10+ requirements), it MAY propose splitting it rather than adding more requirements — but this should be documented as a conscious decision in the Consolidation Check section.
- If a proposed capability genuinely represents a new domain that shares no actor, trigger, or data model with existing specs, the consolidation check SHALL confirm this rather than force-merging.
- If the agent identifies overlap but the user explicitly requests separate specs (e.g., for team ownership reasons), the Consolidation Check SHALL document this decision with rationale.

## Assumptions

<!-- ASSUMPTION: Agent compliance with instruction-based guidance is sufficient. The Consolidation Check template section provides a reviewable artifact as enforcement. -->
No further assumptions beyond those marked above.
