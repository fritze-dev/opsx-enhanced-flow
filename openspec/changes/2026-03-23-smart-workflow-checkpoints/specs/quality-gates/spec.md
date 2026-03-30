## MODIFIED Requirements

### Requirement: Preflight Quality Check

The system SHALL run a mandatory quality review before task creation when the user invokes `/opsx:preflight`. The preflight check SHALL cover six dimensions: (A) Traceability Matrix -- mapping every requirement to scenarios and components, (B) Gap Analysis -- identifying missing edge cases, error handling, and empty states, (C) Side-Effect Analysis -- assessing impact on existing systems and regression risks, (D) Constitution Check -- verifying consistency with project rules in constitution.md, (E) Duplication and Consistency -- detecting overlaps and contradictions across specs, and (F) Assumption Audit -- rating every `<!-- ASSUMPTION -->` marker as Acceptable Risk, Needs Clarification, or Blocking. The system SHALL produce a `preflight.md` artifact containing findings and a verdict of PASS, PASS WITH WARNINGS, or BLOCKED. The system SHALL NOT auto-fix issues; it SHALL report findings for the user to resolve. The system SHALL NOT proceed to task creation if blockers are found. If the verdict is PASS WITH WARNINGS, the system SHALL pause and require explicit user acknowledgment of the warnings before proceeding to task creation. The system SHALL NOT auto-accept warnings or continue without the user reviewing each warning.

<!-- ASSUMPTION: All change artifacts (specs, design) are available and up to date when preflight is invoked -->

**User Story:** As a developer I want a thorough quality review of my specs and design before tasks are created, so that implementation is based on complete, consistent, and well-traced requirements.

#### Scenario: Preflight passes with no issues

- **GIVEN** a change named "add-user-auth" with complete specs and design artifacts
- **AND** all requirements have scenarios, no gaps are detected, and no assumptions are blocking
- **WHEN** the user invokes `/opsx:preflight add-user-auth`
- **THEN** the system reads constitution.md, all change artifacts, and existing baseline specs
- **AND** produces `preflight.md` covering all six dimensions
- **AND** the verdict is "PASS"
- **AND** the summary shows 0 blockers, 0 warnings

#### Scenario: Preflight finds blocking issues

- **GIVEN** a change with a spec requirement that has no scenario
- **AND** an assumption marked as `<!-- ASSUMPTION: External API rate limit is 1000/min -->` that has not been verified
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the traceability matrix flags the requirement as missing scenario coverage
- **AND** the assumption audit rates the API rate limit assumption as "Needs Clarification"
- **AND** the verdict is "BLOCKED"
- **AND** the system informs the user that issues must be resolved before proceeding to tasks

#### Scenario: Preflight detects contradiction with constitution

- **GIVEN** a design.md that proposes adding a project-level package.json
- **AND** the constitution states "Package manager: npm (global installs only -- no project-level package.json)"
- **WHEN** the system runs the Constitution Check
- **THEN** the system flags a contradiction between design.md and the constitution
- **AND** classifies it as a blocker
- **AND** recommends either updating the design to comply or updating the constitution if the rule should change

#### Scenario: Preflight with warnings requires user acknowledgment

- **GIVEN** a change where all requirements have scenarios and no assumptions are blocking
- **BUT** a minor gap is detected (missing error handling for an unlikely edge case)
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the verdict is "PASS WITH WARNINGS"
- **AND** each warning is listed with a recommendation
- **AND** the system SHALL pause and ask the user to acknowledge each warning
- **AND** the system SHALL NOT proceed to task creation until the user explicitly confirms

#### Scenario: Required artifacts missing

- **GIVEN** a change where specs exist but design.md has not been created
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the system SHALL abort the preflight
- **AND** SHALL report which required artifacts are missing
- **AND** SHALL suggest running `/opsx:continue` or `/opsx:ff` to generate them
