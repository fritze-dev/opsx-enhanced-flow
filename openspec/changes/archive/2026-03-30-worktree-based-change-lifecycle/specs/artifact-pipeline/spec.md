## MODIFIED Requirements

### Requirement: WORKFLOW.md Owns Pipeline Configuration

`openspec/WORKFLOW.md` SHALL serve as the pipeline orchestration file. Its YAML frontmatter SHALL contain: `templates_dir` pointing to the Smart Templates directory, `pipeline` array defining artifact order, `apply` object with `requires` and `instruction`, `post_artifact` instructions for commit/push/PR, `context` pointing to the constitution, optionally `docs_language`, and optionally `worktree` object with `enabled` (boolean), `path_pattern` (string with `{change}` placeholder), and `auto_cleanup` (boolean). Skills SHALL read WORKFLOW.md for all pipeline-level configuration.

**User Story:** As a workflow maintainer I want pipeline orchestration in a single WORKFLOW.md file, so that configuration is not scattered across schema.yaml and config.yaml.

#### Scenario: WORKFLOW.md contains pipeline orchestration

- **GIVEN** the `openspec/WORKFLOW.md` file
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, and `context` fields

#### Scenario: WORKFLOW.md contains optional worktree configuration

- **GIVEN** the `openspec/WORKFLOW.md` file with worktree mode enabled
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain a `worktree` object with `enabled: true`, `path_pattern`, and `auto_cleanup` fields

#### Scenario: WORKFLOW.md without worktree configuration

- **GIVEN** the `openspec/WORKFLOW.md` file without a `worktree` section
- **WHEN** a skill reads WORKFLOW.md
- **THEN** the skill SHALL treat worktree mode as disabled and use existing directory-based behavior

### Requirement: Post-Artifact Commit and PR Integration

WORKFLOW.md SHALL define a `post_artifact` field containing instructions that the `/opsx:ff` skill executes after creating each artifact. The `post_artifact` instruction SHALL direct the agent to: (1) check the current branch — if already on `<change-name>` branch (e.g., in a worktree), skip branch creation; if on main, create the branch via `git checkout -b <change-name>`; if on another branch, switch to it via `git checkout <change-name>`, (2) stage and commit the change artifacts with a WIP commit message including the artifact ID, (3) push the branch to the remote, and (4) on the first push only, create a draft PR via `gh pr create --draft`. If the `post_artifact` field is absent from WORKFLOW.md (backward compatibility), the skill SHALL skip post-artifact operations silently.

**User Story:** As a developer I want every artifact committed incrementally with a draft PR created on the first commit, so that my team has early visibility and every pipeline stage is tracked in version control.

#### Scenario: First artifact triggers branch and PR creation

- **GIVEN** a change workspace where no feature branch exists yet
- **AND** the `gh` CLI is installed and authenticated
- **WHEN** the agent finishes creating the first artifact
- **THEN** the agent SHALL create a feature branch, commit, push, and create a draft PR

#### Scenario: Subsequent artifacts commit and push only

- **GIVEN** a change workspace with an existing feature branch and draft PR
- **WHEN** the agent finishes creating a subsequent artifact
- **THEN** the agent SHALL commit and push but SHALL NOT create a new PR

#### Scenario: Worktree skips branch creation

- **GIVEN** a change workspace in a git worktree already on the `<change-name>` branch
- **WHEN** the agent finishes creating an artifact
- **THEN** the agent SHALL skip the branch creation step and proceed directly to staging, committing, and pushing

#### Scenario: Graceful degradation without gh CLI

- **GIVEN** the `gh` CLI is not installed or not authenticated
- **WHEN** the agent finishes creating the first artifact
- **THEN** the agent SHALL create the branch, commit, attempt push, and skip PR creation

#### Scenario: WORKFLOW.md without post_artifact field

- **GIVEN** a WORKFLOW.md that does not contain a `post_artifact` field
- **WHEN** the agent finishes creating an artifact
- **THEN** the agent SHALL skip post-artifact operations and proceed normally

## Edge Cases

- **Worktree config with invalid path_pattern**: If `path_pattern` does not contain `{change}`, the system SHALL report an error during `/opsx:new`.
- **Worktree config with empty path_pattern**: SHALL default to `.claude/worktrees/{change}`.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs. <!-- ASSUMPTION: gh CLI authentication -->
No further assumptions beyond those marked above.
