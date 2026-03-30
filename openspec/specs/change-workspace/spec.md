---
order: 3
category: change-workflow
---
## Purpose

Manages the change lifecycle including workspace creation (`/opsx:new`), schema-defined workspace structure, and change archiving (`/opsx:archive`) with date-prefixed directory naming and automatic spec sync.

## Requirements

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

### Requirement: Workspace Structure

The created workspace SHALL contain the artifacts defined by the active schema. The artifact pipeline sequence SHALL be determined by the schema definition in `openspec/schemas/opsx-enhanced/schema.yaml` (e.g., research, proposal, specs, design, preflight, tasks for the `opsx-enhanced` schema). Each artifact SHALL have a defined dependency chain that gates progression from one stage to the next.

**User Story:** As a developer I want the workspace to be pre-structured according to the workflow schema, so that I know exactly which artifacts need to be produced and in what order.

#### Scenario: Workspace contains schema-defined structure

- **GIVEN** the user creates a new change
- **WHEN** the workspace is created
- **THEN** the directory `openspec/changes/<name>/` SHALL exist
- **AND** reading schema.yaml and checking file existence SHALL report all pipeline artifacts as pending

#### Scenario: Artifact dependency gating

- **GIVEN** a workspace created with the `opsx-enhanced` schema
- **WHEN** the user checks artifact status before creating any artifacts
- **THEN** only the first artifact in the pipeline (research) SHALL have status "ready"
- **AND** downstream artifacts (proposal, specs, design, preflight, tasks) SHALL be blocked by unmet dependencies

### Requirement: Archive Completed Change

The system SHALL move a completed change workspace to `openspec/changes/archive/` with a date-prefixed directory name in the format `YYYY-MM-DD-<change-name>` when the user invokes `/opsx:archive`. Before archiving, the system SHALL automatically sync delta specs to baseline specs if unsynced delta specs exist, showing a summary of applied changes. The system SHALL NOT prompt the user to choose between syncing and archiving. When sync is delegated to a subagent, the subagent prompt SHALL convey that sync is a blocking prerequisite for archive and that the result MUST be returned before the workflow continues. After the sync agent returns, the archive skill SHALL validate sync completion by checking file system state: for each delta spec capability at `openspec/changes/<name>/specs/<capability>/`, a corresponding baseline spec MUST exist at `openspec/specs/<capability>/spec.md`. The system SHALL NOT proceed to archive unless all delta spec capabilities have corresponding baseline specs. If the archive target directory already exists, the system SHALL fail with an error and suggest a resolution.

**User Story:** As a developer I want completed changes archived with a date prefix and automatic spec sync, so that the project history is preserved chronologically and baseline specs stay up to date without unnecessary prompts.

#### Scenario: Archive a completed change

- **GIVEN** a change named "add-user-auth" with all artifacts and tasks complete
- **AND** no delta specs exist in the change
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system moves `openspec/changes/add-user-auth/` to `openspec/changes/archive/2026-03-02-add-user-auth/`
- **AND** displays a summary including change name, schema, and archive location

#### Scenario: Auto-sync before archiving

- **GIVEN** a change named "add-user-auth" with delta specs in `openspec/changes/add-user-auth/specs/`
- **AND** the delta specs have not been synced to baseline
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL invoke sync via a subagent whose prompt conveys that sync is a blocking prerequisite
- **AND** SHALL wait for the sync agent to return its result
- **AND** SHALL validate sync completion by checking that `openspec/specs/user-auth/spec.md` exists
- **AND** SHALL display a summary of applied changes (additions, modifications, removals)
- **AND** SHALL proceed to archive only after validation passes

#### Scenario: State-based validation prevents premature archive

- **GIVEN** a change with delta specs for capabilities "user-auth" and "data-export"
- **WHEN** the sync subagent returns
- **THEN** the archive skill SHALL check that `openspec/specs/user-auth/spec.md` exists
- **AND** SHALL check that `openspec/specs/data-export/spec.md` exists
- **AND** SHALL NOT proceed to the archive step (mv to archive directory) until all checks pass

#### Scenario: Baseline spec missing after sync

- **GIVEN** a change with a delta spec for capability "user-auth"
- **WHEN** the sync subagent returns
- **AND** `openspec/specs/user-auth/spec.md` does not exist
- **THEN** the archive skill SHALL report which capabilities are missing baseline specs
- **AND** SHALL NOT proceed to archive

#### Scenario: Archive with incomplete artifacts

- **GIVEN** a change with some artifacts not marked as done
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL display a warning listing the incomplete artifacts
- **AND** SHALL ask the user to confirm before proceeding
- **AND** SHALL archive if the user confirms

#### Scenario: Archive target already exists

- **GIVEN** a change named "add-user-auth"
- **AND** an archive already exists at `openspec/changes/archive/2026-03-02-add-user-auth/`
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL fail with an error
- **AND** SHALL suggest renaming the existing archive or using a different date

#### Scenario: Archive with incomplete tasks

- **GIVEN** a change with a tasks.md containing 3 of 7 checkboxes marked complete
- **WHEN** the user invokes `/opsx:archive`
- **THEN** the system SHALL display a warning showing "3/7 tasks complete"
- **AND** SHALL ask the user to confirm before proceeding

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

The `/opsx:archive` skill SHALL offer worktree cleanup after archiving when the session is in a worktree. The skill SHALL read `worktree.auto_cleanup` from WORKFLOW.md. If `auto_cleanup` is `true`, the system SHALL navigate to the main repository, run `git worktree remove <path>`, and delete the branch. To determine whether the branch has been merged, the system SHALL first check the PR merge status via `gh pr view <branch> --json state`. If the PR state is `MERGED`, the system SHALL use `git branch -D <branch>` (force delete). If `gh` is unavailable, not authenticated, or no PR exists for the branch, the system SHALL fall back to `git branch -d <branch>`. If `auto_cleanup` is `false` or absent, the system SHALL inform the user how to clean up manually (`git worktree remove <path>`).

**User Story:** As a developer I want worktrees cleaned up after archiving, so that stale worktrees don't accumulate on disk.

#### Scenario: Auto-cleanup after archive

- **GIVEN** the user is in a worktree at `.claude/worktrees/add-user-auth`
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system navigates to the main repository
- **AND** runs `git worktree remove .claude/worktrees/add-user-auth`
- **AND** deletes the merged branch `add-user-auth`

#### Scenario: Branch deletion after squash merge

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **AND** the PR for `add-user-auth` was squash-merged to main
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the system attempts to delete the branch during cleanup
- **THEN** the system runs `gh pr view add-user-auth --json state`
- **AND** the result shows `"state": "MERGED"`
- **AND** the system runs `git branch -D add-user-auth`

#### Scenario: Branch deletion without gh CLI

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **AND** `gh` CLI is unavailable or not authenticated
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the system attempts to delete the branch during cleanup
- **THEN** the system falls back to `git branch -d add-user-auth`

#### Scenario: Branch deletion without PR

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **AND** no PR exists for branch `add-user-auth`
- **AND** WORKFLOW.md has `worktree.auto_cleanup: true`
- **WHEN** the system attempts to delete the branch during cleanup
- **THEN** the system falls back to `git branch -d add-user-auth`

#### Scenario: Manual cleanup instructions

- **GIVEN** the user is in a worktree
- **AND** WORKFLOW.md has `worktree.auto_cleanup: false` or the field is absent
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system informs the user: "Worktree at <path> still exists. Run `git worktree remove <path>` to clean up."

#### Scenario: Not in worktree — no cleanup

- **GIVEN** the user is in the main working tree
- **WHEN** the user completes `/opsx:archive`
- **THEN** the system SHALL NOT mention worktree cleanup (existing behavior)

## Edge Cases

- **No active changes**: If no active changes exist when archiving, the system SHALL inform the user and suggest creating a new change.
- **Multiple active changes**: If multiple changes exist and the user does not specify which to archive, the system SHALL list available changes and ask the user to select one. It SHALL NOT auto-select.
- **Branch already exists**: If `git worktree add` fails because the branch already exists, try `git worktree add <path> <branch>` to reuse the existing branch.
- **Worktree path exists but is not a git worktree**: Fail with error — do not overwrite arbitrary directories.
- **Dirty worktree during cleanup**: `git worktree remove` fails on dirty worktrees. Report the error and suggest `--force` or committing changes first.
- **`gh` CLI unavailable during branch deletion**: Fall back to `git branch -d`. If that also fails (squash merge without `gh`), report the error and suggest `git branch -D <branch>` manually.
- **Multiple changes in a worktree**: Each worktree should contain exactly one change matching the branch name. Additional `openspec/changes/` directories are ignored by worktree detection.
- **Worktree config absent**: If WORKFLOW.md has no `worktree` section, treat as `worktree.enabled: false`.
- **Baseline spec already existed before sync:** If the baseline spec already existed (e.g., MODIFIED delta), the existence check still passes — the sync updated it in place. The check validates that sync didn't fail to create new specs, not that it modified existing ones correctly (content correctness is the sync skill's responsibility).
- **Delta specs already synced:** When delta specs exist but are already in sync with baseline, the auto-sync is a no-op. The system proceeds to archive without additional output.
- **Sync failure:** If the sync operation fails, the system SHALL report the error and stop. It SHALL NOT proceed to archive with unsynced specs.

## Assumptions

- The system clock provides the correct date for the YYYY-MM-DD prefix. <!-- ASSUMPTION: System clock accuracy -->
- The file system supports the mv operation atomically within the same mount point. <!-- ASSUMPTION: Atomic mv -->
No further assumptions beyond those marked above.
