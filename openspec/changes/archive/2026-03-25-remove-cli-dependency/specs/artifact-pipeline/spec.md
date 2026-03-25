---
order: 4
category: change-workflow
---

## MODIFIED Requirements

### Requirement: Artifact Dependencies
Each artifact in the pipeline SHALL declare its dependencies explicitly in the schema. The dependency declaration SHALL list which preceding artifacts MUST be complete before the artifact can be generated. Skills SHALL enforce these dependencies by reading schema.yaml and checking artifact completion status via file existence before allowing generation of a dependent artifact. An artifact SHALL be considered complete when its corresponding file exists and is non-empty in the change workspace. For artifacts with glob patterns in the `generates` field (e.g., `specs/**/*.md`), completion SHALL be determined by at least one matching file existing.

**User Story:** As a developer I want the system to enforce artifact dependencies automatically, so that I cannot accidentally generate a design before the specs are written.

#### Scenario: Dependency check passes
- **GIVEN** a change workspace with completed research.md and proposal.md
- **WHEN** the system checks dependencies for the specs artifact
- **THEN** the dependency check SHALL pass because both research and proposal (the transitive chain) are complete

#### Scenario: Dependency check fails
- **GIVEN** a change workspace with only research.md completed
- **WHEN** the system checks dependencies for the design artifact
- **THEN** the dependency check SHALL fail and report that proposal and specs must be completed first

#### Scenario: Schema declares dependencies explicitly
- **GIVEN** the `schema.yaml` file
- **WHEN** the artifact definitions are inspected
- **THEN** each artifact SHALL have a `requires` field listing its direct dependencies by artifact ID

#### Scenario: Artifact status computed from file existence
- **GIVEN** a change workspace with research.md and proposal.md present
- **WHEN** a skill computes artifact status by reading schema.yaml
- **THEN** research and proposal SHALL be marked as "done", specs as "ready", and design/preflight/tasks as "blocked"

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system SHALL treat it as incomplete and not satisfy dependency checks.
- If a user manually deletes an artifact file mid-pipeline, the system SHALL detect the gap and require regeneration before proceeding.
- If multiple spec files are required (one per capability), the specs stage SHALL not be considered complete until at least one spec file exists under `specs/`.

## Assumptions

- Artifact completion is determined by file existence and non-empty content, not by content validation or quality assessment. <!-- ASSUMPTION: File-existence-based completion -->
No further assumptions beyond those marked above.
