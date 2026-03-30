# Change Workspace

## ADDED Requirements

### Requirement: Create Change Workspace

The system SHALL create a scaffolded change workspace when the user invokes `/opsx:new <change-name>`. The workspace SHALL be created by delegating to the OpenSpec CLI command `openspec new change "<name>"`. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

<!-- ASSUMPTION: The OpenSpec CLI is installed and accessible on the PATH, as ensured by /opsx:init -->

**User Story:** As a developer I want to create a new change workspace with a single command, so that I can immediately begin the spec-driven workflow without manual directory setup.

#### Scenario: Create workspace with explicit name

- **GIVEN** the OpenSpec CLI is installed and no change named "add-user-auth" exists
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system runs `openspec new change "add-user-auth"`
- **AND** a directory is created at `openspec/changes/add-user-auth/`
- **AND** the system displays the artifact status and first artifact template

#### Scenario: Derive name from description

- **GIVEN** the OpenSpec CLI is installed
- **WHEN** the user invokes `/opsx:new` and provides the description "add user authentication"
- **THEN** the system derives the kebab-case name `add-user-auth`
- **AND** creates the workspace at `openspec/changes/add-user-auth/`

#### Scenario: Reject invalid name format

- **GIVEN** the user provides a name containing uppercase letters or special characters (e.g., "Add_User Auth")
- **WHEN** the system attempts to create the workspace
- **THEN** the system SHALL ask the user for a valid kebab-case name
- **AND** SHALL NOT create the workspace until a valid name is provided

#### Scenario: Change name already exists

- **GIVEN** a change named "add-user-auth" already exists at `openspec/changes/add-user-auth/`
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL NOT create a duplicate workspace
- **AND** SHALL suggest continuing the existing change instead

### Requirement: Workspace Structure

The created workspace SHALL contain the artifacts defined by the active schema. The workspace MUST include an `.openspec.yaml` manifest that records the schema used and creation metadata. The artifact pipeline sequence SHALL be determined by the schema definition (e.g., research, proposal, specs, design, preflight, tasks for the `opsx-enhanced` schema). Each artifact SHALL have a defined dependency chain that gates progression from one stage to the next.

**User Story:** As a developer I want the workspace to be pre-structured according to the workflow schema, so that I know exactly which artifacts need to be produced and in what order.

#### Scenario: Workspace contains schema-defined structure

- **GIVEN** the user creates a new change using the default `opsx-enhanced` schema
- **WHEN** the workspace is created
- **THEN** the directory `openspec/changes/<name>/` SHALL exist
- **AND** an `.openspec.yaml` file SHALL be present recording the schema name and version
- **AND** `openspec status --change "<name>"` SHALL report all pipeline artifacts as pending

#### Scenario: Artifact dependency gating

- **GIVEN** a workspace created with the `opsx-enhanced` schema
- **WHEN** the user checks artifact status before creating any artifacts
- **THEN** only the first artifact in the pipeline (research) SHALL have status "ready"
- **AND** downstream artifacts (proposal, specs, design, preflight, tasks) SHALL be blocked by unmet dependencies

#### Scenario: Custom schema selection

- **GIVEN** the user explicitly requests a different schema via `--schema <name>`
- **WHEN** the workspace is created
- **THEN** the workspace SHALL follow the artifact structure defined by the specified schema
- **AND** `.openspec.yaml` SHALL record the chosen schema name

### Requirement: Archive Completed Change

The system SHALL move a completed change workspace to `openspec/changes/archive/` with a date-prefixed directory name in the format `YYYY-MM-DD-<change-name>` when the user invokes `/opsx:archive`. Before archiving, the system SHALL assess delta spec sync state and prompt the user to sync if unsynced delta specs exist. The system SHALL NOT silently archive without informing the user of the sync opportunity. If the archive target directory already exists, the system SHALL fail with an error and suggest a resolution.

<!-- ASSUMPTION: The system clock provides the correct date for the YYYY-MM-DD prefix -->

**User Story:** As a developer I want completed changes archived with a date prefix and a sync prompt, so that the project history is preserved chronologically and baseline specs stay up to date.

#### Scenario: Archive a completed change

- **GIVEN** a change named "add-user-auth" with all artifacts and tasks complete
- **AND** no delta specs exist in the change
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system moves `openspec/changes/add-user-auth/` to `openspec/changes/archive/2026-03-02-add-user-auth/`
- **AND** displays a summary including change name, schema, and archive location

#### Scenario: Prompt for sync before archiving

- **GIVEN** a change named "add-user-auth" with delta specs in `openspec/changes/add-user-auth/specs/`
- **AND** the delta specs have not been synced to baseline
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL analyze delta specs and show a summary of pending changes
- **AND** SHALL prompt with options: "Sync now (recommended)" or "Archive without syncing"
- **AND** SHALL proceed to archive regardless of the user's sync choice

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

- **No active changes**: If `openspec list` returns no active changes when archiving, the system SHALL inform the user and suggest creating a new change.
- **Multiple active changes**: If multiple changes exist and the user does not specify which to archive, the system SHALL list available changes and ask the user to select one. It SHALL NOT auto-select.
- **Empty workspace**: A workspace with no artifacts created (all pending) can still be archived if the user confirms the warning.
- **Interrupted archive**: If the `mv` command fails mid-operation (e.g., disk full), the workspace SHALL remain in its original location. The system SHALL report the error.
- **Archive directory does not exist**: The system SHALL create `openspec/changes/archive/` if it does not already exist before moving the change.

## Assumptions

<!-- ASSUMPTION: The file system supports the mv operation atomically within the same mount point -->
<!-- ASSUMPTION: Date format YYYY-MM-DD is always unambiguous and sorts chronologically -->
<!-- ASSUMPTION: The user running the archive command has write permissions to the openspec/changes/ directory -->
