---
title: "Change Workspace"
capability: "change-workspace"
description: "Create, manage, and archive change workspaces with worktree isolation and date-prefixed naming"
lastUpdated: "2026-03-30"
---

# Change Workspace

Manages the full lifecycle of a change workspace -- from creation through archiving -- so that every feature or improvement follows a structured, traceable path. Supports git worktree-based isolation for parallel changes.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent archival pattern. When multiple changes are in-flight simultaneously, they interfere through merge conflicts on shared files (version bumps, ADR numbers, file moves). This capability ensures every change has a dedicated, isolated workspace with a defined structure, and completed changes are preserved chronologically for future reference.

## Rationale

Change names use kebab-case to ensure consistent, URL-safe, filesystem-safe identifiers across operating systems. Archives use a date-prefixed directory naming scheme (YYYY-MM-DD-name) based on ISO 8601, so they sort chronologically in the filesystem by default. The archive step automatically syncs delta specs to baseline before moving files, ensuring baseline specs always stay current without manual intervention. Git worktrees provide full filesystem isolation per change -- each worktree has its own working directory and branch, eliminating cross-change interference from structural modifications on main. Worktree context detection uses `git rev-parse --git-dir` (a reliable built-in git mechanism) to auto-detect which change is active, with the change name derived directly from the branch name (1:1 mapping established by `/opsx:new`). The feature is opt-in via WORKFLOW.md configuration, so existing projects continue working without modification.

## Features

- One-command workspace creation via `/opsx:new <change-name>` -- creates the workspace directory (or git worktree when enabled) and reads WORKFLOW.md to display the artifact pipeline
- **Worktree-based isolation** -- when `worktree.enabled` is `true` in WORKFLOW.md, creates a git worktree with a dedicated feature branch at the configured path (default: `.claude/worktrees/{change}`)
- Automatic name derivation -- provide a description instead of a kebab-case name and the system converts it
- Schema-driven structure -- the workspace contains exactly the artifacts defined by the pipeline, with dependency gating
- **Worktree context detection** -- all 7 change-detecting skills (`ff`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`) auto-detect the active change from worktree branch context before falling through to directory-based detection
- Date-prefixed archiving via `/opsx:archive` -- moves completed changes to a chronologically sorted archive
- **Worktree cleanup after archive** -- offers automatic or manual worktree removal based on `worktree.auto_cleanup` configuration
- Automatic spec sync before archive -- unsynced delta specs are automatically applied to baseline specs during archiving, with validation that all synced specs exist before proceeding
- Warnings for incomplete artifacts or tasks before archiving

## Behavior

### Creating a Workspace (/opsx:new)

When you run `/opsx:new add-user-auth`, the system creates a workspace at `openspec/changes/add-user-auth/` and reads WORKFLOW.md to determine the artifact pipeline, displaying the artifact status and first artifact template. If you provide a description like "add user authentication" instead of a name, the system derives `add-user-auth` automatically. If the name is invalid (contains uppercase or special characters), the system asks for a valid kebab-case name. If a change with that name already exists, the system suggests continuing the existing change instead.

### Worktree-Based Workspace Creation

When `worktree.enabled` is `true` in WORKFLOW.md, `/opsx:new` creates a git worktree instead of a plain directory. The system runs `git worktree add <path> -b <change-name>` where the path is computed from `worktree.path_pattern` (replacing `{change}` with the change name), then creates `openspec/changes/<name>/` inside the worktree. The output reports the worktree path and branch name. If the worktree path already exists, the system suggests switching to it. If `worktree.enabled` is `false` or absent, workspace creation falls back to plain `mkdir -p`.

### Worktree Context Detection

All change-detecting skills auto-detect the active change from worktree context before falling through to directory-based detection. The detection checks whether the current working directory is inside a git worktree (via `git rev-parse --git-dir`), derives the change name from the current branch, and verifies that `openspec/changes/<branch-name>/` exists. If all checks pass, the skill auto-selects the change and announces it. If any check fails, the skill falls through to normal detection logic. An explicit argument always overrides worktree detection.

### Workspace Structure and Dependency Gating

The created workspace is a directory at `openspec/changes/<name>/`. The artifact pipeline sequence is determined by reading WORKFLOW.md -- the stages are: research, proposal, specs, design, preflight, and tasks. Only the first stage (research) is ready initially; downstream stages are blocked by unmet dependencies as determined by file existence checks.

### Archiving a Completed Change (/opsx:archive)

When you run `/opsx:archive`, the system moves the workspace to the archive directory with a date prefix (e.g., `2026-03-02-add-user-auth/`). Before archiving:

- If unsynced delta specs exist, the system automatically syncs them to baseline, validates that all delta spec capabilities have corresponding baseline specs, and displays a summary of applied changes. If any baseline specs are missing after sync, the archive is blocked and the missing capabilities are reported.
- If artifacts or tasks are incomplete, the system displays a warning with details and asks you to confirm.
- If the archive target directory already exists, the system fails with an error and suggests a resolution.

### Worktree Cleanup After Archive

When archiving from a worktree, the system offers cleanup based on the `worktree.auto_cleanup` setting. If `auto_cleanup` is `true`, the system navigates to the main repository, removes the worktree, and deletes the branch. To handle all merge strategies (including squash merges), the system checks the PR merge status via GitHub before deleting the branch. If the PR is confirmed merged, force delete is used; otherwise, the system falls back to standard branch deletion. If `auto_cleanup` is `false` or absent, the system provides manual cleanup instructions. When not in a worktree, no cleanup is mentioned.

### Archiving with Incomplete Tasks

When tasks are partially complete (e.g., 3 of 7 checkboxes marked), the system displays the exact count and asks for confirmation before proceeding.

## Edge Cases

- If no active changes exist when archiving, the system informs you and suggests creating a new change.
- If multiple active changes exist and you do not specify which to archive, the system lists them and asks you to select one.
- An empty workspace (no artifacts created) can still be archived if you confirm the warning.
- If the move operation fails mid-way (e.g., disk full), the workspace remains in its original location and the error is reported.
- The archive directory is created automatically if it does not yet exist.
- If `git worktree add` fails because the branch already exists, the system tries to reuse the existing branch.
- If the worktree path exists but is not a git worktree, the system fails with an error rather than overwriting.
- If `git worktree remove` fails on a dirty worktree, the system reports the error and suggests `--force` or committing changes first.
- Each worktree should contain exactly one change matching the branch name; additional `openspec/changes/` directories are ignored by worktree detection.
- If `gh` CLI is unavailable during branch deletion and the PR was squash-merged, the standard deletion fails. The system reports the error and suggests manual force deletion.
- If WORKFLOW.md has no `worktree` section, worktree mode is disabled.
- If delta specs exist but are already in sync with baseline, the auto-sync is a no-op and archiving proceeds normally.
- If a baseline spec already existed before sync (e.g., a MODIFIED delta), the validation check still passes -- the existence check confirms sync didn't fail to create new specs, not that it modified existing ones correctly.
- If the sync operation fails during archive, the system reports the error and stops -- it does not proceed to archive with unsynced specs.
