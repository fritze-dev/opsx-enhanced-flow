## MODIFIED Requirements

### Requirement: Post-Implementation Verification

The system SHALL verify the implementation against change artifacts when the user invokes `/opsx:verify`. Verification SHALL assess three dimensions: Completeness (task completion and spec coverage), Correctness (requirement implementation accuracy and scenario coverage), and Coherence (design adherence and code pattern consistency). Each issue found SHALL be classified as CRITICAL (must fix before archive), WARNING (should fix), or SUGGESTION (nice to fix). The system SHALL produce a verification report with a summary scorecard, issues grouped by priority, and specific actionable recommendations with file and line references where applicable. The system SHALL err on the side of lower severity when uncertain (SUGGESTION over WARNING, WARNING over CRITICAL).

The system SHALL additionally read `preflight.md` and cross-check each side-effect identified in Section C (Side-Effect Analysis) against `tasks.md` entries and codebase implementation evidence. For each side-effect, the system SHALL search for a corresponding task in `tasks.md` (keyword match) or implementation evidence in the codebase (keyword heuristic). If a side-effect has neither a matching task nor detectable implementation evidence, the system SHALL report a WARNING issue with an actionable recommendation. If Section C contains no side-effects (e.g., all risks assessed as NONE), the system SHALL skip the cross-check and note it in the report.

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

#### Scenario: Side-effect from preflight not addressed

- **GIVEN** a change where preflight Section C identifies "Regression to existing auth middleware" as a side-effect
- **AND** no task in tasks.md addresses auth middleware regression
- **AND** no codebase evidence of auth middleware changes
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the report includes a WARNING: "Preflight side-effect not addressed: Regression to existing auth middleware"
- **AND** recommends "Add a task or verify that this side-effect is handled in the implementation"

#### Scenario: Side-effect addressed in code but not as task

- **GIVEN** a change where preflight Section C identifies "Schema migration needed for user table"
- **AND** no explicit task in tasks.md mentions schema migration
- **BUT** a migration file exists in the codebase matching the keyword "user table"
- **WHEN** the system cross-checks preflight side-effects
- **THEN** the side-effect is marked as addressed (implementation evidence found)
- **AND** no issue is raised for this side-effect

#### Scenario: Preflight Section C has no side-effects

- **GIVEN** a change where preflight Section C shows all risks assessed as NONE
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system skips the side-effect cross-check
- **AND** notes "No preflight side-effects to verify" in the report

## Edge Cases

- **No change selected**: If no change name is provided and multiple changes exist, the system SHALL prompt the user to select one. For preflight, auto-selection is allowed if only one change exists. For verify, the system SHALL always ask.
- **Preflight on change with no specs**: If the change has no spec files, preflight SHALL abort and report that specs must be created first.
- **Verify on change with no tasks**: If tasks.md does not exist, verify SHALL report the missing artifact and suggest generating it.
- **Concurrent modifications**: If the codebase is modified while verify is running, the report reflects the state at the time of each individual check. The system does not lock files.
- **False positives in keyword search**: Verify uses heuristic search to find implementation evidence. If a requirement keyword matches unrelated code, the system SHALL prefer SUGGESTION severity to avoid false critical issues.
- **Large codebase**: Verification scans may be slow on very large codebases. The system SHALL focus on files referenced in design.md and recently modified files rather than exhaustive codebase search.
- **Side-effect keyword ambiguity**: If a preflight side-effect description is too generic to produce meaningful keyword matches (e.g., "general performance impact"), the system SHALL skip that entry and note it as inconclusive rather than raising a false warning.

## Assumptions

- The OpenSpec CLI provides accurate artifact dependency and status information. <!-- ASSUMPTION: CLI accuracy -->
- Keyword-based code search provides reasonable (not perfect) implementation coverage detection. <!-- ASSUMPTION: Heuristic search -->
- constitution.md is the authoritative source for project rules and is kept up to date. <!-- ASSUMPTION: Constitution authority -->
- The codebase is accessible and searchable for verification of requirement implementation. <!-- ASSUMPTION: Codebase accessibility -->
- Preflight Section C uses a consistent structure (table or list with risk descriptions and assessments) that can be parsed for side-effect extraction. <!-- ASSUMPTION: Section C format -->
