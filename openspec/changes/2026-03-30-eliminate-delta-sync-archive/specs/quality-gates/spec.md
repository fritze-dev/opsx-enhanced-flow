## MODIFIED Requirements

### Requirement: Preflight Quality Check

The system SHALL run a mandatory quality review before task creation when the user invokes `/opsx:preflight`. The Traceability Matrix (dimension A) SHALL map each capability listed in the proposal to its corresponding baseline spec at `openspec/specs/<capability>/spec.md`, verifying that the spec has been updated to reflect the proposed changes. For modified capabilities, the agent SHALL compare the spec's current state against the proposal's description of what changes were made, using git diff against the base branch if available to identify which requirements were added, modified, or removed.

#### Scenario: Traceability checks baseline specs directly

- **GIVEN** a change with a proposal listing modified capability "user-auth"
- **AND** the baseline spec at `openspec/specs/user-auth/spec.md` has been edited during the specs stage
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the Traceability Matrix maps the proposal capability "user-auth" to the baseline spec
- **AND** verifies that the spec contains the changes described in the proposal

#### Scenario: Traceability detects missing spec update

- **GIVEN** a change with a proposal listing a new capability "data-export"
- **AND** no spec file exists at `openspec/specs/data-export/spec.md`
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the Traceability Matrix flags "data-export" as missing
- **AND** the verdict is "BLOCKED"

### Requirement: Post-Implementation Verification

The system SHALL verify the implementation against change artifacts when the user invokes `/opsx:verify`. Verification SHALL assess three dimensions: Completeness (task completion and spec coverage), Correctness (requirement implementation accuracy and scenario coverage), and Coherence (design adherence and code pattern consistency). The system SHALL read baseline specs at `openspec/specs/<capability>/spec.md` for the capabilities listed in the change's proposal to verify implementation against.

#### Scenario: Verification with all checks passing

- **GIVEN** a change "add-user-auth" with all tasks complete
- **AND** all spec requirements in `openspec/specs/user-auth/spec.md` are implemented
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system produces a verification report
- **AND** the final assessment is "All checks passed."

#### Scenario: Verification with no specs to verify

- **GIVEN** a change that has tasks but the proposal lists no capability modifications
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system skips requirement-level verification
- **AND** focuses on task completion and code pattern coherence

### Requirement: Documentation Drift Verification

The system SHALL verify that generated documentation accurately reflects the current state of specs when the user invokes `/opsx:docs-verify`. For the ADRs vs Design Decisions dimension, the system SHALL scan all completed change directories in `openspec/changes/*/design.md` for Decisions tables and verify that each decision has a corresponding ADR.

#### Scenario: ADR check scans change directories

- **GIVEN** a project with completed changes at `openspec/changes/2026-03-02-initial-spec/` and `openspec/changes/2026-03-04-doc-ecosystem/`
- **AND** both contain `design.md` with Decisions tables
- **WHEN** the user invokes `/opsx:docs-verify`
- **THEN** the system reads `design.md` from both change directories
- **AND** verifies each decision has a corresponding ADR

## Edge Cases

- **No change selected**: If no change name is provided and multiple active changes exist, the system SHALL prompt the user to select one.
- **Verify on change with no tasks**: If tasks.md does not exist, verify SHALL report the missing artifact and suggest generating it.

## Assumptions

- Baseline specs in `openspec/specs/` reflect the latest state including edits made during the current change's specs stage. <!-- ASSUMPTION: Specs stage edits committed -->
No further assumptions beyond those marked above.
