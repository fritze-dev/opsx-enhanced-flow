## ADDED Requirements

### Requirement: Generate Changelog from Archives
The `/opsx:changelog` command SHALL generate release notes from the archived spec changes located in `openspec/changes/archive/`. The agent SHALL read each archived change directory (named `YYYY-MM-DD-<feature>`), examine the proposal, delta specs, and design artifacts, and produce a changelog entry that summarizes what changed from the user's perspective. The generated changelog SHALL follow the Keep a Changelog format with sections for Added, Changed, Deprecated, Removed, Fixed, and Security as applicable. Entries SHALL be ordered newest first. The changelog SHALL be written to `CHANGELOG.md` in the project root. If `CHANGELOG.md` already exists, the agent SHALL update it by adding new entries for archives not yet represented, preserving existing manually written entries.

**User Story:** As a user of the project I want a changelog that tells me what changed and when, so that I can understand the impact of updates without reading spec files or commit logs.

#### Scenario: Changelog generated from single archived change
- **GIVEN** one archived change at `openspec/changes/archive/2025-01-15-user-auth/` containing a proposal describing a new authentication feature and delta specs with ADDED requirements
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent creates or updates `CHANGELOG.md` with an entry dated 2025-01-15 under the "Added" section describing the new authentication feature in user-facing language

#### Scenario: Multiple archives ordered newest first
- **GIVEN** three archived changes dated 2025-01-10, 2025-02-05, and 2025-03-20
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the changelog lists the 2025-03-20 entry first, followed by 2025-02-05, then 2025-01-10

#### Scenario: Existing changelog preserved
- **GIVEN** a `CHANGELOG.md` that already contains manually written entries for versions 1.0 and 1.1
- **AND** a new archived change that has not been represented in the changelog
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent adds the new entry at the top of the changelog without modifying or removing the existing 1.0 and 1.1 entries

#### Scenario: No archives to process
- **GIVEN** the `openspec/changes/archive/` directory is empty or does not exist
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the agent informs the user that no archived changes were found and no changelog entries were generated

#### Scenario: Change with only internal refactoring
- **GIVEN** an archived change whose proposal and specs describe purely internal refactoring with no user-visible changes
- **WHEN** the agent processes the archive
- **THEN** the agent either omits the entry entirely or includes it under a minimal note (e.g., "Internal improvements") rather than fabricating user-facing changes

## Edge Cases

- **No archives to process**: The agent SHALL inform the user that no archived changes were found.
- **Malformed archive directory**: The agent SHALL skip malformed archives, warn the user, and continue processing remaining archives.
- **Duplicate changelog entries**: The agent SHALL detect existing entries and not duplicate them on re-run.

## Assumptions

- Archived changes follow `YYYY-MM-DD-<feature-name>` naming under `openspec/changes/archive/`. <!-- ASSUMPTION: Archive naming enforced by archive skill -->
- Keep a Changelog format is the target format. <!-- ASSUMPTION: Format convention from constitution -->
