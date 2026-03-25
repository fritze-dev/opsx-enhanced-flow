---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization via /opsx:setup with WORKFLOW.md generation, Smart Template installation, constitution creation, and legacy migration."
lastUpdated: "2026-03-26"
---

# Project Setup

The `/opsx:setup` command performs one-time project initialization, generating WORKFLOW.md, installing Smart Templates, creating the constitution, and validating the setup.

## Purpose

Without `/opsx:setup`, setting up a project for spec-driven development requires manually creating WORKFLOW.md, copying templates, and setting up the constitution -- a multi-step process where any missed step causes confusing errors later. A single initialization command ensures everything is configured correctly from the start.

## Rationale

The setup command copies Smart Templates directly from the plugin and generates WORKFLOW.md from a hardcoded template rather than copying the plugin's own WORKFLOW.md, preventing plugin-specific configuration from leaking into consumer projects. The generated WORKFLOW.md includes a commented-out `docs_language` field for discoverability and an English-enforcement rule ensuring all workflow artifacts remain in English regardless of documentation language settings. Legacy migration detects old project layouts (with `schema.yaml` and `config.yaml`) and converts them automatically, so existing projects transition to the new structure without manual restructuring. No external CLI tools or package managers are required -- setup relies only on file operations that Claude can perform directly.

## Features

- **WORKFLOW.md generation** -- creates `openspec/WORKFLOW.md` with pipeline configuration in YAML frontmatter
- **Smart Template installation** -- copies self-describing templates from the plugin into the project's `openspec/templates/` directory
- **Constitution creation** -- creates `openspec/CONSTITUTION.md` placeholder if none exists
- **Legacy migration** -- detects old layout (schema.yaml, config.yaml, lowercase constitution) and converts to the current structure
- **Post-setup validation** -- verifies WORKFLOW.md readability, template presence, and constitution existence
- **Idempotent execution** -- safe to run multiple times; skips completed steps and preserves existing files
- **Documentation language support** -- WORKFLOW.md template includes a commented-out `docs_language` field and enforces English for workflow artifacts
- **No external dependencies** -- does not require Node.js, npm, or any external CLI tools

## Behavior

### First-Time Initialization

Running `/opsx:setup` on a fresh project copies Smart Templates from the plugin into `openspec/templates/`, generates `openspec/WORKFLOW.md` with pipeline configuration, creates an `openspec/CONSTITUTION.md` placeholder, and validates the setup by confirming all components are present and readable.

### Idempotent Re-Initialization

Running `/opsx:setup` on an already-initialized project skips completed steps, preserves the existing constitution and WORKFLOW.md, and reports which components were already in place.

### Legacy Migration

When the setup command detects a legacy project layout (presence of `openspec/schemas/opsx-enhanced/schema.yaml` without `openspec/WORKFLOW.md`), it performs automatic migration: generates WORKFLOW.md from schema.yaml content, moves and converts templates to Smart Template format, renames `constitution.md` to `CONSTITUTION.md`, and removes legacy files. Migration preserves existing constitution content rather than regenerating it.

### WORKFLOW.md Generation

The generated WORKFLOW.md contains `templates_dir`, `pipeline`, `apply`, `post_artifact`, and `context` fields in YAML frontmatter. The `context` field points to `openspec/CONSTITUTION.md` with an English-enforcement rule for workflow artifacts. The `docs_language` field is included as a comment for discoverability.

### Setup Validation

After all steps complete, the setup command verifies that WORKFLOW.md is readable, the templates directory exists with Smart Template files, and CONSTITUTION.md is present. A summary of validation results is reported. If part of the setup failed silently (for example, the template copy did not complete), validation detects the missing component and reports which specific check failed.

## Edge Cases

- If the project directory is read-only, setup fails before making any changes and reports the permission issue.
- If migration encounters both WORKFLOW.md and legacy schema.yaml (manual partial migration), setup preserves WORKFLOW.md and skips migration.
- If both `constitution.md` (lowercase) and `CONSTITUTION.md` (caps) exist during migration, setup uses the lowercase content and renames to caps.
