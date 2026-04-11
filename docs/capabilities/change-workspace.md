---
title: "Change Workspace"
capability: "change-workspace"
description: "Workspace creation via propose, worktree isolation, proposal-based context detection, and change lifecycle tracking"
lastUpdated: "2026-04-10"
---

# Change Workspace

Manages the full lifecycle of a change workspace -- from creation through completion -- so that every feature or improvement follows a structured, traceable path. Workspace creation is handled by `/opsx:workflow propose`, and change context detection is handled by the router.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent organizational pattern. When multiple changes are in-flight simultaneously, they interfere through merge conflicts on shared files. Without structured metadata in proposals, commands must rely on fragile conventions to detect which change is active and whether it is complete.

## Rationale

Change names use kebab-case for consistent, URL-safe, filesystem-safe identifiers. Change directories use a date-prefixed naming scheme (YYYY-MM-DD-name) so they sort chronologically by default. Proposal frontmatter carries structured metadata (`status`, `branch`, `worktree`, `capabilities`) that enables the router to detect the active change and filter active vs completed changes without parsing markdown or relying on naming conventions. Workspace creation is part of propose because creating a workspace and starting artifact generation are a single workflow step. Change context detection lives in the router as shared logic, eliminating copy-pasted detection code across multiple skill files.

## Features

- **Workspace creation via propose** -- `/opsx:workflow propose <name>` creates the workspace directory (or git worktree when enabled) and begins pipeline traversal
- **Proposal tracking frontmatter** -- proposals include `status`, `branch`, `worktree` (optional), and `capabilities` (new/modified/removed) in YAML frontmatter
- **Worktree-based isolation** -- when `worktree.enabled` is `true` in WORKFLOW.md, creates a git worktree with a dedicated feature branch based on the latest remote main
- **Automatic name derivation** -- provide a description instead of a kebab-case name and the system converts it
- **Change context detection** -- the router auto-detects the active change by matching proposal `branch` frontmatter against the current branch, falling back to worktree convention and directory listing
- **Date-prefixed naming** -- change directories use `YYYY-MM-DD-<name>` format, set at creation and never changed
- **Lazy worktree cleanup** -- when creating a new change, propose detects stale worktrees by checking proposal `status: completed`, falling back to PR merge status
- **Post-merge worktree cleanup** -- after a successful merge from within a worktree, the system immediately cleans up
- **Active vs completed detection** -- changes are distinguished by proposal `status` field (`active`/`completed`), with fallback to tasks.md checkbox parsing for legacy proposals

## Behavior

### Creating a Workspace (`/opsx:workflow propose`)

When you run `/opsx:workflow propose add-user-auth`, the system creates a workspace at `openspec/changes/YYYY-MM-DD-add-user-auth/` and begins pipeline traversal. If you provide a description, the system derives a kebab-case name automatically. If the name is invalid, the system asks for a valid name. If a change with that name already exists, the system suggests continuing it.

### Proposal Tracking Frontmatter

When the proposal artifact is generated, it includes YAML frontmatter with `status: active`, `branch`, optionally `worktree`, and `capabilities` (structured new/modified/removed lists). This frontmatter enables the router to detect changes, filter by status, and identify affected capabilities without parsing markdown.

### Worktree-Based Workspace Creation

When `worktree.enabled` is `true`, propose creates a git worktree instead of a plain directory. The system fetches the latest remote main branch first, then creates the worktree based on it. If the worktree path already exists, the system suggests switching to it.

### Change Context Detection (Router)

The router auto-detects the active change using a three-tier approach: (1) scan proposal frontmatter for a `branch` field matching the current branch; (2) if no match, check if inside a git worktree and derive the change name from the branch; (3) if not in a worktree, list active changes and prompt. An explicit argument always overrides auto-detection.

### Lazy Worktree Cleanup at Change Creation

Before creating a new change, propose checks for stale worktrees using a five-tier detection hierarchy. Completed proposals and merged PRs are auto-cleaned. Closed (unmerged) PRs and branches inactive beyond the configurable `stale_days` threshold (default: 14 days) trigger a user prompt before cleanup. Proposals are read from the worktree filesystem path to avoid branch-naming mismatches. Active worktrees within the threshold are preserved.

### Post-Merge Worktree Cleanup

After a successful PR merge from within a worktree, the system switches to the main worktree, removes the completed worktree, and deletes local and remote branches. If the worktree has uncommitted changes, removal fails and manual cleanup is suggested.

### Active vs Completed Change Detection

Changes are identified as active or completed based on their proposal's `status` frontmatter field. `active` (or absent) means in progress; `completed` means done (set during verify completion). Commands that operate on active changes (propose, apply) filter to active; commands that operate on completed changes (finalize) filter to completed.

## Edge Cases

- If the name contains uppercase or special characters, the system asks for a valid kebab-case name.
- If a change with that name already exists, the system suggests continuing instead of creating a duplicate.
- If `git worktree add` fails because the branch exists, the system tries to reuse it.
- If the worktree path exists but is not a git worktree, the system fails with an error.
- If `git worktree remove` fails on a dirty worktree, the system reports the error and suggests manual cleanup.
- If WORKFLOW.md has no `worktree` section, worktree mode is disabled.
- If two proposals have the same `branch` value, the most recently modified one is used with a warning.
