---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization via /opsx:setup with template-based WORKFLOW.md, Smart Template installation, environment checks, worktree opt-in, and legacy migration"
lastUpdated: "2026-03-30"
---

# Project Setup

The `/opsx:setup` command performs one-time project initialization, copying WORKFLOW.md from a template file, installing Smart Templates, creating the constitution, detecting environment capabilities, offering worktree mode, and validating the setup.

## Purpose

Without `/opsx:setup`, setting up a project for spec-driven development requires manually creating WORKFLOW.md, copying templates, and setting up the constitution -- a multi-step process where any missed step causes confusing errors later. A single initialization command ensures everything is configured correctly from the start, detects available tools, and offers optional features based on the environment.

## Rationale

The setup command copies WORKFLOW.md from a template file (`${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`) rather than generating it inline, consistent with the constitution template pattern and providing a single source of truth that is easier to maintain across plugin versions. Smart Templates are copied directly from the plugin directory. Legacy migration detects old project layouts (with `schema.yaml` and `config.yaml`) and converts them automatically, so existing projects transition to the new structure without manual restructuring. Environment checks (gh CLI, git version, .gitignore) run non-blockingly to inform which optional features are available -- worktree-based change isolation and GitHub merge strategy configuration are only offered when the environment supports them. No external CLI tools or package managers are required for core setup.

## Features

- **WORKFLOW.md from template** -- copies WORKFLOW.md from `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` rather than generating inline, with a commented-out `worktree:` section
- **Smart Template installation** -- copies self-describing templates from the plugin into the project's `openspec/templates/` directory
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

Running `/opsx:setup` on a fresh project copies Smart Templates from the plugin into `openspec/templates/`, copies `openspec/WORKFLOW.md` from the plugin's workflow template, creates an `openspec/CONSTITUTION.md` placeholder, runs environment checks, offers worktree mode if supported, and validates the setup by confirming all components are present and readable.

### Environment Checks

The setup command checks: (1) `gh` CLI availability via `gh --version` and authentication via `gh auth status`, (2) git version via `git --version` to verify 2.5+ for worktree support, (3) `.gitignore` for a `/.claude/` entry. Results are reported in the setup summary. These checks do not block setup -- they only determine which optional features are available.

### Worktree Opt-In

When the `gh` CLI is available and authenticated, and git version is 2.5+, setup asks whether to enable worktree-based change isolation. If the user opts in, setup uncomments the `worktree:` section in WORKFLOW.md and sets `enabled: true`. Setup also offers to configure the GitHub repo for rebase-merge via `gh api repos/{owner}/{repo} -X PATCH -f allow_rebase_merge=true`. If `gh` CLI is not available or git is too old, the worktree question is skipped. If `.gitignore` is missing `/.claude/`, setup offers to add it when the user opts into worktree mode.

### Idempotent Re-Initialization

Running `/opsx:setup` on an already-initialized project skips completed steps, preserves the existing constitution and WORKFLOW.md, and reports which components were already in place.

### Legacy Migration

When the setup command detects a legacy project layout (presence of `openspec/schemas/opsx-enhanced/schema.yaml` without `openspec/WORKFLOW.md`), it performs automatic migration: generates WORKFLOW.md from schema.yaml content, moves and converts templates to Smart Template format, renames `constitution.md` to `CONSTITUTION.md`, and removes legacy files. Migration preserves existing constitution content rather than regenerating it.

### WORKFLOW.md Template

The plugin includes a workflow template file at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` containing default WORKFLOW.md content with YAML frontmatter (`templates_dir`, `pipeline`, `apply`, `post_artifact`, `context`, `docs_language`) and a commented-out `worktree:` section. This template is copied to `openspec/WORKFLOW.md` during setup, ensuring the content is maintained as a versioned template file.

### Setup Validation

After all steps complete, the setup command verifies that WORKFLOW.md is readable, the templates directory exists with Smart Template files, and CONSTITUTION.md is present. A summary of validation results is reported. If part of the setup failed silently (for example, the template copy did not complete), validation detects the missing component and reports which specific check failed.

## Edge Cases

- If the project directory is read-only, setup fails before making any changes and reports the permission issue.
- If migration encounters both WORKFLOW.md and legacy schema.yaml (manual partial migration), setup preserves WORKFLOW.md and skips migration.
- If both `constitution.md` (lowercase) and `CONSTITUTION.MD` (caps) exist during migration, setup uses the lowercase content and renames to caps.
- If the workflow template is missing from the plugin, setup reports an error and suggests reinstalling the plugin.
- If `gh` CLI is installed but not authenticated, setup reports "gh CLI: installed but not authenticated" and skips the worktree opt-in.
- If the user declines worktree mode, the `worktree:` section remains commented out in WORKFLOW.md.
- If the merge strategy `gh api` call fails due to insufficient permissions, setup reports the failure and continues.
