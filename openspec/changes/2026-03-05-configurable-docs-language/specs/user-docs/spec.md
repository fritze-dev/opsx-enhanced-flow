## ADDED Requirements

### Requirement: Language-Aware Documentation Generation
The `/opsx:docs` command SHALL determine the documentation language before generating any output. The agent SHALL read `openspec/config.yaml` and extract the `docs_language` field. If the field is missing or set to "English", the agent SHALL generate all documentation in English (default behavior). If a non-English language is specified, the agent SHALL generate all headings and content in the target language for capability docs, ADRs, and the consolidated README.

Translation rules:
- YAML frontmatter **keys** SHALL remain in English (machine-readable identifiers)
- YAML frontmatter **values** (`title`, `description`) SHALL be translated to the target language
- Product names (OpenSpec, Claude Code), commands (`/opsx:*`), and file paths SHALL remain in English
- If an existing doc is in a different language than the configured `docs_language`, the agent SHALL treat it as a full regeneration rather than an incremental update

**User Story:** As a non-English-speaking team I want documentation generated in my language, so that the entire team can understand the project documentation without translation.

#### Scenario: Documentation generated in configured language
- **GIVEN** `openspec/config.yaml` contains `docs_language: German`
- **AND** a baseline spec exists at `openspec/specs/user-auth/spec.md`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the generated `docs/capabilities/user-auth.md` SHALL have German headings (e.g., "Zweck" instead of "Purpose") and German content
- **AND** YAML frontmatter keys SHALL remain in English
- **AND** YAML frontmatter `title` and `description` values SHALL be in German

#### Scenario: Default to English when field is missing
- **GIVEN** `openspec/config.yaml` does not contain a `docs_language` field
- **WHEN** the developer runs `/opsx:docs`
- **THEN** all documentation SHALL be generated in English (unchanged behavior)

#### Scenario: Product names preserved in any language
- **GIVEN** `docs_language` is set to a non-English language
- **WHEN** the agent generates documentation
- **THEN** product names (OpenSpec, Claude Code), commands (`/opsx:docs`, `/opsx:archive`), and file paths SHALL remain in English

#### Scenario: Language change triggers full regeneration
- **GIVEN** existing capability docs were generated in English
- **AND** `docs_language` has been changed to "French"
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent SHALL fully regenerate all docs in French rather than attempting incremental updates on the English docs

#### Scenario: ADRs generated in configured language
- **GIVEN** `openspec/config.yaml` contains `docs_language: Spanish`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** ADR headings (e.g., "Contexto", "Decisión", "Consecuencias") and content SHALL be in Spanish
- **AND** the ADR file naming convention (`adr-NNN-<slug>.md`) SHALL remain in English

#### Scenario: Consolidated README generated in configured language
- **GIVEN** `openspec/config.yaml` contains `docs_language: German`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** `docs/README.md` headings (e.g., "Systemarchitektur", "Schlüsselentscheidungen") and content SHALL be in German

## Edge Cases

- **Unsupported or misspelled language**: The agent SHALL make a best-effort attempt to generate in the specified language. If the language is unrecognizable, the agent SHALL warn the user and fall back to English.
- **Mixed-language frontmatter**: The `capability` field (machine ID) stays English. Only `title` and `description` values are translated.

## Assumptions

<!-- ASSUMPTION: The LLM can reliably generate documentation in any language specified as a full English name (e.g., "German", "French"). No ISO codes needed. -->
No further assumptions beyond those marked above.
