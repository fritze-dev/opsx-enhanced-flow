## MODIFIED Requirements

### Requirement: Standalone Research with Q&A

The system SHALL run an interactive discovery session when the user invokes `/opsx:discover`. The discovery process SHALL: (1) verify that `openspec/WORKFLOW.md` exists, (2) read the constitution for project rules, (3) read the current change directory and existing baseline specs, (4) check whether existing specs reflect the current codebase and note stale-spec risks, (5) read the research artifact's `instruction` field from the Smart Template and its template, (6) generate `research.md` with a coverage assessment, and (7) generate targeted clarification questions only for Partial or Missing categories.

Context loading guardrails SHALL direct the agent to read `openspec/specs/*/spec.md` and `docs/README.md` but NOT read `openspec/changes/` directories of other completed changes (these are historical and not relevant to new research).

#### Scenario: Ambiguous change selection

- **GIVEN** the user is not in a worktree context
- **AND** multiple active changes exist under `openspec/changes/`
- **AND** no change name is provided
- **WHEN** the user invokes `/opsx:discover`
- **THEN** the system SHALL list active changes and ask the user to select one

## Edge Cases

- **Ambiguous change selection**: If not in a worktree context and multiple active changes exist, the system SHALL list active changes and ask the user to select one.

## Assumptions

- The user has already created a change workspace via /opsx:new before invoking /opsx:discover. <!-- ASSUMPTION: Change workspace exists -->
No further assumptions beyond those marked above.
