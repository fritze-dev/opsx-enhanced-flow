---
title: "Change Workspace"
capability: "change-workspace"
description: "Create and manage change workspaces with worktree isolation and date-prefixed naming"
lastUpdated: "2026-04-08"
---

# Change Workspace

Manages the full lifecycle of a change workspace -- from creation through completion -- so that every feature or improvement follows a structured, traceable path. Supports git worktree-based isolation for parallel changes.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent organizational pattern. When multiple changes are in-flight simultaneously, they interfere through merge conflicts on shared files (version bumps, ADR numbers, file moves). This capability ensures every change has a dedicated, isolated workspace with a defined structure, and completed changes are preserved chronologically for future reference.

## Rationale

Change names use kebab-case to ensure consistent, URL-safe, filesystem-safe identifiers across operating systems. Change directories use a date-prefixed naming scheme (YYYY-MM-DD-name) based on ISO 8601, so they sort chronologically in the filesystem by default. Completed changes are identified by their tasks.md status (all checkboxes marked complete) rather than by moving files to a separate directory, keeping the filesystem structure flat and simple. Git worktrees provide full filesystem isolation per change -- each worktree has its own working directory and branch, eliminating cross-change interference from structural modifications on main. Worktree context detection uses `git rev-parse --git-dir` (a reliable built-in git mechanism) to auto-detect which change is active, with the change name derived directly from the branch name (1:1 mapping established by `/opsx:new`). The feature is opt-in via WORKFLOW.md configuration, so existing projects continue working without modification.

## Features

- One-command workspace creation via `/opsx:new <change-name>` -- creates the workspace directory (or git worktree when enabled) and reads WORKFLOW.md to display the artifact pipeline
- **Worktree-based isolation** -- when `worktree.enabled` is `true` in WORKFLOW.md, creates a git worktree with a dedicated feature branch at the configured path (default: `.claude/worktrees/{change}`)
- Automatic name derivation -- provide a description instead of a kebab-case name and the system converts it
- Schema-driven structure -- the workspace contains exactly the artifacts defined by the pipeline, with dependency gating
- **Worktree context detection** -- all change-detecting skills (`ff`, `apply`, `verify`, `discover`, `preflight`) auto-detect the active change from worktree branch context before falling through to directory-based detection
- Date-prefixed naming -- change directories use `YYYY-MM-DD-<name>` format, set at creation time for stable, chronologically sortable names
- **Lazy worktree cleanup** -- when creating a new change, `/opsx:new` detects stale worktrees from merged PRs and cleans them up automatically
- **Post-merge worktree cleanup** -- after a successful merge from within a worktree, the system immediately cleans up the worktree and deletes the branch instead of leaving it for the next `/opsx:new`
- **Active vs completed detection** -- changes are distinguished by tasks.md checkbox status rather than directory location

## Behavior

### Creating a Workspace (/opsx:new)

When you run `/opsx:new add-user-auth`, the system creates a workspace at `openspec/changes/YYYY-MM-DD-add-user-auth/` (the date prefix is determined at creation time) and reads WORKFLOW.md to determine the artifact pipeline, displaying the artifact status and first artifact template. If you provide a description like "add user authentication" instead of a name, the system derives `add-user-auth` automatically. If the name is invalid (contains uppercase or special characters), the system asks for a valid kebab-case name. If a change with that name already exists, the system suggests continuing the existing change instead.

### Worktree-Based Workspace Creation

When `worktree.enabled` is `true` in WORKFLOW.md, `/opsx:new` creates a git worktree instead of a plain directory. The system runs `git worktree add <path> -b <change-name>` where the path is computed from `worktree.path_pattern` (replacing `{change}` with the change name), then creates `openspec/changes/YYYY-MM-DD-<name>/` inside the worktree. The output reports the worktree path and branch name. If the worktree path already exists, the system suggests switching to it. If `worktree.enabled` is `false` or absent, workspace creation falls back to plain `mkdir -p`.

### Worktree Context Detection

All change-detecting skills auto-detect the active change from worktree context before falling through to directory-based detection. The detection checks whether the current working directory is inside a git worktree (via `git rev-parse --git-dir`), derives the change name from the current branch, and verifies that `openspec/changes/<branch-name>/` exists. If all checks pass, the skill auto-selects the change and announces it. If any check fails, the skill falls through to normal detection logic. An explicit argument always overrides worktree detection.

### Workspace Structure and Dependency Gating

The created workspace is a directory at `openspec/changes/<name>/`. The artifact pipeline sequence is determined by reading WORKFLOW.md -- the stages are: research, proposal, specs, design, preflight, and tasks. Only the first stage (research) is ready initially; downstream stages are blocked by unmet dependencies as determined by file existence checks.

### Lazy Worktree Cleanup at Change Creation

Before creating a new change, `/opsx:new` checks for stale worktrees. For each existing worktree, it checks the associated PR's merge status via `gh pr view`. If the PR is merged, the worktree is removed and the branch deleted. If the PR is not merged or no PR exists, the worktree is left untouched. If no stale worktrees are found, creation proceeds silently.

### Post-Merge Worktree Cleanup

After a successful `gh pr merge` from within a worktree, the system immediately cleans up rather than leaving stale worktrees for the next `/opsx:new`. The cleanup sequence switches to the main worktree, removes the completed worktree, and deletes the merged branch. If the worktree has uncommitted changes and removal fails, the system reports the error and suggests manual cleanup without blocking the workflow. This complements lazy cleanup -- lazy cleanup catches worktrees from merges that happened outside the agent session, while post-merge cleanup handles in-session merges immediately.

### Active vs Completed Change Detection

Changes are identified as active or completed based on their tasks.md status. A change with all checkboxes marked `- [x]` is considered completed. A change with any `- [ ]` checkboxes remaining is considered active. Skills that list changes (such as `/opsx:changelog` and `/opsx:docs`) use this status to filter which changes to process.

## Edge Cases

- If the name is invalid (contains uppercase or special characters), the system asks for a valid kebab-case name.
- If a change with that name already exists, the system suggests continuing the existing change instead.
- If `git worktree add` fails because the branch already exists, the system tries to reuse the existing branch.
- If the worktree path exists but is not a git worktree, the system fails with an error rather than overwriting.
- If `git worktree remove` fails on a dirty worktree, the system reports the error and suggests `--force` or committing changes first.
- Each worktree should contain exactly one change matching the branch name; additional `openspec/changes/` directories are ignored by worktree detection.
- If `gh` CLI is unavailable during lazy cleanup, stale worktree detection is skipped silently.
- If WORKFLOW.md has no `worktree` section, worktree mode is disabled.
- If tasks.md does not exist in a change directory, the change is treated as active (in-progress).
