## MODIFIED Requirements

### Requirement: End-to-End Install and Update Checklist

The project spec SHALL document the complete happy path for plugin installation and updates as testable scenarios: marketplace add -> install -> setup -> bootstrap, and marketplace update -> plugin update -> verify. This ensures the full flow is exercised and regressions are caught.

**User Story:** As a maintainer I want a testable checklist for the full install/update flow, so that I can verify the entire pipeline works end-to-end.

#### Scenario: Clean install flow

- **GIVEN** a clean project without the plugin installed
- **WHEN** the maintainer tests the install flow
- **THEN** `claude plugin marketplace add fritze-dev/opsx-enhanced-flow` SHALL succeed
- **AND** `claude plugin install opsx@opsx-enhanced-flow` SHALL succeed
- **AND** `/opsx:setup` SHALL install the schema and create config files
- **AND** `/opsx:bootstrap` SHALL generate constitution and initial specs

#### Scenario: Update flow after new version

- **GIVEN** a project with the plugin installed at version N
- **AND** a new version N+1 has been pushed
- **WHEN** the maintainer tests the update flow
- **THEN** `claude plugin marketplace update opsx-enhanced-flow` SHALL refresh the listing
- **AND** `claude plugin update opsx@opsx-enhanced-flow` SHALL detect and install version N+1
- **AND** `/opsx:setup` SHALL run idempotently without errors

## Edge Cases

No changes to edge cases.

## Assumptions

No assumptions changed.
