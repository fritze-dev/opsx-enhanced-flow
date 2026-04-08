---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization via /opsx:setup with template-based WORKFLOW.md, Smart Template installation, version-aware template merge, environment checks, worktree opt-in, and legacy migration"
lastUpdated: "2026-04-08"
---

# Project Setup

The `/opsx:setup` command performs one-time project initialization and handles plugin updates -- copying WORKFLOW.md from a template file, installing Smart Templates with version-aware merge detection, creating the constitution, detecting environment capabilities, offering worktree mode, and validating the setup.

## Purpose

Without `/opsx:setup`, setting up a project for spec-driven development requires manually creating WORKFLOW.md, copying templates, and setting up the constitution -- a multi-step process where any missed step causes confusing errors later. Without template merge detection, re-running setup after a plugin update either overwrites user customizations or leaves stale templates that miss plugin improvements. A single initialization command ensures everything is configured correctly from the start, detects available tools, and preserves customizations during updates.

## Rationale

The setup command copies WORKFLOW.md from a template file (`${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`) rather than generating it inline, consistent with the constitution template pattern and providing a single source of truth. Smart Templates are copied directly from the plugin directory, each carrying a `template-version` field for merge detection. On re-setup, the system compares local and plugin `template-version` values along with content hashes to determine whether to skip (already up to date), update silently (no user customizations), or prompt for merge (both sides changed). WORKFLOW.md is included in merge detection (replacing the previous skip-if-exists behavior) so that users receive plugin updates to behavioral fields like `apply.instruction` and `post_artifact`. CONSTITUTION.md uses section-level merge -- only structural additions from template updates are offered, existing user content is preserved. Legacy migration detects old project layouts and converts them automatically. Environment checks run non-blockingly to inform which optional features are available.

## Features

- **WORKFLOW.md from template** -- copies WORKFLOW.md from `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` rather than generating inline, with a commented-out `worktree:` section
- **Smart Template installation** -- copies self-describing templates from the plugin into the project's `openspec/templates/` directory
- **Version-aware template merge** -- on re-setup, uses `template-version` fields to detect user customizations and merge plugin updates instead of overwriting
- **WORKFLOW.md merge detection** -- WORKFLOW.md is included in version-based merge (replaces skip-if-exists), so plugin updates to behavioral fields are not missed
- **Constitution section-level merge** -- new sections from template updates are offered for interactive generation; existing user content is preserved
- **Constitution creation** -- creates `openspec/CONSTITUTION.md` placeholder if none exists
- **Environment checks** -- detects `gh` CLI availability and authentication, git version (2.5+ for worktree support), and `.gitignore` coverage for `/.claude/`
- **Worktree opt-in** -- when `gh` CLI is available and git supports worktrees, asks whether to enable worktree-based change isolation and uncomments the `worktree:` section in WORKFLOW.md
- **GitHub merge strategy configuration** -- when the user opts into worktree mode, offers to configure the repository for rebase-merge via `gh api`
- **Legacy migration** -- detects old layout (schema.yaml, config.yaml, lowercase constitution) and converts to the current structure
- **Post-setup validation** -- verifies WORKFLOW.md readability, template presence, and constitution existence
- **Idempotent execution** -- safe to run multiple times; skips completed steps and preserves existing files
- **No external dependencies** -- does not require Node.js, npm, or any external CLI tools

## Behavior

### First-Time Initialization (/opsx:setup)

Running `/opsx:setup` on a fresh project copies Smart Templates from the plugin into `openspec/templates/`, copies `openspec/WORKFLOW.md` from the plugin's workflow template, creates an `openspec/CONSTITUTION.md` placeholder, runs environment checks, offers worktree mode if supported, and validates the setup.

### Template Merge on Re-Setup (/opsx:setup)

When `/opsx:setup` runs on an already-initialized project (after a plugin update), it uses the `template-version` field in each template to determine the correct action. If the local template matches the plugin version and content, it is skipped. If the local template matches the plugin version but content differs, the user has customized it -- it is preserved and reported. If the plugin version is higher and the local content was not customized, the template is updated silently. If the plugin version is higher and the local content was customized, the system presents both versions for interactive merge. Legacy templates without a `template-version` field are treated as version 0.

### WORKFLOW.md Merge Detection

WORKFLOW.md participates in version-based merge detection rather than being skipped when it already exists. This ensures that plugin updates to behavioral fields (`apply.instruction`, `post_artifact`, `context`) reach consumer projects. User-specific fields (`worktree`, `docs_language`, pipeline order) are preserved during merge.

### Constitution Section-Level Merge

When a plugin update adds new sections to the constitution template (for example, a `## Security Rules` section), setup detects the missing section by comparing template headings against the existing CONSTITUTION.md. Missing sections are offered for interactive generation (the agent reads the codebase and proposes content). Existing sections with user content are preserved unchanged.

### Environment Checks

The setup command checks: (1) `gh` CLI availability via `gh --version` and authentication via `gh auth status`, (2) git version via `git --version` to verify 2.5+ for worktree support, (3) `.gitignore` for a `/.claude/` entry. Results are reported in the setup summary. These checks do not block setup -- they only determine which optional features are available.

### Worktree Opt-In

When the `gh` CLI is available and authenticated, and git version is 2.5+, setup asks whether to enable worktree-based change isolation. If the user opts in, setup uncomments the `worktree:` section in WORKFLOW.md and sets `enabled: true`, and offers to configure the GitHub repo for rebase-merge. If `gh` CLI is not available or git is too old, the worktree question is skipped. If `.gitignore` is missing `/.claude/`, setup offers to add it.

### Idempotent Re-Initialization

Running `/opsx:setup` on an already-initialized project applies template merge logic for templates and WORKFLOW.md, preserves the existing constitution (checking for new sections), and reports which components were already in place or updated.

### Legacy Migration

When the setup command detects a legacy project layout (presence of `openspec/schemas/opsx-enhanced/schema.yaml` without `openspec/WORKFLOW.md`), it performs automatic migration: generates WORKFLOW.md from schema.yaml content, moves and converts templates to Smart Template format, renames `constitution.md` to `CONSTITUTION.md`, and removes legacy files. Migration preserves existing constitution content.

### WORKFLOW.md Template

The plugin includes a workflow template file at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` containing default WORKFLOW.md content with YAML frontmatter and a commented-out `worktree:` section.

### Setup Validation

After all steps complete, the setup command verifies that WORKFLOW.md is readable, the templates directory exists with Smart Template files, and CONSTITUTION.md is present. If part of the setup failed silently, validation detects and reports it.

## Edge Cases

- If the project directory is read-only, setup fails before making any changes and reports the permission issue.
- If migration encounters both WORKFLOW.md and legacy schema.yaml (manual partial migration), setup preserves WORKFLOW.md and skips migration.
- If both `constitution.md` (lowercase) and `CONSTITUTION.MD` (caps) exist during migration, setup uses the lowercase content and renames to caps.
- If the workflow template is missing from the plugin, setup reports an error and suggests reinstalling the plugin.
- If the merge detection encounters templates in subdirectories (e.g., `templates/specs/spec.md`), it processes them recursively.
- If the plugin `template-version` is lower than the local version (plugin downgrade), setup warns and skips rather than downgrading.
- If `gh` CLI is installed but not authenticated, setup reports "gh CLI: installed but not authenticated" and skips the worktree opt-in.
- If the user declines worktree mode, the `worktree:` section remains commented out in WORKFLOW.md.
- If the merge strategy `gh api` call fails due to insufficient permissions, setup reports the failure and continues.
