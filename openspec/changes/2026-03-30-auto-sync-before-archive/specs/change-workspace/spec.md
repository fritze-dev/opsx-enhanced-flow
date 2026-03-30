## MODIFIED Requirements

### Requirement: Archive Completed Change

The system SHALL move a completed change workspace to `openspec/changes/archive/` with a date-prefixed directory name in the format `YYYY-MM-DD-<change-name>` when the user invokes `/opsx:archive`. Before archiving, the system SHALL automatically sync delta specs to baseline specs if unsynced delta specs exist, showing a summary of applied changes. The system SHALL NOT prompt the user to choose between syncing and archiving. If the archive target directory already exists, the system SHALL fail with an error and suggest a resolution.

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
- **THEN** the system SHALL automatically invoke sync to apply delta specs to baseline
- **AND** SHALL display a summary of applied changes (additions, modifications, removals)
- **AND** SHALL proceed to archive after sync completes

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

- **Delta specs already synced:** When delta specs exist but are already in sync with baseline, the auto-sync is a no-op. The system proceeds to archive without additional output.
- **Sync failure:** If the sync operation fails, the system SHALL report the error and stop. It SHALL NOT proceed to archive with unsynced specs.

## Assumptions

No assumptions made.
