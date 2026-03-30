## MODIFIED Requirement: Post-Implementation Verification

Add: The `/opsx:verify` command SHALL serve as both the initial verification (tasks.md step 3.2) and the final verification (step 3.5) in the QA loop. When invoked as a final verify after the fix loop, the command SHALL operate identically — checking completeness, correctness, and coherence against the current state of code and artifacts. No special flags or modes are needed; the verify skill is stateless and always checks the current state.

#### Scenario: Final verify confirms fix loop resolved all issues

- **GIVEN** a change where the initial verify found 2 CRITICAL issues
- **AND** the developer fixed both issues in the fix loop
- **WHEN** the developer runs `/opsx:verify` as the final verification step (3.5)
- **THEN** the verification report SHALL show 0 CRITICAL issues
- **AND** the report SHALL reflect the current state of all artifacts (including any specs updated during the fix loop)
- **AND** the final assessment SHALL be "All checks passed. Ready for archive." or note remaining warnings
