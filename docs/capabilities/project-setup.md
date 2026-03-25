---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization via /opsx:setup with schema file copy and config creation."
lastUpdated: "2026-03-25"
---
# Project Setup

The `/opsx:setup` command performs one-time project initialization, copying schema files, creating configuration, and validating the setup.

## Purpose

Without `/opsx:setup`, setting up a project for spec-driven development requires manually copying schema files, creating configuration, and setting up the constitution -- a multi-step process where any missed step causes confusing errors later. A single initialization command ensures everything is configured correctly from the start.

## Rationale

The setup command copies schema files directly from the plugin rather than requiring an external tool to register them. Configuration is generated from a hardcoded template rather than copied from the plugin's own config.yaml, preventing project-specific rules from leaking into consumer projects. The generated config includes a commented-out `docs_language` field for discoverability and an English-enforcement rule ensuring all workflow artifacts remain in English regardless of documentation language settings. No external CLI tools or package managers are required -- setup relies only on file operations that Claude can perform directly.

## Features

- **Schema file copy** -- copies the opsx-enhanced schema files and templates into the project
- **Config generation** -- creates a minimal config.yaml from a template with schema reference and constitution pointer
- **Constitution placeholder** -- creates a constitution file if none exists
- **Post-setup validation** -- verifies schema file readability and config presence
- **Idempotent execution** -- safe to run multiple times; skips completed steps and preserves existing files
- **Documentation language support** -- config template includes a commented-out `docs_language` field and enforces English for workflow artifacts
- **No external dependencies** -- does not require Node.js, npm, or any external CLI tools

## Behavior

### First-Time Initialization

Running `/opsx:setup` on a fresh project copies custom schema files from the plugin into `openspec/schemas/`, creates config.yaml from a template, creates a constitution placeholder, and validates the setup by confirming the schema files are readable.

### Idempotent Re-Initialization

Running `/opsx:setup` on an already-initialized project skips completed steps, preserves the existing constitution and config, and reports which components were already in place.

### No Duplicate Skill Creation

The setup command does not create any `.claude/skills/openspec-*` skill files. These would duplicate the plugin's own `/opsx:*` skills and cause conflicts.

### Config Generation from Template

The generated config.yaml contains a `schema` reference, a commented-out `docs_language` field, and a `context` field pointing to the project constitution with an English-enforcement rule for workflow artifacts. It does not contain workflow rules or per-artifact rules from the plugin's own config.

### Existing Config Preserved

If `openspec/config.yaml` already exists, `/opsx:setup` preserves it unchanged.

### Config Documentation Language Support

The generated config includes `# docs_language: English` as a commented-out field for discoverability and a context rule enforcing English for all workflow artifacts (research, proposal, specs, design, preflight, tasks).

### Setup Validation

After all steps complete, the setup command verifies that the schema directory exists with a readable `schema.yaml` and that `config.yaml` is present. A summary of validation results is reported.

### Validation Detects Failures

If part of the setup failed silently (for example, the schema copy did not complete), validation detects the missing component and reports which specific check failed.

## Edge Cases

- If the project directory is read-only, setup fails before making any changes and reports the permission issue.
- The setup template is hardcoded in the skill, not read from the plugin's own config.yaml. Even if the plugin maintainer adds project-specific rules to their config, consumer projects get a clean template.
