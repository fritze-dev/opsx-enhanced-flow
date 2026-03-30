## MODIFIED Requirements

### Requirement: Skills Layer
The system SHALL deliver all 13 commands as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills SHALL be categorized as workflow (6: new, continue, ff, apply, verify, archive), governance (5: setup, bootstrap, discover, preflight, sync), or documentation (2: changelog, docs). All skills SHALL be model-invocable (disable-model-invocation: false or absent).

**User Story:** As a developer I want every command delivered as a SKILL.md file, so that Claude Code can discover and invoke them through its plugin system.

#### Scenario: All 13 skills are present
- **GIVEN** a fully installed plugin
- **WHEN** the `skills/` directory is listed
- **THEN** it SHALL contain exactly 13 subdirectories, each with a `SKILL.md` file

#### Scenario: Setup is model-invocable
- **GIVEN** the `skills/setup/SKILL.md` file
- **WHEN** its YAML frontmatter is inspected
- **THEN** the `disable-model-invocation` field SHALL be set to `false` so that bootstrap workflows can invoke it programmatically

#### Scenario: All skills are model-invocable
- **GIVEN** any skill in the `skills/` directory
- **WHEN** its YAML frontmatter is inspected
- **THEN** the `disable-model-invocation` field SHALL be set to `false` or be absent (defaulting to false)

## Edge Cases

No changes to edge cases.

## Assumptions

No assumptions changed.
