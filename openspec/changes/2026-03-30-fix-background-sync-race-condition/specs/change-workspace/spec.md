## MODIFIED Requirements

### Requirement: Archive Completed Change

The system SHALL move a completed change workspace to `openspec/changes/archive/` with a date-prefixed directory name in the format `YYYY-MM-DD-<change-name>` when the user invokes `/opsx:archive`. Before archiving, the system SHALL automatically sync delta specs to baseline specs if unsynced delta specs exist, showing a summary of applied changes. The system SHALL NOT prompt the user to choose between syncing and archiving. When sync is delegated to a subagent, the subagent prompt SHALL convey that sync is a blocking prerequisite for archive and that the result MUST be returned before the workflow continues. After the sync agent returns, the archive skill SHALL validate sync completion by checking file system state: for each delta spec capability at `openspec/changes/<name>/specs/<capability>/`, a corresponding baseline spec MUST exist at `openspec/specs/<capability>/spec.md`. The system SHALL NOT proceed to archive unless all delta spec capabilities have corresponding baseline specs. If the archive target directory already exists, the system SHALL fail with an error and suggest a resolution.

**User Story:** As a developer I want completed changes archived with a date prefix and automatic spec sync, so that the project history is preserved chronologically and baseline specs stay up to date without unnecessary prompts.

#### Scenario: Archive a completed change

- **GIVEN** a change named "add-user-auth" with all artifacts and tasks complete
- **AND** no delta specs exist in the change
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system moves `openspec/changes/add-user-auth/` to `openspec/changes/archive/2026-03-02-add-user-auth/`
- **AND** displays a summary including change name, schema, and archive location

#### Scenario: Auto-sync before archiving

- **GIVEN** a change named "add-user-auth" with delta specs in `openspec/changes/add-user-auth/specs/`
- **AND** the delta specs have not been synced to baseline
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL invoke sync via a subagent whose prompt conveys that sync is a blocking prerequisite
- **AND** SHALL wait for the sync agent to return its result
- **AND** SHALL validate sync completion by checking that `openspec/specs/user-auth/spec.md` exists
- **AND** SHALL display a summary of applied changes (additions, modifications, removals)
- **AND** SHALL proceed to archive only after validation passes

#### Scenario: State-based validation prevents premature archive

- **GIVEN** a change with delta specs for capabilities "user-auth" and "data-export"
- **WHEN** the sync subagent returns
- **THEN** the archive skill SHALL check that `openspec/specs/user-auth/spec.md` exists
- **AND** SHALL check that `openspec/specs/data-export/spec.md` exists
- **AND** SHALL NOT proceed to the archive step (mv to archive directory) until all checks pass

#### Scenario: Baseline spec missing after sync

- **GIVEN** a change with a delta spec for capability "user-auth"
- **WHEN** the sync subagent returns
- **AND** `openspec/specs/user-auth/spec.md` does not exist
- **THEN** the archive skill SHALL report which capabilities are missing baseline specs
- **AND** SHALL NOT proceed to archive

#### Scenario: Archive with incomplete artifacts

- **GIVEN** a change with some artifacts not marked as done
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL display a warning listing the incomplete artifacts
- **AND** SHALL ask the user to confirm before proceeding
- **AND** SHALL archive if the user confirms

#### Scenario: Archive target already exists

- **GIVEN** a change named "add-user-auth"
- **AND** an archive already exists at `openspec/changes/archive/2026-03-02-add-user-auth/`
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL fail with an error
- **AND** SHALL suggest renaming the existing archive or using a different date

#### Scenario: Archive with incomplete tasks

- **GIVEN** a change with a tasks.md containing 3 of 7 checkboxes marked complete
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL display a warning showing "3/7 tasks complete"
- **AND** SHALL ask the user to confirm before proceeding

## Edge Cases

- **Baseline spec already existed before sync:** If the baseline spec already existed (e.g., MODIFIED delta), the existence check still passes — the sync updated it in place. The check validates that sync didn't fail to create new specs, not that it modified existing ones correctly (content correctness is the sync skill's responsibility).

## Assumptions

No new assumptions.
