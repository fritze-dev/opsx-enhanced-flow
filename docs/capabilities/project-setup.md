---
title: "Project Setup"
capability: "project-setup"
description: "One-time project initialization with OpenSpec CLI, schema, and configuration"
order: 1
lastUpdated: "2026-03-04"
---

# Project Setup

Set up your project for the spec-driven workflow with a single command. `/opsx:init` installs all dependencies, registers the schema, creates configuration files, and validates the setup.

## Features

- Initialize a project for spec-driven development with one command
- Automatic OpenSpec CLI installation and version management
- Schema registration and custom template setup
- Minimal configuration file generation
- Constitution placeholder creation
- Post-setup validation to confirm everything works
- Idempotent — safe to run again on an already-initialized project

## Behavior

### First-Time Initialization

When you run `/opsx:init` on a fresh project, the system installs the OpenSpec CLI globally (if not already present), registers the schema, copies custom schema files and templates into your project, creates a minimal configuration file, and sets up a constitution placeholder. After all steps complete, a validation phase confirms that the CLI is accessible, the schema is valid, and the config is in place.

### Automatic CLI Management

If the OpenSpec CLI is not installed, it is installed automatically. If an older incompatible version is found, it is upgraded. If Node.js or npm are not available, a clear error message explains what needs to be installed first.

### Idempotent Re-Initialization

Running `/opsx:init` on an already-initialized project skips completed steps and preserves your existing constitution. It reports which components were already in place.

### Configuration Generation

The configuration file contains only a schema reference and a pointer to the constitution — no workflow rules or project-specific content. If a configuration file already exists, it is preserved unchanged.

## Edge Cases

- If the plugin's own config has project-specific rules, your project still gets a clean, minimal config — the template is hardcoded in the skill, not copied from the plugin's config.
- If you lack write permissions to the global npm prefix, the install fails with a clear error suggesting `sudo` or an npm prefix configuration change.
- If the project directory is read-only, init fails before making any changes and reports the permission issue.
- If network connectivity is unavailable during npm install, a network error is reported with a suggestion to retry.
