---
title: "Change Workspace"
capability: "change-workspace"
description: "Create and manage change workspaces with worktree isolation, proposal-based context detection, and structured change lifecycle tracking"
lastUpdated: "2026-04-09"
---

# Change Workspace

Manages the full lifecycle of a change workspace -- from creation through completion -- so that every feature or improvement follows a structured, traceable path. Supports git worktree-based isolation for parallel changes, with proposal frontmatter providing machine-readable metadata for change detection and lifecycle tracking.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent organizational pattern. When multiple changes are in-flight simultaneously, they interfere through merge conflicts on shared files. Without structured metadata in proposals, skills must rely on fragile conventions (branch name matching, tasks.md checkbox parsing) to detect which change is active, which specs are affected, and whether the change is complete.

## Rationale

Change names use kebab-case to ensure consistent, URL-safe, filesystem-safe identifiers across operating systems. Change directories use a date-prefixed naming scheme (YYYY-MM-DD-name) based on ISO 8601, so they sort chronologically in the filesystem by default. Proposal frontmatter carries structured metadata (`status`, `branch`, `worktree`, `capabilities`) that enables skills to detect the active change, filter active vs completed changes, and identify affected capabilities without parsing markdown sections or relying on naming conventions. The `branch` field enables change context detection via a simple frontmatter lookup against the current branch, with worktree convention detection as a fallback for legacy proposals. Active/completed status is tracked via the proposal's `status` field (`active`/`completed`), flipped during verify completion -- this is faster and more reliable than parsing tasks.md checkboxes. Git worktrees provide full filesystem isolation per change, and the feature is opt-in via WORKFLOW.md configuration.

## Features

- One-command workspace creation via `/opsx:new <change-name>` -- creates the workspace directory (or git worktree when enabled) and reads WORKFLOW.md to display the artifact pipeline
- **Proposal tracking frontmatter** -- proposals include `status`, `branch`, `worktree` (optional), and `capabilities` (structured new/modified/removed lists) in YAML frontmatter for machine-readable change metadata
- **Worktree-based isolation** -- when `worktree.enabled` is `true` in WORKFLOW.md, creates a git worktree with a dedicated feature branch
- Automatic name derivation -- provide a description instead of a kebab-case name and the system converts it
- Schema-driven structure -- the workspace contains exactly the artifacts defined by the pipeline, with dependency gating
- **Change context detection** -- all change-detecting skills auto-detect the active change by matching proposal `branch` frontmatter against the current branch, falling back to worktree convention and directory listing
- Date-prefixed naming -- change directories use `YYYY-MM-DD-<name>` format, set at creation time for stable, chronologically sortable names
- **Lazy worktree cleanup** -- when creating a new change, `/opsx:new` detects stale worktrees by checking proposal `status: completed` (falling back to PR merge status via `gh`)
- **Post-merge worktree cleanup** -- after a successful merge from within a worktree, the system immediately cleans up the worktree and deletes local and remote branches
- **Active vs completed detection** -- changes are distinguished by proposal `status` field (`active`/`completed`), with fallback to tasks.md checkbox parsing for legacy proposals

## Behavior

### Creating a Workspace (/opsx:new)

When you run `/opsx:new add-user-auth`, the system creates a workspace at `openspec/changes/YYYY-MM-DD-add-user-auth/` and reads WORKFLOW.md to display the artifact pipeline. If you provide a description instead of a name, the system derives a kebab-case name automatically. If the name is invalid, the system asks for a valid name. If a change with that name already exists, the system suggests continuing it instead.

### Proposal Tracking Frontmatter

When the proposal artifact is generated, it includes YAML frontmatter with `status: active`, `branch` (the git branch name), optionally `worktree` (the worktree path, when worktree mode is enabled), and `capabilities` (a structured object with `new`, `modified`, and `removed` arrays listing capability names). This frontmatter mirrors the proposal body's Capabilities section in machine-readable form, enabling skills to query affected capabilities without parsing markdown.

### Worktree-Based Workspace Creation

When `worktree.enabled` is `true` in WORKFLOW.md, `/opsx:new` creates a git worktree instead of a plain directory. The system first fetches the latest remote main branch, then creates the worktree based on the fetched remote main. This ensures the new branch starts from the latest code, preventing merge conflicts caused by a stale local main. The system creates the change directory inside the worktree and reports the path and branch name. If the worktree path already exists, the system suggests switching to it.

### Change Context Detection

All change-detecting skills auto-detect the active change using a three-tier approach: (1) scan proposal frontmatter for a `branch` field matching the current branch; (2) if no match, check if the current directory is inside a git worktree and derive the change name from the branch; (3) if not in a worktree, list active changes and prompt the user. An explicit argument always overrides auto-detection.

### Workspace Structure and Dependency Gating

The artifact pipeline sequence is determined by reading WORKFLOW.md. Only the first stage (research) is ready initially; downstream stages are blocked by unmet dependencies as determined by file existence checks.

### Lazy Worktree Cleanup at Change Creation

Before creating a new change, `/opsx:new` checks for stale worktrees. For each existing worktree, it first checks the associated proposal's `status` field -- if `completed`, the worktree is cleaned up. If no proposal status is available, it checks the PR merge status via `gh pr view`. If `gh` is unavailable, it falls back to `git branch -d` (which only deletes merged branches). Stale worktrees are removed and their branches deleted before the new change is created.

### Post-Merge Worktree Cleanup

After a successful `gh pr merge` from within a worktree, the system immediately cleans up: switches to the main worktree, removes the completed worktree, deletes the local branch, and deletes the remote branch. If the worktree has uncommitted changes and removal fails, the system reports the error and suggests manual cleanup. This complements lazy cleanup -- lazy cleanup catches merges from outside the session, post-merge cleanup handles in-session merges.

### Active vs Completed Change Detection

Changes are identified as active or completed based on their proposal's `status` frontmatter field. `status: active` (or absent) means the change is in progress. `status: completed` means the change is done (set during verify completion). For proposals without frontmatter (legacy), the system falls back to tasks.md checkbox parsing. Skills that operate on active changes (apply, ff, verify) filter to active changes; skills that operate on completed changes (changelog, docs) filter to completed changes.

## Edge Cases

- If the name is invalid (contains uppercase or special characters), the system asks for a valid kebab-case name.
- If a change with that name already exists, the system suggests continuing the existing change instead.
- If `git worktree add` fails because the branch already exists, the system tries to reuse the existing branch.
- If the worktree path exists but is not a git worktree, the system fails with an error rather than overwriting.
- If `git worktree remove` fails on a dirty worktree, the system reports the error and suggests manual cleanup.
- Each worktree should contain exactly one change matching the branch name; additional `openspec/changes/` directories are ignored by detection.
- If `gh` CLI is unavailable during lazy cleanup and no proposal status is available, cleanup falls back to `git branch -d`.
- If WORKFLOW.md has no `worktree` section, worktree mode is disabled.
- If tasks.md does not exist and no proposal status is available, the change is treated as active.
- If two change directories have proposals with the same `branch` value, skills use the most recently modified one and warn about the conflict.
- If the branch is renamed after change creation, the `branch` field becomes stale -- skills fall through to worktree convention detection.
