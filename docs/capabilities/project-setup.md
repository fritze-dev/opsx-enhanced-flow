---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization via /opsx:init with CLI install and schema setup."
lastUpdated: "2026-03-05"
---
# Project Setup

The `/opsx:init` command performs one-time project initialization, installing the OpenSpec CLI, setting up the schema, creating configuration files, and validating the setup.

## Purpose

Without `/opsx:init`, setting up a project for spec-driven development requires manually installing the OpenSpec CLI, registering the schema, copying schema files, creating configuration, and setting up the constitution — a multi-step process where any missed step causes confusing errors later. A single initialization command ensures everything is configured correctly from the start.

## Rationale

The init command uses `openspec schema init` instead of `openspec init --tools claude` because the latter creates built-in OpenSpec skills that duplicate and conflict with the plugin's own `/opsx:*` commands. Configuration is generated from a hardcoded template rather than copied from the plugin's own config.yaml, preventing project-specific rules from leaking into consumer projects. The generated config includes a commented-out `docs_language` field for discoverability and an English-enforcement rule ensuring all workflow artifacts remain in English regardless of documentation language settings.

## Features

- **Automated CLI installation** — installs the OpenSpec CLI globally via npm if not already present
- **Schema setup** — registers and copies the opsx-enhanced schema into the project
- **Config generation** — creates a minimal config.yaml from a template with schema reference and constitution pointer
- **Constitution placeholder** — creates a constitution file if none exists
- **Post-setup validation** — verifies CLI accessibility, schema validity, and config presence
- **Idempotent execution** — safe to run multiple times; skips completed steps and preserves existing files
- **Documentation language support** — config template includes a commented-out `docs_language` field and enforces English for workflow artifacts

## Behavior

### First-Time Initialization

Running `/opsx:init` on a fresh project installs the OpenSpec CLI globally, registers the schema via `openspec schema init`, copies custom schema files from the plugin, creates config.yaml from a template, creates a constitution placeholder, and validates the setup.

### Idempotent Re-Initialization

Running `/opsx:init` on an already-initialized project skips completed steps, preserves the existing constitution and config, and reports which components were already in place.

### No Duplicate Skill Creation

The init command does not create any `.claude/skills/openspec-*` skill files. These would duplicate the plugin's own `/opsx:*` skills and cause conflicts.

### Config Generation from Template

The generated config.yaml contains a `schema` reference, a commented-out `docs_language` field, and a `context` field pointing to the project constitution with an English-enforcement rule for workflow artifacts. It does not contain workflow rules or per-artifact rules from the plugin's own config.

### Existing Config Preserved

If `openspec/config.yaml` already exists, `/opsx:init` preserves it unchanged.

### Config Documentation Language Support

The generated config includes `# docs_language: English` as a commented-out field for discoverability and a context rule enforcing English for all workflow artifacts (research, proposal, specs, design, preflight, tasks).

### CLI Auto-Installation

If the OpenSpec CLI is not installed globally and npm is available, `/opsx:init` runs `npm install -g @fission-ai/openspec`. The installed version is compatible with `^1.2.0`. If npm is not available, a clear error message provides installation guidance.

### CLI Version Check

If the CLI is already installed at a compatible version, installation is skipped. If an incompatible version (below `^1.2.0`) is detected, it is upgraded automatically.

### Setup Validation

After all installation steps complete, the init command verifies that the CLI is accessible and at a compatible version, the schema directory exists with a valid `schema.yaml`, and the config is present. A summary of validation results is reported.

### Validation Detects Failures

If part of the setup failed silently (for example, the schema copy did not complete), validation detects the missing component and reports which specific check failed.

## Known Limitations

- Requires Node.js and npm to be installed on the system.
- Uses npm global install (`npm install -g`), which may require elevated permissions depending on the system configuration.

## Edge Cases

- If you do not have write permissions to the global npm prefix, the auto-install fails with an error suggesting `sudo` or an npm prefix configuration change.
- If the project directory is read-only, init fails before making any changes and reports the permission issue.
- If network connectivity is unavailable during npm install, the system reports a network error with a suggestion to retry.
- The init template is hardcoded in the skill, not read from the plugin's own config.yaml. Even if the plugin maintainer adds project-specific rules to their config, consumer projects get a clean template.
