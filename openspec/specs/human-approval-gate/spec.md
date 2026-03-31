---
order: 10
category: development
---
## Purpose

Defines the QA loop with mandatory explicit human approval before archiving, including success metric validation, fix-verify cycles, and bidirectional feedback between code and specs.

## Requirements

### Requirement: QA Loop with Mandatory Approval

The system SHALL require explicit human approval before a change can be archived. The QA loop consists of: (1) running `/opsx:verify` to produce a verification report, (2) presenting findings to the user, and (3) waiting for an explicit "Approved" response. The system SHALL NOT archive a change without receiving explicit human approval. Approval SHALL only be requested after verification has been run and all CRITICAL issues have been resolved. The tasks.md template SHALL include a QA Loop section with an explicit human approval checkbox that MUST be checked before archiving proceeds. Every Success Metric from design.md SHALL be carried over as a PASS/FAIL checkbox in the QA Loop section.

Approval SHALL be gated by a final verification pass. After the fix loop completes (all CRITICAL issues resolved, code and specs in sync), a final `/opsx:verify` SHALL be run before the user is asked for approval. This ensures that all changes made during the fix loop — including spec updates, design changes, and code fixes — are verified as consistent before archiving. If the fix loop was not entered (first verify was clean), the initial verify at step 3.2 satisfies this requirement and the final verify step can be marked complete immediately.

The tasks.md template QA Loop section SHALL include the final verify step:

```
3.1. Metric Check
3.2. Auto-Verify: Run /opsx:verify
3.3. User Testing: Stop here!
3.4. Fix Loop: fix → re-verify
3.5. Final Verify: Run /opsx:verify to confirm all fixes are consistent
3.6. Approval: Only finish on explicit "Approved"
```

**User Story:** As a developer I want a mandatory human approval step before archiving, so that no change is finalized without my explicit review and sign-off.

#### Scenario: Approval after clean verification

- **GIVEN** a change "add-user-auth" has been implemented and all tasks are complete
- **AND** the user runs `/opsx:verify` which produces a report with no CRITICAL or WARNING issues
- **AND** all success metric checkboxes in the QA Loop section are marked PASS
- **WHEN** the system presents the verification report
- **THEN** the system asks for explicit approval
- **AND** the user responds "Approved"
- **AND** the system proceeds to allow archiving

#### Scenario: Approval blocked by critical issues

- **GIVEN** a verification report contains 2 CRITICAL issues
- **WHEN** the system presents the findings to the user
- **THEN** the system SHALL NOT request approval
- **AND** SHALL state that CRITICAL issues must be resolved first
- **AND** SHALL list the specific issues that need resolution

#### Scenario: Approval with warnings acknowledged

- **GIVEN** a verification report contains 0 CRITICAL issues but 3 WARNING issues
- **WHEN** the system presents the findings
- **THEN** the system SHALL request approval while highlighting the warnings
- **AND** the user may respond "Approved" to accept the warnings
- **AND** the system SHALL proceed to allow archiving

#### Scenario: Success metrics carried into QA loop

- **GIVEN** a design.md containing 3 success metrics: "Auth response time < 200ms", "All endpoints require valid JWT", "Session expiry after 30 min idle"
- **WHEN** tasks.md is generated
- **THEN** the QA Loop section SHALL contain 3 PASS/FAIL checkboxes, one for each success metric
- **AND** each checkbox SHALL be marked by the user or verifier during the QA phase
- **AND** all checkboxes MUST be marked PASS before approval can be granted

#### Scenario: Final verify after fix loop

- **GIVEN** a change where the initial verify (3.2) found CRITICAL issues
- **AND** the developer completed the fix loop (3.4), fixing all issues
- **WHEN** the fix loop is complete
- **THEN** the system SHALL run `/opsx:verify` one final time (step 3.5)
- **AND** the final verify report SHALL confirm 0 CRITICAL issues
- **AND** only then SHALL the system proceed to request approval (step 3.6)

#### Scenario: Final verify skipped when first verify is clean

- **GIVEN** a change where the initial verify (3.2) found no CRITICAL or WARNING issues
- **AND** the user testing (3.3) found no bugs
- **AND** the fix loop (3.4) was not entered
- **WHEN** the QA loop reaches step 3.5
- **THEN** the final verify step SHALL be marked complete immediately
- **AND** the system SHALL proceed to approval (3.6)

#### Scenario: Final verify finds new issues from fix loop changes

- **GIVEN** a fix loop where the developer updated specs and code
- **WHEN** the final verify (3.5) is run
- **AND** it discovers that a spec update introduced an inconsistency
- **THEN** the system SHALL report the new issue
- **AND** the developer SHALL return to the fix loop (3.4) to resolve it
- **AND** SHALL re-run the final verify (3.5) after the fix

### Requirement: Fix Loop

Verify issues SHALL be resolved via a code fix or a spec update before re-verification. When verification finds CRITICAL or WARNING issues, the user SHALL address each issue by either (a) fixing the code to match the spec, or (b) updating the spec or design to match the intended implementation. After fixes are applied, the user SHALL re-run `/opsx:verify` to confirm resolution. The system SHALL support iterative fix-verify cycles until all CRITICAL issues are resolved and the user is satisfied with remaining warnings. The bidirectional feedback principle applies: when implementation reveals that a spec or design is wrong, updating the spec is a valid resolution path.

**User Story:** As a developer I want a structured fix-verify loop, so that every verification issue is explicitly resolved -- either by fixing the code or by updating the spec -- before the change is considered complete.

#### Scenario: Fix code to resolve critical issue

- **GIVEN** a verification report with CRITICAL issue "Requirement not found: Session Timeout"
- **WHEN** the developer implements session timeout logic in the auth module
- **AND** re-runs `/opsx:verify`
- **THEN** the new verification report no longer lists the session timeout issue as CRITICAL
- **AND** the Completeness dimension reflects the additional requirement coverage

#### Scenario: Update spec to resolve warning

- **GIVEN** a verification report with WARNING "Implementation may diverge from spec: auth uses session cookies, spec requires JWT"
- **AND** the developer intentionally chose session cookies over JWT
- **WHEN** the developer updates the spec to reflect session cookie authentication
- **AND** re-runs `/opsx:verify`
- **THEN** the new verification report no longer lists the divergence warning
- **AND** the spec accurately reflects the implementation

#### Scenario: Multiple fix-verify iterations

- **GIVEN** a first verification finds 3 CRITICAL and 2 WARNING issues
- **WHEN** the developer fixes all 3 CRITICAL issues and re-runs `/opsx:verify`
- **THEN** the second report shows 0 CRITICAL issues
- **AND** may show the same 2 warnings plus any new issues introduced by the fixes
- **AND** the developer may choose to address warnings or approve with acknowledged warnings

#### Scenario: Fix introduces new issue

- **GIVEN** a developer fixes a CRITICAL issue by refactoring the auth module
- **AND** the refactoring removes a function that another requirement depends on
- **WHEN** the developer re-runs `/opsx:verify`
- **THEN** the original CRITICAL issue is resolved
- **BUT** a new CRITICAL issue appears for the broken dependency
- **AND** the developer must address the new issue before approval

#### Scenario: Bidirectional feedback -- update design

- **GIVEN** a verification finds that the implementation uses a different architectural pattern than design.md specifies
- **AND** the new pattern is superior and the developer wants to keep it
- **WHEN** the developer updates design.md to document the actual architecture
- **AND** re-runs `/opsx:verify`
- **THEN** the coherence check passes because design.md now matches the implementation

## Edge Cases

- **Approval without running verify**: If the user has never run `/opsx:verify` for the current change, the QA Loop approval checkbox in tasks.md will not be checked. The system SHALL warn during archive that verification has not been performed.
- **Stale verification**: If code changes are made after the last verify run, the verification report may be stale. The system does not enforce re-verification automatically but SHALL note the timestamp of the last verify run relative to the most recent code changes when the user requests archive.
- **No design.md success metrics**: If design.md does not contain explicit success metrics, the QA Loop section SHALL still include the mandatory human approval checkbox but will have no PASS/FAIL metric checkboxes.
- **User provides partial approval**: If the user responds with something ambiguous (e.g., "looks ok" or "seems fine"), the system SHALL clarify that it needs an explicit "Approved" and SHALL NOT treat ambiguous responses as approval.
- **All issues are suggestions only**: If verification produces only SUGGESTION-level findings and no CRITICAL or WARNING issues, the system SHALL proceed directly to requesting approval without requiring fixes.
- **Fix loop with no code changes needed**: If a CRITICAL issue is a false positive (e.g., keyword search matched unrelated code), the user may update the verify heuristics or acknowledge the false positive. Re-running verify with the same code is a valid fix loop iteration.

## Assumptions

- The user is available to provide approval in a timely manner within the same session or a subsequent session. <!-- ASSUMPTION: User availability -->
- Spec updates during the fix loop do not require re-running the full artifact pipeline (preflight is not re-triggered automatically). <!-- ASSUMPTION: No auto-retrigger -->
- The human reviewer is the same person who initiated the change or has sufficient context to approve. <!-- ASSUMPTION: Reviewer context -->
- "Approved" is the canonical approval token; the system recognizes it case-insensitively. <!-- ASSUMPTION: Approval token -->
- The fix loop does not have a maximum iteration count; it continues until the user is satisfied. <!-- ASSUMPTION: Unbounded fix loop -->
