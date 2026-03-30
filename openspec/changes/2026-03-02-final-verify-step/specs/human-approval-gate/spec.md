## MODIFIED Requirement: QA Loop with Mandatory Approval

Add: Approval SHALL be gated by a final verification pass. After the fix loop completes (all CRITICAL issues resolved, code and specs in sync), a final `/opsx:verify` SHALL be run before the user is asked for approval. This ensures that all changes made during the fix loop — including spec updates, design changes, and code fixes — are verified as consistent before archiving. If the fix loop was not entered (first verify was clean), the initial verify at step 3.2 satisfies this requirement and the final verify step can be marked complete immediately.

The tasks.md template QA Loop section SHALL be updated to include the final verify step:

```
3.1. Metric Check
3.2. Auto-Verify: Run /opsx:verify
3.3. User Testing: Stop here!
3.4. Fix Loop: fix → re-verify
3.5. Final Verify: Run /opsx:verify to confirm all fixes are consistent
3.6. Approval: Only finish on explicit "Approved"
```

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
