---
order: 3
category: reference
---
## ADDED Requirements

### Requirement: WORKFLOW.md Pipeline Orchestration
The system SHALL support an `openspec/WORKFLOW.md` file as the pipeline orchestration contract. WORKFLOW.md SHALL use markdown-with-YAML-frontmatter format. The YAML frontmatter SHALL contain: `templates_dir` (path to Smart Templates directory), `pipeline` (ordered array of artifact IDs), `apply` (object with `requires`, `tracks`, and `instruction` fields), `post_artifact` (instructions executed after each artifact creation), `context` (path to constitution or behavioral context), and optionally `docs_language`. The markdown body MAY contain supplementary workflow documentation. When `openspec/WORKFLOW.md` is present, skills SHALL read it instead of `openspec/schemas/opsx-enhanced/schema.yaml` and `openspec/config.yaml`.

**User Story:** As a plugin maintainer I want a single WORKFLOW.md file for pipeline orchestration, so that pipeline configuration is not scattered across schema.yaml and config.yaml.

#### Scenario: Skill reads WORKFLOW.md for pipeline configuration
- **GIVEN** a project with `openspec/WORKFLOW.md` containing pipeline frontmatter
- **WHEN** any artifact-generating skill is invoked
- **THEN** the skill SHALL read WORKFLOW.md frontmatter for `templates_dir`, `pipeline`, `apply`, and `post_artifact` configuration

#### Scenario: WORKFLOW.md replaces schema.yaml and config.yaml
- **GIVEN** a project with `openspec/WORKFLOW.md`
- **WHEN** a skill needs pipeline definitions or project context
- **THEN** it SHALL read from WORKFLOW.md and SHALL NOT require `openspec/schemas/opsx-enhanced/schema.yaml` or `openspec/config.yaml`

#### Scenario: WORKFLOW.md frontmatter contains required fields
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, and `context` fields

### Requirement: Smart Template Format
All template files SHALL use the Smart Template format: markdown with YAML frontmatter containing `id` (artifact identifier), `description` (brief purpose), `generates` (output file path relative to change directory), `requires` (array of dependency artifact IDs), and `instruction` (AI behavioral constraints for artifact generation). The markdown body SHALL define the output structure for the generated artifact. The `instruction` field content SHALL NOT be copied into generated artifacts — it serves as constraints for the AI during generation.

**User Story:** As a developer I want each template to be self-describing with its own instruction and metadata, so that I can understand what a template does without consulting a separate schema file.

#### Scenario: Smart Template contains required frontmatter fields
- **GIVEN** a Smart Template file (e.g., `openspec/templates/research.md`)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `generates`, `requires`, and `instruction` fields

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

### Requirement: Template Variable Substitution
Smart Template bodies SHALL support simple `{{ variable }}` substitution. Supported variables SHALL be: `{{ change.name }}` (current change directory name), `{{ change.stage }}` (current pipeline artifact stage), and `{{ project.name }}` (project name from WORKFLOW.md frontmatter or repository name). Variables SHALL be resolved at skill invocation time via simple string replacement. If a variable is referenced but unavailable (e.g., no active change), it SHALL be replaced with an empty string. Unknown `{{ tokens }}` that do not match supported variables SHALL be left as-is to avoid breaking markdown content.

**User Story:** As a template author I want to use variables like `{{ change.name }}` in template headings, so that generated artifacts automatically include context-specific information.

#### Scenario: Template variable resolves in active change
- **GIVEN** a Smart Template body containing `# Research: {{ change.name }}`
- **AND** the current change is `add-user-auth`
- **WHEN** the skill generates the artifact
- **THEN** the output heading SHALL be `# Research: add-user-auth`

#### Scenario: Unavailable variable resolves to empty string
- **GIVEN** a Smart Template body containing `{{ change.name }}`
- **AND** there is no active change
- **WHEN** the template is rendered
- **THEN** `{{ change.name }}` SHALL be replaced with an empty string

#### Scenario: Unknown variable token left as-is
- **GIVEN** a Smart Template body containing `{{ custom_token }}`
- **AND** `custom_token` is not a supported variable
- **WHEN** the template is rendered
- **THEN** `{{ custom_token }}` SHALL remain unchanged in the output

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
- **WORKFLOW.md with malformed YAML**: Skills SHALL report a parse error and stop.
- **Template variable syntax in code blocks**: `{{ }}` inside fenced code blocks is part of the content and SHOULD be left as-is by the substitution (only substitute in rendered markdown context).
- **Empty `pipeline` array**: Skills SHALL report that no artifacts are defined and stop.
- **`templates_dir` points to nonexistent directory**: Skills SHALL report the missing directory and suggest running `/opsx:setup`.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to read and interpret them. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
- Simple string replacement for `{{ variable }}` is sufficient for initial template rendering; a full template engine is out of scope. <!-- ASSUMPTION: Simple substitution sufficient -->
No further assumptions beyond those marked above.
