## MODIFIED Requirements

### Requirement: Install OpenSpec Workflow

The system SHALL provide `/opsx:setup` as the single entry point for project setup. The setup command SHALL: (1) copy Smart Templates from the plugin's `templates/` directory (at `${CLAUDE_PLUGIN_ROOT}/templates/`) into the project's `openspec/templates/` directory, (2) generate `openspec/WORKFLOW.md` with pipeline configuration in YAML frontmatter (templates_dir, pipeline, apply, post_artifact, context, docs_language), and (3) create `openspec/CONSTITUTION.md` placeholder if none exists. The setup command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps.

The setup command SHALL NOT install any external CLI tools or require Node.js/npm as prerequisites.

The setup command SHALL ensure target directories exist (via `mkdir -p`) before copying files.

The generated WORKFLOW.md SHALL include a commented-out `docs_language: English` field and a `context` field pointing to `openspec/CONSTITUTION.md` with an English-enforcement rule for workflow artifacts.

**User Story:** As a new user I want a single `/opsx:setup` command that sets up everything, so that I do not have to manually configure the project.

#### Scenario: First-time project initialization

- **GIVEN** a project directory without the opsx-enhanced workflow installed
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL copy Smart Templates from `${CLAUDE_PLUGIN_ROOT}/templates/` to `openspec/templates/`, generate `openspec/WORKFLOW.md`, create `openspec/CONSTITUTION.md` placeholder, and verify the setup

#### Scenario: Idempotent re-initialization

- **GIVEN** a project that has already been initialized
- **WHEN** the user runs `/opsx:setup` again
- **THEN** the system SHALL skip already-completed steps, preserve existing CONSTITUTION.md and WORKFLOW.md, and report what was already in place

#### Scenario: WORKFLOW.md generated with correct frontmatter

- **GIVEN** a project directory without `openspec/WORKFLOW.md`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the generated WORKFLOW.md SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, `context` fields in YAML frontmatter

## Edge Cases

- **Old plugin version with `openspec/templates/` path**: If a consumer has an older cached plugin where templates are at `${CLAUDE_PLUGIN_ROOT}/openspec/templates/`, the setup skill SHALL fail gracefully with a message to update the plugin.

## Assumptions

- `CLAUDE_PLUGIN_ROOT` points to the `src/` directory after the restructuring. <!-- ASSUMPTION: plugin root after restructure -->
