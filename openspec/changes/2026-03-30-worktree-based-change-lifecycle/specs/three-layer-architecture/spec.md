## MODIFIED Requirements

### Requirement: Skills Layer

The system SHALL deliver all commands as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills SHALL be categorized as workflow (new, ff, apply, verify, archive), governance (setup, bootstrap, discover, preflight, sync, docs-verify), or documentation (changelog, docs). All skills SHALL be model-invocable (disable-model-invocation: false or absent).

**User Story:** As a developer I want every command delivered as a SKILL.md file, so that Claude Code can discover and invoke them through its plugin system.

#### Scenario: All skills are present

- **GIVEN** a fully installed plugin
- **WHEN** the `skills/` directory is listed
- **THEN** every subdirectory SHALL contain a `SKILL.md` file

#### Scenario: All skills are model-invocable

- **GIVEN** any skill in the `skills/` directory
- **WHEN** its YAML frontmatter is inspected
- **THEN** the `disable-model-invocation` field SHALL be set to `false` or be absent (defaulting to false)

## Edge Cases

No additional edge cases.

## Assumptions

No assumptions made.
