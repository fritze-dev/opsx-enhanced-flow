## MODIFIED Requirements

### Requirement: Post-Archive Auto Patch Bump Convention

The project constitution SHALL define a convention that instructs the post-apply workflow to automatically increment the patch version in `.claude-plugin/plugin.json` after a successful change completion. The convention SHALL also require syncing the `version` field in `.claude-plugin/marketplace.json` to match. The output SHALL display the new version.

**User Story:** As a plugin maintainer I want the patch version to auto-increment when a change is completed, so that consumers can detect updates without manual version bumps.

#### Scenario: Successful auto-bump after change completion

- **GIVEN** a plugin project with `.claude-plugin/plugin.json` containing version `1.0.3`
- **AND** `.claude-plugin/marketplace.json` containing version `1.0.3`
- **AND** the constitution defines the post-completion auto-bump convention
- **WHEN** the post-apply workflow runs for a completed change
- **THEN** the system SHALL increment the patch version to `1.0.4` in `plugin.json`
- **AND** SHALL update `marketplace.json` to version `1.0.4`

### Requirement: Generate Changelog from Completed Changes

The `/opsx:changelog` command SHALL generate release notes from completed changes located in `openspec/changes/`. The agent SHALL scan all change directories (named `YYYY-MM-DD-<feature>`) and identify completed changes (all tasks checked). For each completed change not yet in the changelog, the agent SHALL read `proposal.md` from the change directory for motivation and capabilities, and read the current baseline specs at `openspec/specs/<capability>/spec.md` for user stories and scenario titles of the affected capabilities. The generated changelog SHALL follow the Keep a Changelog format. Entries SHALL be ordered newest first. The changelog SHALL be written to `CHANGELOG.md` in the project root.

**User Story:** As a user of the project I want a changelog that tells me what changed and when, so that I can understand the impact of updates without reading spec files or commit logs.

#### Scenario: Changelog generated from completed change

- **GIVEN** a completed change at `openspec/changes/2026-04-01-user-auth/` with proposal.md describing a new authentication feature
- **AND** the proposal lists capability `user-auth` as new
- **AND** `openspec/specs/user-auth/spec.md` contains user stories and scenarios
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent creates or updates `CHANGELOG.md` with an entry dated 2026-04-01 describing the new authentication feature
- **AND** uses user stories from the baseline spec for user-facing descriptions

#### Scenario: Multiple completed changes ordered newest first

- **GIVEN** three completed changes dated 2026-01-10, 2026-02-05, and 2026-03-20
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the changelog lists the 2026-03-20 entry first, followed by 2026-02-05, then 2026-01-10

#### Scenario: Active changes excluded from changelog

- **GIVEN** a completed change at `openspec/changes/2026-04-01-user-auth/` (all tasks checked)
- **AND** an active change at `openspec/changes/2026-04-02-wip-feature/` (unchecked tasks)
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** only the completed change is included in the changelog
- **AND** the active change is skipped

#### Scenario: No completed changes to process

- **GIVEN** all changes under `openspec/changes/` are active (have unchecked tasks)
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent informs the user that no completed changes were found

### Requirement: Archive Output Includes Next Steps

The post-apply workflow output SHALL include a "Next steps" section guiding the user through the complete post-completion workflow: generate changelog, generate docs, version bump, push, and update the local plugin.

#### Scenario: Next steps shown after verification

- **GIVEN** a successful verification of a completed change
- **WHEN** the verification summary is displayed
- **THEN** the output SHALL include next steps: `/opsx:changelog` → `/opsx:docs` → version bump → push → update plugin

## Edge Cases

- **Change with only internal refactoring:** If a change's proposal describes purely internal refactoring, the changelog either omits the entry or includes a minimal note.
- **Proposal missing from change directory:** If a completed change has no `proposal.md`, skip it with a warning.

## Assumptions

- Completed changes follow `YYYY-MM-DD-<feature-name>` naming under `openspec/changes/`. <!-- ASSUMPTION: Naming enforced by new skill -->
No further assumptions beyond those marked above.
