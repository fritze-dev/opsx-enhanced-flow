---
order: 3
category: change-workflow
status: stable
version: 3
lastModified: 2026-04-11
---
## Purpose

Manages the change lifecycle including workspace creation (now part of `workflow propose`), date-prefixed workspace structure, worktree isolation, worktree context detection (now handled by the router), lazy worktree cleanup, and active/completed change detection based on task status.

## Requirements

### Requirement: Create Change Workspace

The system SHALL create a change workspace when the user invokes `workflow propose <change-name>`. The workspace directory SHALL use a creation-date prefix in the format `YYYY-MM-DD-<change-name>`, set at creation time and never changed. If `worktree.enabled` is `true` in WORKFLOW.md, the system SHALL create a git worktree (see "Create Worktree-Based Workspace" requirement) and then create the change directory inside it via `mkdir -p <worktree>/openspec/changes/YYYY-MM-DD-<name>`. If worktree mode is not enabled, the workspace SHALL be created by running `mkdir -p openspec/changes/YYYY-MM-DD-<name>`. The change name MUST be in kebab-case format. If the user provides a description instead of a name, the system SHALL derive a kebab-case name from the description. The system SHALL NOT proceed without a valid change name.

When the proposal artifact (`proposal.md`) is created for a change, the propose action SHALL include YAML frontmatter with tracking fields:
- `status: active` — change lifecycle (flipped to `completed` during verify completion)
- `branch: <branch-name>` — git branch association
- `worktree: <worktree-path>` — only when worktree mode is enabled
- `capabilities` — structured list of affected capabilities:
  ```yaml
  capabilities:
    new: [capability-one]
    modified: [quality-gates, spec-format]
    removed: []
  ```
  This machine-readable field mirrors the Capabilities section in the proposal body and eliminates the need for skills to parse markdown sections.

These fields enable automated change context detection, active/completed filtering, worktree association, and capability lookup without relying on naming conventions or markdown parsing.

**User Story:** As a developer I want to create a new change workspace with a date-prefixed directory, so that changes are chronologically ordered from creation and I can immediately begin the spec-driven workflow.

#### Scenario: Create workspace with date prefix

- **GIVEN** no change named "add-user-auth" exists
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `workflow propose add-user-auth`
- **THEN** the system creates the workspace at `openspec/changes/2026-04-01-add-user-auth/`
- **AND** reads WORKFLOW.md to determine the artifact pipeline and displays the artifact status

#### Scenario: Derive name from description

- **WHEN** the user invokes `workflow propose` and provides the description "add user authentication"
- **AND** today's date is 2026-04-01
- **THEN** the system derives the kebab-case name `add-user-auth`
- **AND** creates the workspace at `openspec/changes/2026-04-01-add-user-auth/`

#### Scenario: Proposal created with tracking frontmatter

- **GIVEN** a new change `add-user-auth` created on branch `add-user-auth` in worktree `.claude/worktrees/add-user-auth`
- **AND** the proposal lists `user-auth` as a new capability and `quality-gates` as modified
- **WHEN** the proposal artifact is generated
- **THEN** `proposal.md` SHALL include YAML frontmatter with `status: active`, `branch: add-user-auth`, `worktree: .claude/worktrees/add-user-auth`, and `capabilities: { new: [user-auth], modified: [quality-gates], removed: [] }`

#### Scenario: Proposal frontmatter without worktree

- **GIVEN** a new change created without worktree mode (`worktree.enabled: false`)
- **WHEN** the proposal artifact is generated
- **THEN** `proposal.md` SHALL include YAML frontmatter with `status: active`, `branch: <branch-name>`, and `capabilities`
- **AND** the `worktree` field SHALL be absent

#### Scenario: Reject invalid name format

- **GIVEN** the user provides a name containing uppercase letters or special characters (e.g., "Add_User Auth")
- **WHEN** the system attempts to create the workspace
- **THEN** the system SHALL ask the user for a valid kebab-case name
- **AND** SHALL NOT create the workspace until a valid name is provided

#### Scenario: Change name already exists

- **GIVEN** a change directory matching `*-add-user-auth` already exists under `openspec/changes/`
- **WHEN** the user invokes `workflow propose add-user-auth`
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

The system SHALL create a git worktree with a dedicated feature branch when the user invokes `workflow propose <change-name>` and `worktree.enabled` is `true` in WORKFLOW.md. The worktree path SHALL be computed by replacing `{change}` in the `worktree.path_pattern` field with the change name (without date prefix). Before creating the worktree, the system SHALL fetch the latest remote main branch. The system SHALL use the fetched remote main as the start-point for the new branch. The system SHALL then run `mkdir -p openspec/changes/YYYY-MM-DD-<name>` inside the worktree. The system SHALL report the worktree path and branch name in its output. If the worktree path already exists as a git worktree, the system SHALL suggest switching to it instead of creating a new one.

**User Story:** As a developer I want each change to be created in its own git worktree, so that parallel changes are fully isolated and cannot conflict with each other.

#### Scenario: Create worktree when enabled

- **GIVEN** WORKFLOW.md has `worktree.enabled: true` and `worktree.path_pattern: .claude/worktrees/{change}`
- **AND** no worktree for "add-user-auth" exists
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `workflow propose add-user-auth`
- **THEN** the system fetches the latest remote main branch
- **AND** creates a worktree based on the fetched remote main
- **AND** creates `openspec/changes/2026-04-01-add-user-auth/` inside the worktree
- **AND** reports the worktree path and branch name

#### Scenario: Worktree already exists

- **GIVEN** WORKFLOW.md has `worktree.enabled: true`
- **AND** a worktree at `.claude/worktrees/add-user-auth` already exists
- **WHEN** the user invokes `workflow propose add-user-auth`
- **THEN** the system SHALL NOT create a duplicate worktree
- **AND** SHALL suggest switching to the existing worktree

#### Scenario: Worktree disabled falls back to directory creation

- **GIVEN** WORKFLOW.md does not have `worktree.enabled: true` (absent or false)
- **AND** today's date is 2026-04-01
- **WHEN** the user invokes `workflow propose add-user-auth`
- **THEN** the system SHALL create `openspec/changes/2026-04-01-add-user-auth/` in the current working tree

### Requirement: Change Context Detection

The router SHALL detect the active change using proposal frontmatter before falling through to legacy detection, and pass the resolved context to the dispatched action. The detection sequence SHALL be:

1. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose `branch` field matches the current branch (`git rev-parse --abbrev-ref HEAD`). If found, auto-select that change.
2. **Fallback — worktree convention**: If no proposal has a matching `branch` field, check if the current working directory is inside a git worktree (inspect `git rev-parse --git-dir` for `/worktrees/`), derive the change name from the branch, and search for `openspec/changes/*-<branch-name>/`.
3. **Fallback — directory listing**: If not in a worktree, list active changes and prompt the user.

If a match is found, the router SHALL auto-select the change and announce: "Detected change context: using change '<name>'". An explicit argument always overrides auto-detection.

**User Story:** As a developer I want the router to automatically know which change I'm working on using structured metadata, so that detection is reliable regardless of naming conventions.

#### Scenario: Auto-detect change via proposal branch field

- **GIVEN** the user is on branch `add-user-auth`
- **AND** `openspec/changes/2026-04-01-add-user-auth/proposal.md` has frontmatter `branch: add-user-auth`
- **WHEN** any command is invoked via the router without an explicit change name
- **THEN** the router SHALL auto-select "2026-04-01-add-user-auth"
- **AND** announce "Detected change context: using change 'add-user-auth'"

#### Scenario: Fallback to worktree convention when proposal has no branch field

- **GIVEN** the user is in a git worktree on branch `legacy-change`
- **AND** `openspec/changes/2026-03-01-legacy-change/proposal.md` has no YAML frontmatter
- **WHEN** any command is invoked via the router
- **THEN** the router SHALL fall back to worktree convention detection (branch name → directory glob)

#### Scenario: Fall through to directory listing when not in worktree

- **GIVEN** the user is in the main working tree (not a worktree)
- **AND** no proposal has a `branch` field matching the current branch
- **WHEN** any command is invoked via the router without an explicit change name
- **THEN** the router SHALL list active changes and prompt the user

#### Scenario: Explicit argument overrides auto-detection

- **GIVEN** the user is on branch `add-user-auth`
- **WHEN** a skill is invoked with explicit argument `other-change`
- **THEN** the router SHALL use "other-change" regardless of proposal frontmatter or worktree context

### Requirement: Lazy Worktree Cleanup at Change Creation

The `workflow propose` skill SHALL check for stale worktrees before creating a new change. The system SHALL run `git worktree list` and for each worktree (excluding the main working tree), determine if the associated change is completed or abandoned:

1. **Proposal status check**: Read `<worktree-path>/openspec/changes/*/proposal.md` (using the worktree's filesystem path from `git worktree list`). If the proposal has `status: completed`, the change is done — auto-clean.
2. **Fallback — PR status (MERGED)**: If no proposal status is available or not `completed`, check the PR state for the branch using available GitHub tooling. If `MERGED`, the change is done — auto-clean.
3. **Fallback — PR status (CLOSED)**: If the PR state is `CLOSED`, the change is abandoned. Prompt the user for confirmation before cleanup, displaying the branch name and PR URL. This prompt SHALL NOT be suppressed by `auto_approve`.
4. **Fallback — inactivity**: If no PR exists (or no GitHub tooling is available), check the last commit date on the branch via `git log -1 --format=%ci <branch-name>`. If older than `worktree.stale_days` (default: 14), prompt the user for confirmation before cleanup.
5. **Fallback — git branch**: If none of the above apply, try `git branch -d <branch-name>` (only deletes if merged).

For completed changes (tiers 1–2), the system SHALL auto-remove the worktree without prompting. For abandoned or stale changes (tiers 3–4), the system SHALL prompt the user before removal. The cleanup sequence SHALL be: `git worktree remove <path>`, `git branch -D <branch-name>`, delete the remote branch. The system SHALL report cleaned-up worktrees before proceeding.

**User Story:** As a developer I want stale worktrees cleaned up automatically when I start a new change, so that completed, abandoned, and inactive branches don't accumulate on disk.

#### Scenario: Cleanup worktree with completed proposal status

- **GIVEN** a worktree exists at `.claude/worktrees/feature-x` on branch `worktree-feature-x`
- **AND** `<worktree-path>/openspec/changes/2026-04-10-feature-x/proposal.md` has `status: completed`
- **WHEN** the user invokes `workflow propose add-logging`
- **THEN** the system reads the proposal from the worktree filesystem path
- **AND** removes the worktree and deletes the branch
- **AND** reports "Cleaned up stale worktree: feature-x (completed)"

#### Scenario: Cleanup worktree via PR status fallback

- **GIVEN** a worktree on branch `fix-auth` with no proposal `status` field
- **AND** the PR for `fix-auth` has state "MERGED"
- **WHEN** the user invokes `workflow propose add-logging`
- **THEN** the system removes the worktree and deletes the branch

#### Scenario: Abandoned worktree detected via closed PR

- **GIVEN** a worktree on branch `worktree-abandoned-feature` with `status: active`
- **AND** the PR for `worktree-abandoned-feature` has state `CLOSED`
- **WHEN** the user invokes `workflow propose new-change`
- **THEN** the system prompts: "Worktree 'abandoned-feature' has a closed PR (not merged). Clean up? [y/N]"
- **AND** if the user confirms, the system removes the worktree and deletes the branch
- **AND** if the user declines, the worktree is preserved

#### Scenario: Inactive worktree detected via commit age

- **GIVEN** a worktree on branch `worktree-old-experiment` with `status: active`
- **AND** no PR exists for `worktree-old-experiment`
- **AND** the last commit on the branch is 21 days old
- **AND** `worktree.stale_days` is 14
- **WHEN** the user invokes `workflow propose new-change`
- **THEN** the system prompts: "Worktree 'old-experiment' has had no commits for 21 days. Clean up? [y/N]"
- **AND** if the user confirms, the system removes the worktree and deletes the branch
- **AND** if the user declines, the worktree is preserved

#### Scenario: Recent worktree within inactivity threshold preserved

- **GIVEN** a worktree on branch `worktree-recent-work` with `status: active`
- **AND** no PR exists, and the last commit is 5 days old
- **AND** `worktree.stale_days` is 14
- **WHEN** the user invokes `workflow propose new-change`
- **THEN** the system SHALL NOT prompt for cleanup of `recent-work`

#### Scenario: No stale worktrees

- **GIVEN** no worktrees exist besides the main working tree
- **WHEN** the user invokes `workflow propose add-logging`
- **THEN** the system proceeds directly to change creation without cleanup messages

#### Scenario: Worktree with active change preserved

- **GIVEN** a worktree exists at `.claude/worktrees/wip-feature` on branch `wip-feature`
- **AND** the proposal has `status: active`
- **AND** the last commit is within the `stale_days` threshold
- **WHEN** the user invokes `workflow propose add-logging`
- **THEN** the system SHALL NOT remove the `wip-feature` worktree

#### Scenario: Cleanup without GitHub tooling and no proposal status

- **GIVEN** a worktree exists on branch `fix-auth`
- **AND** proposal has no `status` field and no GitHub tooling is available
- **AND** the last commit is within the `stale_days` threshold
- **WHEN** the system attempts cleanup
- **THEN** the system falls back to `git branch -d fix-auth`
- **AND** if the branch was fully merged to main, it is deleted and the worktree removed
- **AND** if the branch was NOT merged, `git branch -d` fails and the worktree is preserved

### Requirement: Post-Merge Worktree Cleanup

When a PR is merged from within a worktree (via any merge method), the system SHALL perform immediate cleanup of the completed worktree. The cleanup sequence SHALL be: (1) switch working directory to the main worktree, (2) remove the completed worktree, (3) delete the local branch, (4) delete the remote branch. The system SHALL detect that it is inside a worktree by checking `git rev-parse --git-dir` for a path containing `/worktrees/`. This immediate cleanup complements lazy cleanup at `workflow propose` — lazy cleanup catches worktrees from merges that happened outside the agent session, while immediate cleanup handles in-session merges.

**User Story:** As a developer I want the worktree cleaned up immediately after my PR is merged, so that I don't have stale worktrees lingering until the next `workflow propose`.

#### Scenario: Cleanup after successful local merge

- **GIVEN** the agent is working inside a worktree at `.claude/worktrees/fix-auth` on branch `fix-auth`
- **AND** the agent merges the PR which succeeds
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

The router SHALL distinguish active from completed changes using the proposal's `status` frontmatter field. A change is considered **active** if its `proposal.md` has `status: active` or has no `status` field (legacy/early pipeline). A change is considered **completed** if its `proposal.md` has `status: completed`. The `status` field is set to `active` at change creation and flipped to `completed` during verify completion (same step that flips spec `draft → stable`).

**Fallback** (for proposals without frontmatter): A change is active if its `tasks.md` contains at least one unchecked item (`- [ ]`) or if `tasks.md` does not exist. A change is completed if its `tasks.md` exists and all items are checked (`- [x]`).

Actions that operate on active changes (propose, apply) SHALL filter to active changes. Actions that operate on completed changes (finalize) SHALL filter to completed changes.

**User Story:** As a developer I want the system to distinguish active from completed changes using structured metadata, so that detection is instant and does not require parsing task checkboxes.

#### Scenario: Active change detected via proposal status

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with `proposal.md` containing `status: active`
- **WHEN** `workflow apply` lists available changes
- **THEN** the change is shown as available for implementation

#### Scenario: Completed change detected via proposal status

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with `proposal.md` containing `status: completed`
- **WHEN** `workflow finalize` lists available changes
- **THEN** the change is included in changelog generation

#### Scenario: Change without proposal frontmatter falls back to tasks.md

- **GIVEN** a change at `openspec/changes/2026-03-01-legacy/` with `proposal.md` without YAML frontmatter
- **AND** `tasks.md` contains unchecked items
- **WHEN** `workflow apply` lists available changes
- **THEN** the change is shown as active (fallback to tasks.md parsing)

#### Scenario: Change without tasks.md is active

- **GIVEN** a change at `openspec/changes/2026-04-01-add-auth/` with research.md and proposal.md (`status: active`) but no tasks.md
- **WHEN** `workflow propose` lists available changes
- **THEN** the change is shown as available for artifact generation

## Edge Cases

- **Date collision**: If two changes are created on the same day with the same name (e.g., after deleting and recreating), the system SHALL detect the existing directory and suggest continuing instead.
- **Branch already exists**: If `git worktree add` fails because the branch already exists, try `git worktree add <path> <branch>` to reuse the existing branch.
- **Worktree path exists but is not a git worktree**: Fail with error — do not overwrite arbitrary directories.
- **Dirty worktree during cleanup**: `git worktree remove` fails on dirty worktrees. Report the error and skip this worktree.
- **GitHub tooling unavailable during cleanup**: Fall back to inactivity check, then `git branch -d`. If all fail, skip this worktree and continue.
- **PR state `CLOSED` during cleanup**: A `CLOSED` PR indicates the change was abandoned (not merged). The system SHALL prompt the user rather than auto-cleaning, since the branch may contain salvageable work.
- **`worktree.stale_days` absent**: If WORKFLOW.md has no `stale_days` field, default to 14 days.
- **Branch with no commits**: If `git log -1` fails (branch has no commits), treat the worktree as active (do not flag for cleanup).
- **Multiple changes in a worktree**: Each worktree should contain exactly one change matching the branch name. Additional `openspec/changes/` directories are ignored by worktree detection.
- **Worktree config absent**: If WORKFLOW.md has no `worktree` section, treat as `worktree.enabled: false`.
- **Proposal without frontmatter (legacy)**: The router SHALL fall back to tasks.md-based detection for active/completed status and branch-name convention for worktree context.
- **Multiple proposals match same branch**: If two change directories have proposals with the same `branch` value, skills SHALL use the most recently modified one and warn about the conflict.
- **Branch renamed after change creation**: The `branch` field in proposal.md reflects the branch at creation time. If the branch is renamed, the field becomes stale — skills fall through to worktree convention detection.

## Assumptions

- The system clock provides the correct date for the YYYY-MM-DD prefix. <!-- ASSUMPTION: System clock accuracy -->
No further assumptions beyond those marked above.
