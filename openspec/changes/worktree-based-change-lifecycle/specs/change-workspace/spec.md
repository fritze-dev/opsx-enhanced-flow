## ADDED Requirements

### Requirement: Create Worktree-Based Workspace

The system SHALL create a git worktree with a dedicated feature branch when the user invokes `/opsx:new <change-name>` and `worktree.enabled` is `true` in WORKFLOW.md. The worktree path SHALL be computed by replacing `{change}` in the `worktree.path_pattern` field with the change name. The system SHALL run `git worktree add <path> -b <change-name>` to create the worktree and then `mkdir -p openspec/changes/<name>` inside the worktree. The system SHALL report the worktree path and branch name in its output. If the worktree path already exists as a git worktree, the system SHALL suggest switching to it instead of creating a new one.

**User Story:** As a developer I want each change to be created in its own git worktree, so that parallel changes are fully isolated and cannot conflict with each other.

#### Scenario: Create worktree when enabled

- **GIVEN** WORKFLOW.md has `worktree.enabled: true` and `worktree.path_pattern: .claude/worktrees/{change}`
- **AND** no worktree for "add-user-auth" exists
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system runs `git worktree add .claude/worktrees/add-user-auth -b add-user-auth`
- **AND** creates `openspec/changes/add-user-auth/` inside the worktree
- **AND** reports the worktree path and branch name

#### Scenario: Worktree already exists

- **GIVEN** WORKFLOW.md has `worktree.enabled: true`
- **AND** a worktree at `.claude/worktrees/add-user-auth` already exists
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL NOT create a duplicate worktree
- **AND** SHALL suggest switching to the existing worktree

#### Scenario: Worktree disabled falls back to directory creation

- **GIVEN** WORKFLOW.md does not have `worktree.enabled: true` (absent or false)
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL create `openspec/changes/add-user-auth/` in the current working tree (existing behavior)

### Requirement: Worktree Context Detection

All change-detecting skills (`ff`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`) SHALL detect the active change from worktree context before falling through to directory-based detection. The detection SHALL: (1) check if the current working directory is inside a git worktree by inspecting `git rev-parse --git-dir` for a path containing `/worktrees/`, (2) derive the change name from the current branch via `git rev-parse --abbrev-ref HEAD`, (3) verify that `openspec/changes/<branch-name>/` exists in the current working tree. If all checks pass, the skill SHALL auto-select this change and announce: "Detected worktree context: using change '<name>'". If the directory does not exist, the skill SHALL fall through to normal detection logic.

**User Story:** As a developer working in a worktree I want skills to automatically know which change I'm working on, so that I don't have to specify the change name every time.

#### Scenario: Auto-detect change from worktree

- **GIVEN** the user is in a git worktree on branch `add-user-auth`
- **AND** `openspec/changes/add-user-auth/` exists in the worktree
- **WHEN** any change-detecting skill is invoked without an explicit change name
- **THEN** the skill SHALL auto-select "add-user-auth"
- **AND** announce "Detected worktree context: using change 'add-user-auth'"

#### Scenario: Fall through when not in worktree

- **GIVEN** the user is in the main working tree (not a worktree)
- **WHEN** any change-detecting skill is invoked without an explicit change name
- **THEN** the skill SHALL use existing directory-based detection logic

#### Scenario: Fall through when change directory missing

- **GIVEN** the user is in a git worktree on branch `some-branch`
- **AND** `openspec/changes/some-branch/` does NOT exist
- **WHEN** any change-detecting skill is invoked
- **THEN** the skill SHALL fall through to normal detection logic

#### Scenario: Explicit argument overrides worktree detection

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **WHEN** a skill is invoked with explicit argument `other-change`
- **THEN** the skill SHALL use "other-change" regardless of worktree context

### Requirement: Worktree Cleanup After Archive

The `/opsx:archive` skill SHALL offer worktree cleanup after archiving when the session is in a worktree. The skill SHALL read `worktree.auto_cleanup` from WORKFLOW.md. If `auto_cleanup` is `true`, the system SHALL navigate to the main repository, run `git worktree remove <path>`, and delete the branch if it has been merged to main. If `auto_cleanup` is `false` or absent, the system SHALL inform the user how to clean up manually (`git worktree remove <path>`).

**User Story:** As a developer I want worktrees cleaned up after archiving, so that stale worktrees don't accumulate on disk.

#### Scenario: Auto-cleanup after archive

- **GIVEN** the user is in a worktree at `.claude/worktrees/add-user-auth`
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system navigates to the main repository
- **AND** runs `git worktree remove .claude/worktrees/add-user-auth`
- **AND** deletes the merged branch `add-user-auth`

#### Scenario: Manual cleanup instructions

- **GIVEN** the user is in a worktree
- **AND** WORKFLOW.md has `worktree.auto_cleanup: false` or the field is absent
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system informs the user: "Worktree at <path> still exists. Run `git worktree remove <path>` to clean up."

#### Scenario: Not in worktree — no cleanup

- **GIVEN** the user is in the main working tree
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system SHALL NOT mention worktree cleanup (existing behavior)

## MODIFIED Requirements

### Requirement: Create Change Workspace

The system SHALL create a change workspace when the user invokes `/opsx:new <change-name>`. If `worktree.enabled` is `true` in WORKFLOW.md, the system SHALL create a git worktree (see "Create Worktree-Based Workspace" requirement). Otherwise, the workspace SHALL be created by running `mkdir -p openspec/changes/<name>`. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

**User Story:** As a developer I want to create a new change workspace with a single command, so that I can immediately begin the spec-driven workflow without manual directory setup.

#### Scenario: Create workspace with explicit name

- **GIVEN** no change named "add-user-auth" exists
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system creates the workspace (worktree if enabled, directory otherwise)
- **AND** the system reads WORKFLOW.md to determine the artifact pipeline and displays the artifact status and first artifact template

#### Scenario: Derive name from description

- **WHEN** the user invokes `/opsx:new` and provides the description "add user authentication"
- **THEN** the system derives the kebab-case name `add-user-auth`
- **AND** creates the workspace at `openspec/changes/add-user-auth/`

#### Scenario: Reject invalid name format

- **GIVEN** the user provides a name containing uppercase letters or special characters (e.g., "Add_User Auth")
- **WHEN** the system attempts to create the workspace
- **THEN** the system SHALL ask the user for a valid kebab-case name
- **AND** SHALL NOT create the workspace until a valid name is provided

#### Scenario: Change name already exists

- **GIVEN** a change named "add-user-auth" already exists at `openspec/changes/add-user-auth/`
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL NOT create a duplicate workspace
- **AND** SHALL suggest continuing the existing change instead

## Edge Cases

- **Branch already exists**: If `git worktree add` fails because the branch already exists, try `git worktree add <path> <branch>` to reuse the existing branch.
- **Worktree path exists but is not a git worktree**: Fail with error — do not overwrite arbitrary directories.
- **Dirty worktree during cleanup**: `git worktree remove` fails on dirty worktrees. Report the error and suggest `--force` or committing changes first.
- **Multiple changes in a worktree**: Each worktree should contain exactly one change matching the branch name. Additional `openspec/changes/` directories are ignored by worktree detection.
- **Worktree config absent**: If WORKFLOW.md has no `worktree` section, treat as `worktree.enabled: false`.

## Assumptions

- Git version supports worktree commands (git 2.5+). <!-- ASSUMPTION: Git worktree support -->
- The `.claude/` directory in `.gitignore` covers `.claude/worktrees/`. <!-- ASSUMPTION: Gitignore coverage -->
No further assumptions beyond those marked above.
