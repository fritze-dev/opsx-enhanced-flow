## ADDED Requirements

### Requirement: Language-Aware Architecture Overview
The architecture overview content generated as part of `docs/README.md` by `/opsx:docs` SHALL respect the `docs_language` setting from `openspec/config.yaml`. When a non-English language is configured, all section headings (e.g., "System Architecture", "Tech Stack", "Key Design Decisions", "Conventions") and descriptive content SHALL be translated to the target language. Table column headers in the Key Design Decisions table SHALL also be translated. Product names, commands, and file paths SHALL remain in English.

**User Story:** As a non-English-speaking team I want the architecture overview in my language, so that the full documentation entry point is accessible to my team.

#### Scenario: Architecture overview in configured language
- **GIVEN** `openspec/config.yaml` contains `docs_language: German`
- **AND** a constitution and archived design.md files exist
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the architecture overview in `docs/README.md` SHALL have German headings (e.g., "Systemarchitektur", "Technologie-Stack") and German content
- **AND** product names (OpenSpec, Claude Code) and file paths SHALL remain in English

#### Scenario: Design decisions table translated
- **GIVEN** `docs_language: French`
- **WHEN** the agent generates the Key Design Decisions table
- **THEN** column headers SHALL be in French (e.g., "Décision", "Justification")
- **AND** ADR link text (e.g., "ADR-001") SHALL remain in English

## Edge Cases

- **Constitution content in English**: The constitution is always in English. The agent translates when generating the overview, not the constitution itself.

## Assumptions

No assumptions made.
