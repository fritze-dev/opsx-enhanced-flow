---
order: 5
category: change-workflow
---

## MODIFIED Requirements

### Requirement: Step-by-Step Generation
The system SHALL provide `/opsx:continue` as the command for generating one artifact at a time. When invoked, continue SHALL determine which artifact is next in the pipeline by querying the OpenSpec CLI for the current change status, then generate exactly that one artifact using the schema's instruction and template. After generation, continue SHALL report what was generated and what the next step is. If all artifacts are already complete, continue SHALL inform the user that the pipeline is finished and suggest proceeding to `/opsx:apply`. At routine transitions (research to proposal, proposal to specs, specs to design, preflight to tasks), continue SHALL auto-continue to the next artifact without pausing for confirmation. At mandatory-pause checkpoints (after design for user review, after preflight with warnings for acknowledgment), continue SHALL pause and wait for explicit user input before proceeding. When creating specs artifacts, continue SHALL verify the proposal's Consolidation Check confirms no overlap with existing specs before creating spec files.

**User Story:** As a developer I want to advance the pipeline one step at a time, so that I can review each artifact and provide feedback before moving to the next stage.

#### Scenario: Generate next artifact in sequence
- **GIVEN** a change workspace where research.md and proposal.md are complete
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate the specs artifact(s) as the next pending stage, then report completion and indicate design as the next step

#### Scenario: All artifacts already complete
- **GIVEN** a change workspace where all 6 pipeline artifacts have been generated
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL report that all artifacts are complete and suggest running `/opsx:apply` to begin implementation

#### Scenario: Continue respects dependency gating
- **GIVEN** a change workspace where research.md is complete but proposal.md is missing (e.g., manually deleted)
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate proposal.md as the next required artifact, not skip ahead to specs

#### Scenario: Continue auto-continues through routine transitions
- **GIVEN** a change workspace where research.md has just been generated
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate research.md and immediately proceed to generate proposal.md without pausing for confirmation
- **AND** SHALL report both artifacts as generated

#### Scenario: Continue pauses at design review checkpoint
- **GIVEN** a change workspace where specs have been generated and design is the next artifact
- **WHEN** the user runs `/opsx:continue`
- **THEN** the system SHALL generate design.md
- **AND** SHALL pause for user review before proceeding to preflight
- **AND** SHALL display the design for the user to evaluate

#### Scenario: Continue verifies consolidation before creating specs
- **GIVEN** a change workspace where the proposal lists a new capability that overlaps with an existing spec
- **WHEN** the user runs `/opsx:continue` and the specs artifact is next
- **THEN** the system SHALL verify the proposal's Consolidation Check section before creating spec files
- **AND** SHALL flag any unresolved overlap before proceeding

## Edge Cases

- If the proposal has no Consolidation Check section (e.g., created before this change), the continue skill SHALL proceed without the consolidation verification step and rely on the specs instruction's overlap verification instead.

## Assumptions

<!-- ASSUMPTION: The continue skill's Artifact Creation Guidelines are supplementary to the schema instructions. Both are read by the agent when creating artifacts. -->
No further assumptions beyond those marked above.
