## MODIFIED Requirements

### Requirement: Standalone Research with Q&A

The following scenario is updated to reference `/opsx:setup` instead of `/opsx:init`:

#### Scenario: Prerequisite check fails

- **GIVEN** the OpenSpec CLI is not installed or the opsx-enhanced schema is not registered
- **WHEN** the user invokes `/opsx:discover`
- **THEN** the system runs `openspec schema which opsx-enhanced --json`
- **AND** the command fails
- **AND** the system tells the user to run `/opsx:setup` first and stops

## Edge Cases

No changes to edge cases.

## Assumptions

No assumptions changed.
