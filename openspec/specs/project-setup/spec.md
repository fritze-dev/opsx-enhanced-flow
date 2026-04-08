---
order: 1
category: setup
---
## Purpose

Handles one-time project initialization via `/opsx:setup`, including WORKFLOW.md generation, Smart Template installation, constitution creation, legacy migration, and post-setup validation.

## Requirements

### Requirement: Install OpenSpec Workflow
The system SHALL provide `/opsx:setup` as the single entry point for project setup. The setup command SHALL: (1) copy Smart Templates from the plugin's `templates/` directory (at `${CLAUDE_PLUGIN_ROOT}/templates/`) into the project's `openspec/templates/` directory, (2) copy `openspec/WORKFLOW.md` from the plugin's workflow template at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` (skip if WORKFLOW.md already exists), and (3) create `openspec/CONSTITUTION.md` placeholder if none exists. The setup command SHALL be idempotent — running it on an already-initialized project SHALL skip completed steps.

The setup command SHALL check for `gh` CLI availability and authentication. If `gh` is available and authenticated, the setup command SHALL ask the user whether to enable worktree-based change isolation. If the user opts in, the setup command SHALL uncomment the `worktree:` section in the generated WORKFLOW.md and set `enabled: true`. The setup command SHALL also offer to configure the GitHub repository merge strategy for rebase-merge via `gh api`.

The setup command SHALL NOT install any external CLI tools or require Node.js/npm as prerequisites.

The setup command SHALL ensure target directories exist (via `mkdir -p`) before copying files.

**User Story:** As a new user I want a single `/opsx:setup` command that sets up everything including optional worktree mode, so that I do not have to manually configure the project.

#### Scenario: First-time project initialization
- **GIVEN** a project directory without the opsx-enhanced workflow installed
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL copy Smart Templates from `${CLAUDE_PLUGIN_ROOT}/templates/` to `openspec/templates/`, copy WORKFLOW.md from `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`, create `openspec/CONSTITUTION.md` placeholder, and verify the setup

#### Scenario: Idempotent re-initialization
- **GIVEN** a project that has already been initialized
- **WHEN** the user runs `/opsx:setup` again
- **THEN** the system SHALL skip already-completed steps, preserve existing CONSTITUTION.md and WORKFLOW.md, and report what was already in place

#### Scenario: WORKFLOW.md copied from template
- **GIVEN** a project directory without `openspec/WORKFLOW.md`
- **AND** the plugin has `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL copy workflow.md to `openspec/WORKFLOW.md`

#### Scenario: Worktree opt-in during setup
- **GIVEN** the `gh` CLI is installed and authenticated
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL ask whether to enable worktree-based change isolation
- **AND** if the user opts in, SHALL uncomment the `worktree:` section in WORKFLOW.md and set `enabled: true`
- **AND** SHALL offer to configure the GitHub repo for rebase-merge

#### Scenario: No gh CLI available
- **GIVEN** the `gh` CLI is not installed or not authenticated
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL skip the worktree opt-in question
- **AND** SHALL leave the `worktree:` section commented out in WORKFLOW.md

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

### Requirement: Template Merge on Re-Setup
When `/opsx:setup` runs on an already-initialized project (re-setup after plugin update), the system SHALL use Smart Template `version` fields to detect user customizations and merge plugin updates instead of blindly overwriting. For each template file in `${CLAUDE_PLUGIN_ROOT}/templates/`:

1. **Read** the plugin template's `version` field and the local template's `version` field at `openspec/templates/<path>`.
2. **Compare versions:**
   - If the local template does not exist: copy the plugin template (fresh install).
   - If the local `version` matches the plugin `version` AND content is identical: skip (already up to date).
   - If the local `version` matches the plugin `version` BUT content differs: the user has customized the template. Keep the local version and report: "Template <name> has local customizations — skipped."
   - If the plugin `version` is higher than the local `version` AND the local content matches the previous plugin version (no user changes): update silently to the new plugin template.
   - If the plugin `version` is higher AND the local content has been customized: merge is needed. The system SHALL present both versions to the user and ask them to resolve differences. Report: "Template <name> has both local customizations and plugin updates — merge required."
   - If the local template has no `version` field (legacy): treat as version 0 and apply the same logic (likely results in silent update if content matches plugin template, or merge prompt if customized).

The merge detection SHALL apply to all Smart Templates including docs templates in subdirectories and WORKFLOW.md (which is copied from `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`). WORKFLOW.md is especially important for merge detection because the plugin frequently updates behavioral fields (`apply.instruction`, `post_artifact`, `context`) while users customize project-specific fields (`worktree`, `docs_language`, pipeline order). The existing skip-if-exists behavior for WORKFLOW.md is replaced by version-based merge detection. CONSTITUTION.md is excluded from template merge — it is user-owned content generated by bootstrap, not a plugin template.

**User Story:** As a user who has customized my templates I want plugin updates to preserve my customizations, so that re-running `/opsx:setup` after a plugin update does not silently destroy my changes.

#### Scenario: Unchanged template updated silently
- **GIVEN** a local template `openspec/templates/research.md` with `version: 1` matching the plugin template content exactly
- **AND** the plugin update has `version: 2` with updated instruction text
- **WHEN** the user runs `/opsx:setup`
- **THEN** the local template SHALL be replaced with the plugin's version 2 template
- **AND** the report SHALL show "Template research.md updated (v1 → v2)"

#### Scenario: User-customized template preserved
- **GIVEN** a local template `openspec/templates/research.md` with `version: 1` but modified instruction content
- **AND** the plugin template also has `version: 1`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the local template SHALL NOT be overwritten
- **AND** the report SHALL show "Template research.md has local customizations — skipped"

#### Scenario: Customized template with plugin update triggers merge
- **GIVEN** a local template with `version: 1` and custom content
- **AND** the plugin template has `version: 2` with new content
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL present both versions and ask the user to resolve
- **AND** SHALL NOT overwrite the local template without user confirmation

#### Scenario: Legacy template without version field
- **GIVEN** a local template with no `version` field in frontmatter
- **AND** the plugin template has `version: 1`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system SHALL treat the local version as 0
- **AND** SHALL update silently if content matches the plugin template, or prompt for merge if customized

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

### Requirement: WORKFLOW.md Template File

The plugin SHALL include a workflow template file at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` containing the default WORKFLOW.md content with YAML frontmatter (`templates_dir`, `pipeline`, `apply`, `post_artifact`, `context`, `docs_language`) and a commented-out `worktree:` section. The `/opsx:setup` skill SHALL copy this template to `openspec/WORKFLOW.md` instead of generating the content inline. This ensures WORKFLOW.md is maintained as a template file consistent with the constitution template pattern.

**User Story:** As a plugin maintainer I want WORKFLOW.md content maintained as a template file, so that it is consistent with the constitution template and easier to update across versions.

#### Scenario: Template contains default pipeline configuration

- **GIVEN** the workflow template at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`
- **WHEN** its content is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, and `context` in YAML frontmatter

#### Scenario: Template contains commented-out worktree section

- **GIVEN** the workflow template at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`
- **WHEN** its content is inspected
- **THEN** it SHALL contain a commented-out `worktree:` section with `enabled`, `path_pattern`, and `auto_cleanup` fields

### Requirement: Environment Checks During Setup

The setup command SHALL check the environment for: (1) `gh` CLI availability by running `gh --version` and authentication by running `gh auth status`, (2) git version by running `git --version` and verifying it is 2.5+ (required for worktree support), (3) `.gitignore` contains a `/.claude/` entry (required for worktree paths to be excluded from version control). The results SHALL be reported in the setup summary. The environment checks SHALL NOT block setup — they only inform which optional features (worktree mode, PR creation, merge strategy) are available. If git version is below 2.5, the system SHALL skip the worktree opt-in question and report that worktree mode requires git 2.5+. If `/.claude/` is not in `.gitignore`, the system SHALL offer to add it when the user opts into worktree mode.

**User Story:** As a user I want setup to detect my environment capabilities, so that I know which features are available without manual checking.

#### Scenario: gh CLI detected and authenticated

- **GIVEN** the `gh` CLI is installed and authenticated
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system reports "gh CLI: available and authenticated"
- **AND** offers worktree mode and merge strategy configuration

#### Scenario: gh CLI not installed

- **GIVEN** the `gh` CLI is not installed
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system reports "gh CLI: not found"
- **AND** skips worktree and merge strategy options

#### Scenario: Git version supports worktrees

- **GIVEN** git version is 2.5 or higher
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system reports "git: version X.Y (worktree support: yes)"

#### Scenario: Git version too old for worktrees

- **GIVEN** git version is below 2.5
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system reports "git: version X.Y (worktree support: no — requires 2.5+)"
- **AND** skips the worktree opt-in question

#### Scenario: Gitignore missing .claude/ entry

- **GIVEN** `.gitignore` does not contain `/.claude/`
- **AND** the user opts into worktree mode
- **WHEN** setup configures worktree mode
- **THEN** the system SHALL offer to add `/.claude/` to `.gitignore`
- **AND** if the user agrees, append the entry to `.gitignore`

#### Scenario: Gitignore already has .claude/ entry

- **GIVEN** `.gitignore` already contains `/.claude/`
- **WHEN** the user runs `/opsx:setup`
- **THEN** the system reports ".gitignore: /.claude/ entry present"

### Requirement: GitHub Merge Strategy Configuration

When the user opts in during setup and `gh` CLI is available, the system SHALL configure the GitHub repository merge strategy for rebase-merge by running `gh api repos/{owner}/{repo} -X PATCH` to set `allow_rebase_merge=true`. The system SHALL report the configuration result. If the API call fails (e.g., insufficient permissions), the system SHALL report the failure and continue setup.

**User Story:** As a team lead I want the repo configured for rebase-merge during setup, so that worktree-based changes merge cleanly with linear history.

#### Scenario: Configure rebase-merge strategy

- **GIVEN** the user opts in to worktree mode during setup
- **AND** the `gh` CLI is authenticated with repo admin permissions
- **WHEN** setup configures the merge strategy
- **THEN** the system runs `gh api repos/{owner}/{repo} -X PATCH -f allow_rebase_merge=true`
- **AND** reports "GitHub merge strategy: rebase-merge enabled"

#### Scenario: Merge strategy configuration fails

- **GIVEN** the user opts in to worktree mode
- **AND** the `gh` CLI lacks admin permissions
- **WHEN** setup attempts to configure the merge strategy
- **THEN** the system reports the failure
- **AND** continues with the rest of setup

## Edge Cases

- If the user does not have write permissions, setup SHALL fail before making changes.
- If migration encounters both WORKFLOW.md and legacy schema.yaml (manual partial migration), setup SHALL preserve WORKFLOW.md and skip migration.
- If `openspec/constitution.md` (lowercase) and `openspec/CONSTITUTION.md` (caps) both exist during migration, setup SHALL use the lowercase content and rename to caps.
- **Workflow template missing from plugin**: If `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` does not exist, report an error and suggest reinstalling the plugin.
- **Template merge with subdirectories**: The merge detection SHALL recursively process templates in subdirectories (e.g., `templates/specs/spec.md`, `templates/docs/capability.md`).
- **Plugin downgrades**: If the plugin `version` is lower than the local `version`, the system SHALL warn and skip (do not downgrade).
- **gh CLI installed but not authenticated**: Report "gh CLI: installed but not authenticated" and skip worktree opt-in.
- **User declines worktree mode**: Leave WORKFLOW.md with commented-out `worktree:` section — no changes needed.

## Assumptions

- The `gh` CLI `--version` command returns exit code 0 when installed. <!-- ASSUMPTION: gh version check -->
- The `gh auth status` command returns exit code 0 when authenticated. <!-- ASSUMPTION: gh auth check -->
- `git --version` output contains a parseable version number (e.g., "git version 2.43.0"). <!-- ASSUMPTION: git version parseable -->
No further assumptions beyond those marked above.
