---
order: 1
category: setup
---
## Purpose

Handles one-time project initialization via `/opsx:setup`, including WORKFLOW.md generation, Smart Template installation, constitution creation, legacy migration, and post-setup validation.

## Requirements

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

### Requirement: Legacy Migration
The setup command SHALL detect legacy project layouts (presence of `openspec/schemas/opsx-enhanced/schema.yaml` without `openspec/WORKFLOW.md`) and perform migration: (1) generate WORKFLOW.md from schema.yaml content and config.yaml settings, (2) move templates from `openspec/schemas/opsx-enhanced/templates/` to `openspec/templates/` converting them to Smart Template format, (3) rename `openspec/constitution.md` to `openspec/CONSTITUTION.md`, (4) remove the `openspec/schemas/` directory and `openspec/config.yaml` after successful migration.

**User Story:** As an existing user I want `/opsx:setup` to automatically migrate my project from the old schema layout, so that I don't have to manually restructure files.

#### Scenario: Legacy layout detected and migrated
- **GIVEN** a project with `openspec/schemas/opsx-enhanced/schema.yaml` but no `openspec/WORKFLOW.md`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL generate WORKFLOW.md, move and convert templates, rename constitution, and remove legacy files

#### Scenario: Migration preserves existing content
- **GIVEN** a legacy project with custom constitution content
- **WHEN** migration runs
- **THEN** the CONSTITUTION.md SHALL contain the original constitution content (renamed, not regenerated)

#### Scenario: Already migrated project is not re-migrated
- **GIVEN** a project with `openspec/WORKFLOW.md` already present
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL skip migration and report that WORKFLOW.md already exists

### Requirement: Setup Validation
The setup command SHALL validate after all steps complete. Validation SHALL confirm that `openspec/WORKFLOW.md` is readable, `openspec/templates/` contains Smart Templates, and `openspec/CONSTITUTION.md` is present. The setup command SHALL report a summary.

**User Story:** As a user I want setup to verify everything works, so that I can trust the environment is ready.

#### Scenario: Successful validation after fresh setup
- **GIVEN** the setup command has completed all steps
- **WHEN** validation runs
- **THEN** the system SHALL verify WORKFLOW.md is readable, templates directory exists with files, and CONSTITUTION.md is present

#### Scenario: Validation detects partial setup failure
- **GIVEN** the setup completed but template copy failed
- **WHEN** validation runs
- **THEN** the system SHALL detect the missing templates and report the failure

## Edge Cases

- If the user does not have write permissions, setup SHALL fail before making changes.
- If migration encounters both WORKFLOW.md and legacy schema.yaml (manual partial migration), setup SHALL preserve WORKFLOW.md and skip migration.
- If `openspec/constitution.md` (lowercase) and `openspec/CONSTITUTION.md` (caps) both exist during migration, setup SHALL use the lowercase content and rename to caps.

## Assumptions

No assumptions made.
