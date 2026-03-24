## MODIFIED Requirements

### Requirement: Preflight Quality Check

The system SHALL run a mandatory quality review before task creation when the user invokes `/opsx:preflight`. The preflight check SHALL cover six dimensions: (A) Traceability Matrix -- mapping every requirement to scenarios and components, (B) Gap Analysis -- identifying missing edge cases, error handling, and empty states, (C) Side-Effect Analysis -- assessing impact on existing systems and regression risks, (D) Constitution Check -- verifying consistency with project rules in constitution.md, (E) Duplication and Consistency -- detecting overlaps and contradictions across specs, and (F) Marker Audit -- auditing all assumption and review markers from spec.md and design.md. The Marker Audit SHALL:
1. Collect all `<!-- ASSUMPTION: ... -->` tags and verify each has an accompanying visible list item. Assumptions written entirely inside HTML comments (no visible text) SHALL be flagged as format violations.
2. Rate each valid assumption as Acceptable Risk, Needs Clarification, or Blocking.
3. Scan for any remaining `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers. Any REVIEW marker found SHALL be rated as Blocking, because REVIEW markers must be resolved before implementation.

The system SHALL produce a `preflight.md` artifact containing findings and a verdict of PASS, PASS WITH WARNINGS, or BLOCKED. The system SHALL NOT auto-fix issues; it SHALL report findings for the user to resolve. The system SHALL NOT proceed to task creation if blockers are found. If the verdict is PASS WITH WARNINGS, the system SHALL pause and require explicit user acknowledgment of the warnings before proceeding to task creation. The system SHALL NOT auto-accept warnings or continue without the user reviewing each warning.

- All change artifacts (specs, design) are available and up to date when preflight is invoked. <!-- ASSUMPTION: Artifact availability -->

**User Story:** As a developer I want a thorough quality review of my specs and design before tasks are created, so that implementation is based on complete, consistent, and well-traced requirements with no unresolved markers.

#### Scenario: Preflight passes with no issues

- **GIVEN** a change named "add-user-auth" with complete specs and design artifacts
- **AND** all requirements have scenarios, no gaps are detected, all assumptions have visible text, and no REVIEW markers remain
- **WHEN** the user invokes `/opsx:preflight add-user-auth`
- **THEN** the system reads constitution.md, all change artifacts, and existing baseline specs
- **AND** produces `preflight.md` covering all six dimensions
- **AND** the verdict is "PASS"
- **AND** the summary shows 0 blockers, 0 warnings

#### Scenario: Preflight finds invisible assumption

- **GIVEN** a change with a spec containing `<!-- ASSUMPTION: External API rate limit is 1000/min -->` with no visible list item
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the Marker Audit flags the invisible assumption as a format violation
- **AND** the verdict is "BLOCKED"
- **AND** the system recommends adding visible text: `- External API rate limit is 1000/min. <!-- ASSUMPTION: API rate limit -->`

#### Scenario: Preflight finds unresolved REVIEW marker

- **GIVEN** a change where design.md contains `<!-- REVIEW: confirm caching strategy -->`
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the Marker Audit flags the REVIEW marker as Blocking
- **AND** the verdict is "BLOCKED"
- **AND** the system informs the user that REVIEW markers must be resolved before proceeding

#### Scenario: Preflight detects contradiction with constitution

- **GIVEN** a design.md that proposes adding a project-level package.json
- **AND** the constitution states "Package manager: npm (global installs only -- no project-level package.json)"
- **WHEN** the system runs the Constitution Check
- **THEN** the system flags a contradiction between design.md and the constitution
- **AND** classifies it as a blocker
- **AND** recommends either updating the design to comply or updating the constitution if the rule should change

#### Scenario: Preflight with warnings requires user acknowledgment

- **GIVEN** a change where all requirements have scenarios, all assumptions have visible text, and no REVIEW markers remain
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

### Requirement: Post-Implementation Verification

The system SHALL verify the implementation against change artifacts when the user invokes `/opsx:verify`. Verification SHALL assess three dimensions: Completeness (task completion and spec coverage), Correctness (requirement implementation accuracy and scenario coverage), and Coherence (design adherence and code pattern consistency). Each issue found SHALL be classified as CRITICAL (must fix before archive), WARNING (should fix), or SUGGESTION (nice to fix). The system SHALL produce a verification report with a summary scorecard, issues grouped by priority, and specific actionable recommendations with file and line references where applicable. The system SHALL err on the side of lower severity when uncertain (SUGGESTION over WARNING, WARNING over CRITICAL).

The `/opsx:verify` command SHALL serve as both the initial verification (tasks.md step 3.2) and the final verification (step 3.5) in the QA loop. When invoked as a final verify after the fix loop, the command SHALL operate identically — checking completeness, correctness, and coherence against the current state of code and artifacts. No special flags or modes are needed; the verify skill is stateless and always checks the current state.

**User Story:** As a developer I want post-implementation verification that checks my code against the specs, so that I can catch gaps, divergences, and inconsistencies before archiving the change.

#### Scenario: Verification with all checks passing

- **GIVEN** a change "add-user-auth" with all tasks complete
- **AND** all spec requirements are implemented and all design decisions are followed
- **WHEN** the user invokes `/opsx:verify add-user-auth`
- **THEN** the system produces a verification report
- **AND** the Completeness dimension shows all tasks and requirements covered
- **AND** the Correctness dimension shows all scenarios satisfied
- **AND** the Coherence dimension shows design adherence
- **AND** the final assessment is "All checks passed. Ready for archive."

#### Scenario: Verification finds critical issues

- **GIVEN** a change with 5 of 7 tasks marked complete
- **AND** one spec requirement has no corresponding implementation in the codebase
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the report lists 2 CRITICAL issues: incomplete tasks and missing requirement implementation
- **AND** each issue includes a specific recommendation (e.g., "Complete task: Add rate limiting middleware" and "Implement requirement: Session Timeout -- no session timeout logic found in auth module")
- **AND** the final assessment states "2 critical issue(s) found. Fix before archiving."

#### Scenario: Verification finds implementation diverging from spec

- **GIVEN** a spec requiring JWT-based authentication
- **AND** the implementation uses session cookies instead
- **WHEN** the system checks correctness
- **THEN** the report includes a WARNING: "Implementation may diverge from spec: auth uses session cookies, spec requires JWT"
- **AND** recommends "Review src/auth/handler.ts:45 against requirement: JWT Authentication"

#### Scenario: Verification finds code pattern inconsistency

- **GIVEN** the project uses kebab-case file naming throughout
- **AND** a new file is named `userAuth.ts` (camelCase)
- **WHEN** the system checks coherence
- **THEN** the report includes a SUGGESTION: "Code pattern deviation: file userAuth.ts uses camelCase, project convention is kebab-case"
- **AND** recommends "Consider renaming to user-auth.ts to follow project pattern"

#### Scenario: Graceful degradation with missing artifacts

- **GIVEN** a change with only tasks.md (no specs or design)
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system verifies task completion only
- **AND** skips spec coverage and design adherence checks
- **AND** notes in the report which checks were skipped and why

#### Scenario: Verification with no delta specs

- **GIVEN** a change that has tasks but no delta specs (e.g., a documentation-only change)
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system skips requirement-level verification
- **AND** focuses on task completion and code pattern coherence
- **AND** notes "No delta specs to verify against"

#### Scenario: Final verify confirms fix loop resolved all issues

- **GIVEN** a change where the initial verify found 2 CRITICAL issues
- **AND** the developer fixed both issues in the fix loop
- **WHEN** the developer runs `/opsx:verify` as the final verification step (3.5)
- **THEN** the verification report SHALL show 0 CRITICAL issues
- **AND** the report SHALL reflect the current state of all artifacts (including any specs updated during the fix loop)
- **AND** the final assessment SHALL be "All checks passed. Ready for archive." or note remaining warnings

## Assumptions

- The OpenSpec CLI provides accurate artifact dependency and status information. <!-- ASSUMPTION: CLI accuracy -->
- Keyword-based code search provides reasonable (not perfect) implementation coverage detection. <!-- ASSUMPTION: Heuristic search -->
- constitution.md is the authoritative source for project rules and is kept up to date. <!-- ASSUMPTION: Constitution authority -->
- The codebase is accessible and searchable for verification of requirement implementation. <!-- ASSUMPTION: Codebase accessibility -->
