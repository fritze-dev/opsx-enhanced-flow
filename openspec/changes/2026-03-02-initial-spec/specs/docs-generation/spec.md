## ADDED Requirements

### Requirement: Generate Capability Documentation
The `/opsx:docs` command SHALL generate user-facing documentation from the merged baseline specs located in `openspec/specs/<capability>/spec.md`. The command SHALL produce one documentation file per capability, placed under `docs/capabilities/<capability>.md`. Generated documentation SHALL use clear, user-facing language that explains what the capability does, how to use it, and what behavior to expect. Documentation SHALL NOT include implementation details, internal architecture references, or normative specification language (SHALL/MUST). The agent SHALL transform requirement descriptions into natural explanations, convert Gherkin scenarios into readable usage examples or behavioral descriptions, and organize content with appropriate headings. If a User Story is present in the spec, the agent SHALL use it to inform the documentation's framing and context. The `docs/capabilities/` directory SHALL be created if it does not exist.

**User Story:** As a user of the plugin I want clear documentation for each capability, so that I can understand what features are available and how they work without reading formal specifications.

#### Scenario: Documentation generated for single capability
- **GIVEN** a merged baseline spec exists at `openspec/specs/user-auth/spec.md` with two requirements and four scenarios
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent creates `docs/capabilities/user-auth.md` containing a description of the user-auth capability, explanations of each feature, and usage examples derived from the scenarios

#### Scenario: Normative language replaced with user-facing language
- **GIVEN** a baseline spec containing "The system SHALL validate email format before account creation"
- **WHEN** the agent generates documentation for this capability
- **THEN** the documentation reads something like "Email addresses are validated when you create an account" — natural language without SHALL/MUST

#### Scenario: Gherkin scenarios converted to usage examples
- **GIVEN** a spec scenario with GIVEN a user on the dashboard, WHEN they click Export, THEN a CSV downloads
- **WHEN** the agent generates documentation
- **THEN** the documentation includes a section describing the export workflow in natural terms, such as "From the dashboard, click Export to download your data as a CSV file"

#### Scenario: Implementation details excluded
- **GIVEN** a spec requirement that mentions internal module names or database schema details in its description
- **WHEN** the agent generates documentation
- **THEN** the documentation omits internal references and focuses only on user-visible behavior and outcomes

#### Scenario: Documentation generated for all capabilities
- **GIVEN** baseline specs exist for five capabilities under `openspec/specs/`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** five documentation files are created under `docs/capabilities/`, one for each capability

#### Scenario: Docs directory created if missing
- **GIVEN** the `docs/capabilities/` directory does not exist in the project
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent creates the `docs/capabilities/` directory and writes the documentation files into it

#### Scenario: User Story informs documentation framing
- **GIVEN** a spec requirement with a User Story "As a team lead I want to see aggregated metrics, so that I can track team performance"
- **WHEN** the agent generates documentation
- **THEN** the documentation frames the feature from the team lead's perspective, emphasizing how it helps track team performance

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

- **No baseline specs exist**: If `openspec/specs/` is empty, the agent SHALL inform the user and suggest running `/opsx:sync` first.
- **Spec with no scenarios**: The agent SHALL still generate documentation from requirement descriptions, noting that usage examples are unavailable.
- **Existing documentation files**: The agent SHALL overwrite existing docs with freshly generated content, since specs are the source of truth.
- **No archives to process**: The agent SHALL inform the user that no archived changes were found.
- **Malformed archive directory**: The agent SHALL skip malformed archives, warn the user, and continue processing remaining archives.
- **Duplicate changelog entries**: The agent SHALL detect existing entries and not duplicate them on re-run.

## Assumptions

- Baseline specs in `openspec/specs/` are the source of truth for documentation generation. <!-- ASSUMPTION: Docs generated after sync -->
- Archived changes follow `YYYY-MM-DD-<feature-name>` naming under `openspec/changes/archive/`. <!-- ASSUMPTION: Archive naming enforced by archive skill -->
- Keep a Changelog format is the target format. <!-- ASSUMPTION: Format convention from constitution -->
