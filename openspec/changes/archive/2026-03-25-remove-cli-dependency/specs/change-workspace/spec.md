---
order: 3
category: change-workflow
---

## MODIFIED Requirements

### Requirement: Create Change Workspace

The system SHALL create a change workspace when the user invokes `/opsx:new <change-name>`. The workspace SHALL be created by running `mkdir -p openspec/changes/<name>`. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

**User Story:** As a developer I want to create a new change workspace with a single command, so that I can immediately begin the spec-driven workflow without manual directory setup.

#### Scenario: Create workspace with explicit name

- **GIVEN** no change named "add-user-auth" exists
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system creates the directory `openspec/changes/add-user-auth/`
- **AND** the system reads schema.yaml to determine the artifact pipeline and displays the artifact status and first artifact template

#### Scenario: Derive name from description

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

The created workspace SHALL contain the artifacts defined by the active schema. The artifact pipeline sequence SHALL be determined by the schema definition in `openspec/schemas/opsx-enhanced/schema.yaml` (e.g., research, proposal, specs, design, preflight, tasks for the `opsx-enhanced` schema). Each artifact SHALL have a defined dependency chain that gates progression from one stage to the next.

**User Story:** As a developer I want the workspace to be pre-structured according to the workflow schema, so that I know exactly which artifacts need to be produced and in what order.

#### Scenario: Workspace contains schema-defined structure

- **GIVEN** the user creates a new change
- **WHEN** the workspace is created
- **THEN** the directory `openspec/changes/<name>/` SHALL exist
- **AND** reading schema.yaml and checking file existence SHALL report all pipeline artifacts as pending

#### Scenario: Artifact dependency gating

- **GIVEN** a workspace created with the `opsx-enhanced` schema
- **WHEN** the user checks artifact status before creating any artifacts
- **THEN** only the first artifact in the pipeline (research) SHALL have status "ready"
- **AND** downstream artifacts (proposal, specs, design, preflight, tasks) SHALL be blocked by unmet dependencies

## Edge Cases

- **No active changes**: If no active changes exist when archiving, the system SHALL inform the user and suggest creating a new change.
- **Multiple active changes**: If multiple changes exist and the user does not specify which to archive, the system SHALL list available changes and ask the user to select one. It SHALL NOT auto-select.

## Assumptions

- The system clock provides the correct date for the YYYY-MM-DD prefix. <!-- ASSUMPTION: System clock accuracy -->
- The file system supports the mv operation atomically within the same mount point. <!-- ASSUMPTION: Atomic mv -->
No further assumptions beyond those marked above.
