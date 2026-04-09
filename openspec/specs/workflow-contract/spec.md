---
order: 3
category: reference
status: stable
version: 1
lastModified: 2026-04-08
---
## Purpose

Defines the WORKFLOW.md pipeline orchestration contract, Smart Template format, and the skill reading pattern for pipeline configuration.

## Requirements

### Requirement: WORKFLOW.md Pipeline Orchestration
The system SHALL support an `openspec/WORKFLOW.md` file as the pipeline orchestration contract. WORKFLOW.md SHALL use markdown-with-YAML-frontmatter format. The YAML frontmatter SHALL contain: `templates_dir` (path to Smart Templates directory), `pipeline` (ordered array of artifact IDs), `apply` (object with `requires`, `tracks`, and `instruction` fields), `post_artifact` (instructions executed after each artifact creation), `context` (path to constitution or behavioral context), optionally `docs_language`, and `template-version` (integer, for template merge detection during `/opsx:setup`). The markdown body MAY contain supplementary workflow documentation.

**User Story:** As a plugin maintainer I want a single WORKFLOW.md file for pipeline orchestration, so that all pipeline configuration lives in one place.

#### Scenario: Skill reads WORKFLOW.md for pipeline configuration
- **GIVEN** a project with `openspec/WORKFLOW.md` containing pipeline frontmatter
- **WHEN** any artifact-generating skill is invoked
- **THEN** the skill SHALL read WORKFLOW.md frontmatter for `templates_dir`, `pipeline`, `apply`, and `post_artifact` configuration

#### Scenario: WORKFLOW.md frontmatter contains required fields
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, `context`, and `template-version` fields

### Requirement: Smart Template Format
All template files SHALL use the Smart Template format: markdown with YAML frontmatter containing `id` (artifact identifier), `description` (brief purpose), `generates` (output file path relative to change directory), `requires` (array of dependency artifact IDs), `instruction` (AI behavioral constraints for artifact generation), and `template-version` (integer, monotonically increasing — bumped when the plugin changes the template content). The markdown body SHALL define the output structure for the generated artifact. The `instruction` field content SHALL NOT be copied into generated artifacts — it serves as constraints for the AI during generation. The `template-version` field enables `/opsx:setup` to detect whether a local template has been customized by the user and to merge plugin updates with local customizations instead of overwriting them. The field is named `template-version` (not `version`) to distinguish it from spec `version` (content version tracking).

**User Story:** As a developer I want each template to be self-describing with its own instruction and metadata, so that I can understand what a template does without consulting a separate schema file.

#### Scenario: Smart Template contains required frontmatter fields
- **GIVEN** a Smart Template file (e.g., `openspec/templates/research.md`)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields

#### Scenario: Skill reads instruction from template frontmatter
- **GIVEN** a Smart Template with an `instruction` field in its frontmatter
- **WHEN** a skill generates an artifact using this template
- **THEN** the skill SHALL apply the instruction as behavioral constraints
- **AND** SHALL NOT copy the instruction text into the generated artifact file

#### Scenario: Template body defines output structure
- **GIVEN** a Smart Template with markdown headings in its body
- **WHEN** a skill generates an artifact using this template
- **THEN** the generated artifact SHALL follow the section structure defined in the template body

#### Scenario: All templates use Smart Template format
- **GIVEN** the `openspec/templates/` directory
- **WHEN** all template files are inspected
- **THEN** every template (pipeline artifacts, docs, constitution) SHALL have YAML frontmatter with at minimum `id` and `description` fields

### Requirement: Skill Reading Pattern
Skills SHALL follow this reading pattern: (1) read `openspec/WORKFLOW.md` frontmatter for `templates_dir` and `pipeline` array, (2) for each artifact in `pipeline`, read `<templates_dir>/<id>.md` to get `generates`, `requires`, and `instruction` from frontmatter and output structure from body, (3) check artifact status via file existence at `openspec/changes/<name>/<generates>`, (4) read WORKFLOW.md's `context` field for project-level behavioral context, (5) execute `post_artifact` from WORKFLOW.md after artifact creation.

**User Story:** As a skill author I want a clear, documented pattern for reading pipeline configuration, so that all skills interact with the pipeline consistently.

#### Scenario: Skill resolves template path from WORKFLOW.md
- **GIVEN** WORKFLOW.md with `templates_dir: openspec/templates` and `pipeline: [research, ...]`
- **WHEN** a skill needs the research template
- **THEN** it SHALL read `openspec/templates/research.md`

#### Scenario: Skill checks artifact status via file existence
- **GIVEN** a change workspace at `openspec/changes/my-change/`
- **AND** a Smart Template with `generates: research.md`
- **WHEN** the skill checks artifact status
- **THEN** it SHALL check if `openspec/changes/my-change/research.md` exists and is non-empty

## Edge Cases

- **WORKFLOW.md missing**: Skills SHALL report an error and suggest running `/opsx:setup`.
- **Smart Template missing frontmatter**: Skills SHALL treat the file as a plain template (no instruction, no metadata) and report a warning.
- **Smart Template missing template-version field**: Setup SHALL treat the template as version 0 (always eligible for update). Skills reading templates SHALL ignore the `template-version` field — it is only used by setup for merge detection.
- **WORKFLOW.md with malformed YAML**: Skills SHALL report a parse error and stop.
- **Empty `pipeline` array**: Skills SHALL report that no artifacts are defined and stop.
- **`templates_dir` points to nonexistent directory**: Skills SHALL report the missing directory and suggest running `/opsx:setup`.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to read and interpret them. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
No further assumptions beyond those marked above.
