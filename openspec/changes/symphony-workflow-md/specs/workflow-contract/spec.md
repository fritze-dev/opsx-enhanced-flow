---
order: 2
category: setup
---
## ADDED Requirements

### Requirement: WORKFLOW.md Repository Contract
Every opsx-enhanced-flow project SHALL support a `WORKFLOW.md` file at the project root as the single authoritative workflow contract. `WORKFLOW.md` SHALL use the standard Markdown-with-YAML-front-matter format: an optional YAML block delimited by `---` lines at the top of the file, followed by a markdown body. The YAML front matter SHALL provide structured, machine-readable project settings. The markdown body SHALL serve as the agent prompt context and behavioral template. When `WORKFLOW.md` is present, it supersedes `openspec/config.yaml` and `openspec/constitution.md` as the primary context source for agent skill invocations. When `WORKFLOW.md` is absent, the system SHALL fall back to `openspec/constitution.md` for backward compatibility.

**User Story:** As a project maintainer I want a single version-controlled file that defines my project's AI workflow behavior, so that I can evolve the workflow without touching plugin internals and new contributors have one canonical place to understand how the AI works on this project.

#### Scenario: Agent reads WORKFLOW.md when present
- **GIVEN** a project with `WORKFLOW.md` at the project root
- **AND** the file contains YAML front matter and a markdown body
- **WHEN** the agent invokes any `/opsx:*` skill
- **THEN** the agent reads `WORKFLOW.md` as its primary behavioral context
- **AND** uses the markdown body as the project rules and prompt template
- **AND** respects YAML front matter settings over any defaults

#### Scenario: Fallback to constitution.md when WORKFLOW.md absent
- **GIVEN** a project without `WORKFLOW.md` at the root
- **AND** `openspec/constitution.md` is present
- **WHEN** the agent invokes any `/opsx:*` skill
- **THEN** the agent reads `openspec/constitution.md` as the behavioral context
- **AND** operates identically to the pre-WORKFLOW.md behavior

#### Scenario: WORKFLOW.md with YAML front matter only (no markdown body)
- **GIVEN** a `WORKFLOW.md` containing only YAML front matter and no markdown body
- **WHEN** the agent reads the file
- **THEN** the agent SHALL apply front matter settings
- **AND** treat the empty body as equivalent to minimal guidance (no extra behavioral constraints)

#### Scenario: WORKFLOW.md with markdown body only (no front matter)
- **GIVEN** a `WORKFLOW.md` containing only a markdown body and no YAML front matter
- **WHEN** the agent reads the file
- **THEN** the agent SHALL treat the entire file content as the behavioral context
- **AND** apply no structured settings (equivalent to a renamed constitution.md)

### Requirement: WORKFLOW.md YAML Front Matter Schema
The YAML front matter in `WORKFLOW.md` SHALL support the following top-level fields for opsx-enhanced-flow projects:

- `schema` (string): The OpenSpec schema name. Default: `opsx-enhanced`.
- `project` (object): Project metadata.
  - `name` (string): Human-readable project name.
  - `description` (string, optional): Brief project description.
- `docs_language` (string, optional): Language for generated documentation. Default: `English`.
- `workflow` (object, optional): Workflow behavior overrides.
  - `enforce_english_artifacts` (boolean, optional): Whether to enforce English for all pipeline artifacts. Default: `true`.

Unknown YAML keys SHALL be ignored for forward compatibility. Malformed YAML front matter (invalid YAML syntax) SHALL cause the agent to report a parse error and fall back to reading the markdown body as plain context.

**User Story:** As a developer I want WORKFLOW.md front matter to define structured project settings in a validated format, so that project configuration is explicit, discoverable, and not buried in prose.

#### Scenario: Front matter sets schema reference
- **GIVEN** a `WORKFLOW.md` with `schema: opsx-enhanced` in the front matter
- **WHEN** the agent reads the file
- **THEN** the agent confirms the `opsx-enhanced` schema is active for this project

#### Scenario: Front matter sets project name
- **GIVEN** a `WORKFLOW.md` with `project.name: "My SaaS App"` in the front matter
- **WHEN** the agent generates documentation or changelogs
- **THEN** the project name "My SaaS App" is used as the human-readable project identifier in all generated artifacts

#### Scenario: Unknown front matter keys are ignored
- **GIVEN** a `WORKFLOW.md` front matter containing `custom_key: some-value`
- **AND** `custom_key` is not in the defined schema
- **WHEN** the agent reads the file
- **THEN** the agent ignores `custom_key` without error and processes all known fields normally

#### Scenario: Malformed YAML falls back gracefully
- **GIVEN** a `WORKFLOW.md` with syntactically invalid YAML in the front matter (e.g., mismatched indentation)
- **WHEN** the agent reads the file
- **THEN** the agent reports a YAML parse warning
- **AND** reads the markdown body as plain context, treating the entire file as prose

### Requirement: WORKFLOW.md Prompt Template Variables
The markdown body of `WORKFLOW.md` SHALL support simple `{{ variable }}` substitution for context-aware prompt rendering. The supported template variables SHALL be:

- `{{ change.name }}`: The name of the current active change (e.g., `add-user-auth`).
- `{{ change.stage }}`: The current pipeline stage (e.g., `research`, `specs`, `design`).
- `{{ project.name }}`: The project name from front matter.

Template variables are resolved at skill invocation time. If a variable is referenced but unavailable (e.g., no active change during `/opsx:init`), it SHALL be replaced with an empty string. Unknown `{{ variable }}` tokens that do not match the supported list SHALL be left as-is (not substituted) to avoid breaking markdown content that happens to use `{{ }}` syntax for other purposes.

**User Story:** As a project maintainer I want to write behavioral instructions in WORKFLOW.md that adapt to the current change context, so that the AI receives dynamically relevant guidance without me needing to update the file for each change.

#### Scenario: Template variable resolves in active change context
- **GIVEN** a `WORKFLOW.md` body containing `"You are working on change {{ change.name }} at stage {{ change.stage }}"`
- **AND** the current change is `add-payment-gateway` at the `specs` stage
- **WHEN** the agent reads the WORKFLOW.md during the specs skill
- **THEN** the rendered context is `"You are working on change add-payment-gateway at stage specs"`

#### Scenario: Unavailable variable resolves to empty string
- **GIVEN** a `WORKFLOW.md` body containing `"Current change: {{ change.name }}"`
- **AND** there is no active change (e.g., during `/opsx:init`)
- **WHEN** the agent reads the WORKFLOW.md
- **THEN** the rendered context is `"Current change: "` (variable replaced with empty string)

#### Scenario: Unknown variable token left as-is
- **GIVEN** a `WORKFLOW.md` body containing `"Use {{ custom_token }} for reference"`
- **AND** `custom_token` is not in the supported variable list
- **WHEN** the agent reads the WORKFLOW.md
- **THEN** the rendered context retains `"Use {{ custom_token }} for reference"` unchanged

## Edge Cases

- **Both `WORKFLOW.md` and `constitution.md` present**: `WORKFLOW.md` takes precedence. The agent SHOULD note that `constitution.md` is superseded and may be removed.
- **`WORKFLOW.md` is empty**: Treated as absent — the agent falls back to `constitution.md`.
- **Front matter delimiter present but body is empty**: Valid; front matter settings are applied with no additional prompt context.
- **`WORKFLOW.md` is not at the project root**: If `WORKFLOW.md` is not found at the root, the agent SHALL NOT search subdirectories. The fallback to `constitution.md` applies.
- **Front matter contains `schema: unknown-schema`**: The agent SHALL report a warning that the specified schema is not recognized and continue with the `opsx-enhanced` default.

## Assumptions

<!-- ASSUMPTION: WORKFLOW.md is placed at the project root (same level as README.md), consistent with Symphony and other standard workflow file conventions. -->
<!-- ASSUMPTION: The agent (Claude) can parse YAML front matter from markdown files natively as part of its reading capability. -->
<!-- ASSUMPTION: Simple {{ variable }} substitution is sufficient for initial template rendering; a full Liquid engine is out of scope. -->
No further assumptions beyond those marked above.
