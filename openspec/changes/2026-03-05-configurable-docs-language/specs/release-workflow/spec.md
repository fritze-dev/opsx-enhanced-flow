## ADDED Requirements

### Requirement: Language-Aware Changelog Generation
The `/opsx:changelog` command SHALL determine the documentation language before generating entries. The agent SHALL read `openspec/config.yaml` and extract the `docs_language` field. If the field is missing or set to "English", the agent SHALL generate changelog entries in English (default behavior). If a non-English language is configured, the agent SHALL translate section headers (e.g., `### Added` → `### Hinzugefügt` for German) and entry descriptions to the target language. Dates SHALL remain in ISO format (`YYYY-MM-DD`). Product names (OpenSpec, Claude Code), commands (`/opsx:*`), and file paths SHALL remain in English.

**User Story:** As a non-English-speaking team I want changelog entries in my language, so that release notes are immediately understandable.

#### Scenario: Changelog generated in configured language
- **GIVEN** `openspec/config.yaml` contains `docs_language: German`
- **AND** a new archived change exists that is not yet in the changelog
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** the new entry SHALL have German section headers (e.g., `### Hinzugefügt`, `### Geändert`, `### Behoben`)
- **AND** entry descriptions SHALL be in German
- **AND** dates SHALL remain in ISO format

#### Scenario: Default to English when field is missing
- **GIVEN** `openspec/config.yaml` does not contain a `docs_language` field
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** all entries SHALL be generated in English (unchanged behavior)

#### Scenario: Existing entries preserved in previous language
- **GIVEN** existing changelog entries were generated in English
- **AND** `docs_language` has been changed to "French"
- **WHEN** the developer runs `/opsx:changelog`
- **THEN** existing English entries SHALL be preserved unchanged
- **AND** new entries SHALL be generated in French

## Edge Cases

- **Language change mid-project**: Old entries stay in the previous language. This is acceptable because the changelog guardrail already preserves existing entries.
- **Mixed-language changelog**: After a language change, the changelog contains entries in multiple languages. This is expected and acceptable.

## Assumptions

<!-- ASSUMPTION: Keep a Changelog section headers have well-known translations in major languages. The LLM can produce these reliably. -->
No further assumptions beyond those marked above.
