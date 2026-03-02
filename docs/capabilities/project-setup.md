---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization with /opsx:init including CLI installation and validation"
order: 2
lastUpdated: "2026-03-02"
---

# Project Setup

Run `/opsx:init` once to set up everything needed for spec-driven development. The command installs the OpenSpec CLI, registers the schema, copies custom templates from the plugin, creates configuration and a constitution placeholder, and validates the result.

## Features

- Single command sets up the entire project for spec-driven development
- Automatically installs the OpenSpec CLI if not present
- Copies the plugin's custom schema and templates into your project
- Creates a constitution placeholder for project-specific rules
- Idempotent: running it again skips already-completed steps and preserves existing files
- Validates the setup after installation to confirm everything works
- No duplicate skills: uses the plugin's `/opsx:*` commands instead of creating built-in OpenSpec skills

## Behavior

### First-Time Initialization

When you run `/opsx:init` on a fresh project, the system installs the OpenSpec CLI globally via npm, registers the `opsx-enhanced` schema, copies custom schema files and templates from the plugin, creates `openspec/config.yaml` with workflow rules, creates a constitution placeholder, and validates the setup.

### Re-Initialization

Running `/opsx:init` on an already-initialized project skips completed steps, preserves your existing `constitution.md`, and reports what was already in place.

### No Duplicate Skills

The init command uses `openspec schema init` directly instead of `openspec init --tools claude`. This avoids creating built-in OpenSpec skills that would conflict with the plugin's own `/opsx:*` commands.

### CLI Version Management

The system checks for the OpenSpec CLI (`@fission-ai/openspec`) at version `^1.2.0`. If the CLI is missing, it auto-installs. If an incompatible version is found, it upgrades. If npm is unavailable, you get a clear error with installation guidance.

### Post-Setup Validation

After installation, the system verifies CLI accessibility, schema validity, and config presence. You see a summary of all validation results so you can trust the environment is ready.

## Edge Cases

- If you lack write permissions to the global npm prefix, the install fails with a clear error suggesting `sudo` or npm prefix configuration.
- If the project directory is read-only, init fails before making any changes.
- If network connectivity is unavailable during npm install, you get a network error with a retry suggestion.
