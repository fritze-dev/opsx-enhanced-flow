---
order: 3
category: change-workflow
---
## Purpose

Manages the change lifecycle including workspace creation (`/opsx:new`), date-prefixed workspace structure, worktree isolation, worktree context detection, lazy worktree cleanup, and active/completed change detection based on task status.

## Requirements

### Requirement: Create Change Workspace

The system SHALL create a change workspace when the user invokes `/opsx:new <change-name>`. The workspace directory SHALL use a creation-date prefix in the format `YYYY-MM-DD-<change-name>`, set at creation time and never changed. If `worktree.enabled` is `true` in WORKFLOW.md, the system SHALL create a git worktree (see "Create Worktree-Based Workspace" requirement) and then create the change directory inside it via `mkdir -p <worktree>/openspec/changes/YYYY-MM-DD-<name>`. If worktree mode is not enabled, the workspace SHALL be created by running `mkdir -p openspec/changes/YYYY-MM-DD-<name>`. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

When the first artifact (`proposal.md`) is created for a change, the skills SHALL include YAML frontmatter with tracking fields: `status: active`, `branch: <branch-name>`, and optionally `worktree: <worktree-path>` (only when worktree mode is enabled). These fields enable automated change context detection, active/completed filtering, and worktree association without relying on naming conventions.

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

#### Scenario: Proposal created with tracking frontmatter

- **GIVEN** a new change `add-user-auth` created on branch `add-user-auth` in worktree `.claude/worktrees/add-user-auth`
- **WHEN** the proposal artifact is generated
- **THEN** `proposal.md` SHALL include YAML frontmatter with `status: active`, `branch: add-user-auth`, and `worktree: .claude/worktrees/add-user-auth`

#### Scenario: Proposal frontmatter without worktree

- **GIVEN** a new change created without worktree mode (`worktree.enabled: false`)
- **WHEN** the proposal artifact is generated
- **THEN** `proposal.md` SHALL include YAML frontmatter with `status: active` and `branch: <branch-name>`
- **AND** the `worktree` field SHALL be absent

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

### Requirement: Change Context Detection

All change-detecting skills (`ff`, `apply`, `verify`, `discover`, `preflight`) SHALL detect the active change using proposal frontmatter before falling through to legacy detection. The detection sequence SHALL be:

1. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose `branch` field matches the current branch (`git rev-parse --abbrev-ref HEAD`). If found, auto-select that change.
2. **Fallback — worktree convention**: If no proposal has a matching `branch` field, check if the current working directory is inside a git worktree (inspect `git rev-parse --git-dir` for `/worktrees/`), derive the change name from the branch, and search for `openspec/changes/*-<branch-name>/`.
3. **Fallback — directory listing**: If not in a worktree, list active changes and prompt the user.

If a match is found, the skill SHALL auto-select the change and announce: "Detected change context: using change '<name>'". An explicit argument always overrides auto-detection.

**User Story:** As a developer I want skills to automatically know which change I'm working on using structured metadata, so that detection is reliable regardless of naming conventions.

#### Scenario: Auto-detect change via proposal branch field

- **GIVEN** the user is on branch `add-user-auth`
- **AND** `openspec/changes/2026-04-01-add-user-auth/proposal.md` has frontmatter `branch: add-user-auth`
- **WHEN** any change-detecting skill is invoked without an explicit change name
- **THEN** the skill SHALL auto-select "2026-04-01-add-user-auth"
- **AND** announce "Detected change context: using change 'add-user-auth'"

#### Scenario: Fallback to worktree convention when proposal has no branch field

- **GIVEN** the user is in a git worktree on branch `legacy-change`
- **AND** `openspec/changes/2026-03-01-legacy-change/proposal.md` has no YAML frontmatter
- **WHEN** any change-detecting skill is invoked
- **THEN** the skill SHALL fall back to worktree convention detection (branch name → directory glob)

#### Scenario: Fall through to directory listing when not in worktree

- **GIVEN** the user is in the main working tree (not a worktree)
- **AND** no proposal has a `branch` field matching the current branch
- **WHEN** any change-detecting skill is invoked without an explicit change name
- **THEN** the skill SHALL list active changes and prompt the user

#### Scenario: Explicit argument overrides auto-detection

- **GIVEN** the user is on branch `add-user-auth`
- **WHEN** a skill is invoked with explicit argument `other-change`
- **THEN** the skill SHALL use "other-change" regardless of proposal frontmatter or worktree context

### Requirement: Lazy Worktree Cleanup at Change Creation

The `/opsx:new` skill SHALL check for stale worktrees before creating a new change. The system SHALL run `git worktree list` and for each worktree (excluding the main working tree), determine if the associated change is completed:

1. **Proposal status check**: Find the change directory in the worktree matching the branch name (`openspec/changes/*-<branch>/proposal.md`). If the proposal has `status: completed`, the change is done.
2. **Fallback — PR status**: If no proposal status is available, run `gh pr view <branch-name> --json state --jq '.state'`. If `MERGED`, the change is done.
3. **Fallback — git branch**: If `gh` is unavailable, try `git branch -d <branch-name>` (only deletes if merged).

For completed changes, the system SHALL remove the worktree via `git worktree remove <path>`, delete the local branch via `git branch -D <branch-name>`, and delete the remote branch. The system SHALL report cleaned-up worktrees before proceeding.

**User Story:** As a developer I want stale worktrees cleaned up automatically when I start a new change, so that merged branches don't accumulate on disk.

#### Scenario: Cleanup worktree with completed proposal status

- **GIVEN** a worktree exists at `.claude/worktrees/fix-auth` on branch `fix-auth`
- **AND** `openspec/changes/2026-04-01-fix-auth/proposal.md` in the main tree has `status: completed`
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system removes the worktree and deletes the branch
- **AND** reports "Cleaned up stale worktree: fix-auth (completed)"

#### Scenario: Cleanup worktree via PR status fallback

- **GIVEN** a worktree on branch `fix-auth` with no proposal `status` field
- **AND** the PR for `fix-auth` has state "MERGED"
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system removes the worktree and deletes the branch

#### Scenario: No stale worktrees

- **GIVEN** no worktrees exist besides the main working tree
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system proceeds directly to change creation without cleanup messages

#### Scenario: Worktree with active change preserved

- **GIVEN** a worktree exists at `.claude/worktrees/wip-feature` on branch `wip-feature`
- **AND** the proposal has `status: active`
- **WHEN** the user invokes `/opsx:new add-logging`
- **THEN** the system SHALL NOT remove the `wip-feature` worktree

#### Scenario: Cleanup without gh CLI and no proposal status

- **GIVEN** a worktree exists on branch `fix-auth`
- **AND** proposal has no `status` field and `gh` CLI is unavailable
- **WHEN** the system attempts cleanup
- **THEN** the system falls back to `git branch -d fix-auth`
- **AND** if the branch was fully merged to main, it is deleted and the worktree removed
- **AND** if the branch was NOT merged, `git branch -d` fails and the worktree is preserved

### Requirement: Post-Merge Worktree Cleanup

When a PR is merged from within a worktree (via `gh pr merge` or equivalent), the system SHALL perform immediate cleanup of the completed worktree. The cleanup sequence SHALL be: (1) switch working directory to the main worktree, (2) remove the completed worktree, (3) delete the local branch, (4) delete the remote branch. The system SHALL detect that it is inside a worktree by checking `git rev-parse --git-dir` for a path containing `/worktrees/`. This immediate cleanup complements lazy cleanup at `/opsx:new` — lazy cleanup catches worktrees from merges that happened outside the agent session, while immediate cleanup handles in-session merges.

**User Story:** As a developer I want the worktree cleaned up immediately after my PR is merged, so that I don't have stale worktrees lingering until the next `/opsx:new`.

#### Scenario: Cleanup after successful local merge

- **GIVEN** the agent is working inside a worktree at `.claude/worktrees/fix-auth` on branch `fix-auth`
- **AND** the agent runs `gh pr merge` which succeeds
- **WHEN** the merge completes
- **THEN** the system SHALL switch the working directory to the main worktree
- **AND** remove the worktree
- **AND** delete the local branch
- **AND** delete the remote branch
- **AND** report "Cleaned up worktree: fix-auth (merged)"

#### Scenario: Cleanup skipped when not in worktree

- **GIVEN** the agent is working in the main working tree (not a worktree)
- **WHEN** a merge completes
- **THEN** the system SHALL NOT attempt worktree cleanup

#### Scenario: Worktree removal fails due to dirty state

- **GIVEN** the agent is inside a worktree and a merge completes
- **AND** the worktree has uncommitted changes
- **WHEN** `git worktree remove` fails
- **THEN** the system SHALL report the failure and suggest manual cleanup
- **AND** SHALL NOT block the workflow

### Requirement: Active vs Completed Change Detection

Skills SHALL distinguish active from completed changes using the proposal's `status` frontmatter field. A change is considered **active** if its `proposal.md` has `status: active` or has no `status` field (legacy/early pipeline). A change is considered **completed** if its `proposal.md` has `status: completed`. The `status` field is set to `active` at change creation and flipped to `completed` during verify completion (same step that flips spec `draft → stable`).

**Fallback** (for proposals without frontmatter): A change is active if its `tasks.md` contains at least one unchecked item (`- [ ]`) or if `tasks.md` does not exist. A change is completed if its `tasks.md` exists and all items are checked (`- [x]`).

Skills that operate on active changes (apply, ff, verify, discover, preflight) SHALL filter to active changes. Skills that operate on completed changes (changelog, docs) SHALL filter to completed changes.

**User Story:** As a developer I want the system to distinguish active from completed changes using structured metadata, so that detection is instant and does not require parsing task checkboxes.

#### Scenario: Active change detected via proposal status

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with `proposal.md` containing `status: active`
- **WHEN** `/opsx:apply` lists available changes
- **THEN** the change is shown as available for implementation

#### Scenario: Completed change detected via proposal status

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with `proposal.md` containing `status: completed`
- **WHEN** `/opsx:changelog` lists available changes
- **THEN** the change is included in changelog generation

#### Scenario: Change without proposal frontmatter falls back to tasks.md

- **GIVEN** a change at `openspec/changes/2026-03-01-legacy/` with `proposal.md` without YAML frontmatter
- **AND** `tasks.md` contains unchecked items
- **WHEN** `/opsx:apply` lists available changes
- **THEN** the change is shown as active (fallback to tasks.md parsing)

#### Scenario: Change without tasks.md is active

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with research.md and proposal.md (`status: active`) but no tasks.md
- **WHEN** `/opsx:ff` lists available changes
- **THEN** the change is shown as available for artifact generation

## Edge Cases

- **Date collision**: If two changes are created on the same day with the same name (e.g., after deleting and recreating), the system SHALL detect the existing directory and suggest continuing instead.
- **Branch already exists**: If `git worktree add` fails because the branch already exists, try `git worktree add <path> <branch>` to reuse the existing branch.
- **Worktree path exists but is not a git worktree**: Fail with error — do not overwrite arbitrary directories.
- **Dirty worktree during cleanup**: `git worktree remove` fails on dirty worktrees. Report the error and skip this worktree.
- **`gh` CLI unavailable during cleanup**: Fall back to `git branch -d`. If that also fails, skip this worktree and continue.
- **Multiple changes in a worktree**: Each worktree should contain exactly one change matching the branch name. Additional `openspec/changes/` directories are ignored by worktree detection.
- **Worktree config absent**: If WORKFLOW.md has no `worktree` section, treat as `worktree.enabled: false`.
- **Proposal without frontmatter (legacy)**: Skills SHALL fall back to tasks.md-based detection for active/completed status and branch-name convention for worktree context.
- **Multiple proposals match same branch**: If two change directories have proposals with the same `branch` value, skills SHALL use the most recently modified one and warn about the conflict.
- **Branch renamed after change creation**: The `branch` field in proposal.md reflects the branch at creation time. If the branch is renamed, the field becomes stale — skills fall through to worktree convention detection.

## Assumptions

- The system clock provides the correct date for the YYYY-MM-DD prefix. <!-- ASSUMPTION: System clock accuracy -->
No further assumptions beyond those marked above.
