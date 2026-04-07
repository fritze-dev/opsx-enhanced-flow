## MODIFIED Requirements

### Requirement: Create Change Workspace

The system SHALL create a change workspace when the user invokes `/opsx:new <change-name>`. The workspace directory SHALL use a creation-date prefix in the format `YYYY-MM-DD-<change-name>`, set at creation time and never changed. If `worktree.enabled` is `true` in WORKFLOW.md, the system SHALL create a git worktree (see "Create Worktree-Based Workspace" requirement). Otherwise, the workspace SHALL be created by running `mkdir -p openspec/changes/YYYY-MM-DD-<name>`. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

**User Story:** As a developer I want to create a new change workspace with a date-prefixed directory, so that changes are chronologically ordered from creation and I can immediately begin the spec-driven workflow.

#### Scenario: Create workspace with date prefix

- **GIVEN** no change named "add-user-auth" exists
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system creates the workspace at `openspec/changes/2026-04-01-add-user-auth/`
- **AND** reads WORKFLOW.md to determine the artifact pipeline and displays the artifact status

#### Scenario: Derive name from description

- **WHEN** the user invokes `/opsx:new` and provides the description "add user authentication"
- **AND** today's date is 2026-04-01
- **THEN** the system derives the kebab-case name `add-user-auth`
- **AND** creates the workspace at `openspec/changes/2026-04-01-add-user-auth/`

#### Scenario: Reject invalid name format

- **GIVEN** the user provides a name containing uppercase letters or special characters (e.g., "Add_User Auth")
- **WHEN** the system attempts to create the workspace
- **THEN** the system SHALL ask the user for a valid kebab-case name
- **AND** SHALL NOT create the workspace until a valid name is provided

#### Scenario: Change name already exists

- **GIVEN** a change directory matching `*-add-user-auth` already exists under `openspec/changes/`
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL NOT create a duplicate workspace
- **AND** SHALL suggest continuing the existing change instead

### Requirement: Workspace Structure

The created workspace SHALL contain the artifacts defined by the pipeline in WORKFLOW.md. The artifact pipeline sequence SHALL be determined by the `pipeline` array in `openspec/WORKFLOW.md` frontmatter (e.g., research, proposal, specs, design, preflight, tasks). Each artifact SHALL have a defined dependency chain that gates progression from one stage to the next.

**User Story:** As a developer I want the workspace to be pre-structured according to the workflow pipeline, so that I know exactly which artifacts need to be produced and in what order.

#### Scenario: Workspace contains pipeline-defined structure

- **GIVEN** the user creates a new change
- **WHEN** the workspace is created
- **THEN** the directory `openspec/changes/YYYY-MM-DD-<name>/` SHALL exist
- **AND** reading WORKFLOW.md and checking file existence SHALL report all pipeline artifacts as pending

#### Scenario: Artifact dependency gating

- **GIVEN** a workspace created with the standard pipeline
- **WHEN** the user checks artifact status before creating any artifacts
- **THEN** only the first artifact in the pipeline (research) SHALL have status "ready"
- **AND** downstream artifacts (proposal, specs, design, preflight, tasks) SHALL be blocked by unmet dependencies

### Requirement: Create Worktree-Based Workspace

The system SHALL create a git worktree with a dedicated feature branch when the user invokes `/opsx:new <change-name>` and `worktree.enabled` is `true` in WORKFLOW.md. The worktree path SHALL be computed by replacing `{change}` in the `worktree.path_pattern` field with the change name (without date prefix). The system SHALL run `git worktree add <path> -b <change-name>` to create the worktree and then `mkdir -p openspec/changes/YYYY-MM-DD-<name>` inside the worktree. The system SHALL report the worktree path and branch name in its output. If the worktree path already exists as a git worktree, the system SHALL suggest switching to it instead of creating a new one.

**User Story:** As a developer I want each change to be created in its own git worktree, so that parallel changes are fully isolated and cannot conflict with each other.

#### Scenario: Create worktree when enabled

- **GIVEN** WORKFLOW.md has `worktree.enabled: true` and `worktree.path_pattern: .claude/worktrees/{change}`
- **AND** no worktree for "add-user-auth" exists
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system runs `git worktree add .claude/worktrees/add-user-auth -b add-user-auth`
- **AND** creates `openspec/changes/2026-04-01-add-user-auth/` inside the worktree
- **AND** reports the worktree path and branch name

#### Scenario: Worktree already exists

- **GIVEN** WORKFLOW.md has `worktree.enabled: true`
- **AND** a worktree at `.claude/worktrees/add-user-auth` already exists
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL NOT create a duplicate worktree
- **AND** SHALL suggest switching to the existing worktree

#### Scenario: Worktree disabled falls back to directory creation

- **GIVEN** WORKFLOW.md does not have `worktree.enabled: true` (absent or false)
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `/opsx:new add-user-auth`
- **THEN** the system SHALL create `openspec/changes/2026-04-01-add-user-auth/` in the current working tree

### Requirement: Worktree Context Detection

All change-detecting skills (`ff`, `apply`, `verify`, `discover`, `preflight`) SHALL detect the active change from worktree context before falling through to directory-based detection. The detection SHALL: (1) check if the current working directory is inside a git worktree by inspecting `git rev-parse --git-dir` for a path containing `/worktrees/`, (2) derive the change name from the current branch via `git rev-parse --abbrev-ref HEAD` (the branch name matches the change name without the date prefix), (3) search for a directory matching `openspec/changes/*-<branch-name>/` in the current working tree. If a match is found, the skill SHALL auto-select this change and announce: "Detected worktree context: using change '<name>'". If no matching directory exists, the skill SHALL fall through to normal detection logic.

**User Story:** As a developer working in a worktree I want skills to automatically know which change I'm working on, so that I don't have to specify the change name every time.

#### Scenario: Auto-detect change from worktree

- **GIVEN** the user is in a git worktree on branch `add-user-auth`
- **AND** `openspec/changes/2026-04-01-add-user-auth/` exists in the worktree
- **WHEN** any change-detecting skill is invoked without an explicit change name
- **THEN** the skill SHALL auto-select "2026-04-01-add-user-auth"
- **AND** announce "Detected worktree context: using change 'add-user-auth'"

#### Scenario: Fall through when not in worktree

- **GIVEN** the user is in the main working tree (not a worktree)
- **WHEN** any change-detecting skill is invoked without an explicit change name
- **THEN** the skill SHALL use existing directory-based detection logic

#### Scenario: Fall through when change directory missing

- **GIVEN** the user is in a git worktree on branch `some-branch`
- **AND** no directory matching `openspec/changes/*-some-branch/` exists
- **WHEN** any change-detecting skill is invoked
- **THEN** the skill SHALL fall through to normal detection logic

#### Scenario: Explicit argument overrides worktree detection

- **GIVEN** the user is in a worktree on branch `add-user-auth`
- **WHEN** a skill is invoked with explicit argument `other-change`
- **THEN** the skill SHALL use "other-change" regardless of worktree context

### Requirement: Lazy Worktree Cleanup at Change Creation

The `/opsx:new` skill SHALL check for stale worktrees before creating a new change. The system SHALL run `git worktree list` and for each worktree (excluding the main working tree), check whether the associated branch has been merged by running `gh pr view <branch-name> --json state --jq '.state'`. If the PR state is `MERGED`, the system SHALL automatically remove the worktree via `git worktree remove <path>` and delete the branch via `git branch -D <branch-name>`. If `gh` is unavailable or no PR exists, the system SHALL fall back to `git branch -d <branch-name>` (which only deletes if merged). The system SHALL report cleaned-up worktrees before proceeding with new change creation.

**User Story:** As a developer I want stale worktrees cleaned up automatically when I start a new change, so that merged branches don't accumulate on disk.

#### Scenario: Cleanup merged worktree at new change creation

- **GIVEN** a worktree exists at `.claude/worktrees/fix-auth` on branch `fix-auth`
- **AND** the PR for `fix-auth` has state "MERGED"
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system runs `git worktree remove .claude/worktrees/fix-auth`
- **AND** runs `git branch -D fix-auth`
- **AND** reports "Cleaned up stale worktree: fix-auth (merged)"
- **AND** proceeds to create the new change

#### Scenario: No stale worktrees

- **GIVEN** no worktrees exist besides the main working tree
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system proceeds directly to change creation without cleanup messages

#### Scenario: Worktree with unmerged branch preserved

- **GIVEN** a worktree exists at `.claude/worktrees/wip-feature` on branch `wip-feature`
- **AND** the PR for `wip-feature` is still open (state "OPEN")
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system SHALL NOT remove the `wip-feature` worktree
- **AND** proceeds to create the new change

#### Scenario: Cleanup without gh CLI

- **GIVEN** a worktree exists on branch `fix-auth`
- **AND** `gh` CLI is unavailable
- **WHEN** the system attempts cleanup
- **THEN** the system falls back to `git branch -d fix-auth`
- **AND** if the branch was fully merged to main, it is deleted and the worktree removed
- **AND** if the branch was NOT merged, `git branch -d` fails and the worktree is preserved

### Requirement: Active vs Completed Change Detection

Skills SHALL distinguish active from completed changes based on task completion status. A change is considered **active** if its `tasks.md` contains at least one unchecked item (`- [ ]`) or if `tasks.md` does not exist (artifacts still in progress). A change is considered **completed** if its `tasks.md` exists and all items are checked (`- [x]`). Skills that operate on active changes (apply, ff, verify, discover, preflight) SHALL filter to active changes when listing available changes. Skills that operate on completed changes (changelog, docs) SHALL filter to completed changes.

**User Story:** As a developer I want the system to automatically distinguish between active and completed changes, so that skills operate on the right set of changes without manual tagging.

#### Scenario: Active change has unchecked tasks

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with tasks.md containing 3 unchecked items
- **WHEN** `/opsx:apply` lists available changes
- **THEN** the change is shown as available for implementation

#### Scenario: Completed change has all tasks checked

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with tasks.md where all items are `- [x]`
- **WHEN** `/opsx:changelog` lists available changes
- **THEN** the change is included in changelog generation

#### Scenario: Change without tasks.md is active

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with research.md and proposal.md but no tasks.md
- **WHEN** `/opsx:ff` lists available changes
- **THEN** the change is shown as available for artifact generation

## REMOVED Requirements

### Requirement: Archive Completed Change

**Reason:** Archive is eliminated. Changes remain in their creation-date-prefixed directory under `openspec/changes/`. There is no move step. Completion is determined by task status, not by directory location.

**Migration:** Existing archived changes under `openspec/changes/archive/YYYY-MM-DD-*` are migrated to `openspec/changes/YYYY-MM-DD-*` in a one-time operation.

### Requirement: Worktree Cleanup After Archive

**Reason:** Worktree cleanup is moved to lazy detection at `/opsx:new` (see "Lazy Worktree Cleanup at Change Creation" requirement). Cleanup no longer depends on an archive step.

**Migration:** Worktree cleanup happens automatically at the next `/opsx:new` invocation.

## Edge Cases

- **Date collision**: If two changes are created on the same day with the same name (e.g., after deleting and recreating), the system SHALL detect the existing directory and suggest continuing instead.
- **Branch already exists**: If `git worktree add` fails because the branch already exists, try `git worktree add <path> <branch>` to reuse the existing branch.
- **Worktree path exists but is not a git worktree**: Fail with error — do not overwrite arbitrary directories.
- **Dirty worktree during cleanup**: `git worktree remove` fails on dirty worktrees. Report the error and skip this worktree.
- **`gh` CLI unavailable during cleanup**: Fall back to `git branch -d`. If that also fails, skip this worktree and continue.
- **Multiple changes in a worktree**: Each worktree should contain exactly one change matching the branch name. Additional `openspec/changes/` directories are ignored by worktree detection.
- **Worktree config absent**: If WORKFLOW.md has no `worktree` section, treat as `worktree.enabled: false`.
- **Legacy archive directories**: After migration, no `openspec/changes/archive/` directory should exist. If found, skills SHALL treat contents as regular completed changes.

## Assumptions

- The system clock provides the correct date for the YYYY-MM-DD prefix. <!-- ASSUMPTION: System clock accuracy -->
No further assumptions beyond those marked above.
