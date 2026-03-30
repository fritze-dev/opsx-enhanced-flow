## MODIFIED Requirements

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

## ADDED Requirements

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

- **Workflow template missing from plugin**: If `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` does not exist, report an error and suggest reinstalling the plugin.
- **gh CLI installed but not authenticated**: Report "gh CLI: installed but not authenticated" and skip worktree opt-in.
- **User declines worktree mode**: Leave WORKFLOW.md with commented-out `worktree:` section — no changes needed.

## Assumptions

- The `gh` CLI `--version` command returns exit code 0 when installed. <!-- ASSUMPTION: gh version check -->
- The `gh auth status` command returns exit code 0 when authenticated. <!-- ASSUMPTION: gh auth check -->
- `git --version` output contains a parseable version number (e.g., "git version 2.43.0"). <!-- ASSUMPTION: git version parseable -->
No further assumptions beyond those marked above.
