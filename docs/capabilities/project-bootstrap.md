---
title: "Project Bootstrap"
capability: "project-bootstrap"
description: "Scan your codebase to generate a constitution and initial change, or detect drift in recovery mode"
order: 2
lastUpdated: "2026-03-04"
---

# Project Bootstrap

Bootstrap your existing project into the spec-driven workflow. `/opsx:bootstrap` scans your codebase, generates a constitution reflecting your actual patterns, creates an initial change workspace, and hands off to the standard pipeline.

## Features

- Automatic codebase scanning to detect tech stack, frameworks, conventions, and file structure
- Constitution generation based on observed patterns — not generic defaults
- Initial change workspace creation with handoff to the artifact pipeline
- Recovery mode that detects drift between your code and existing specs
- Handles projects of any size, skipping binary files and respecting `.gitignore`

## Behavior

### First-Run Codebase Scan

When you run `/opsx:bootstrap` on a project without existing specs, the system scans your entire codebase — source files, configuration, dependencies, and directory structure — to identify your tech stack, coding conventions, and architecture patterns. Binary files are skipped and `.gitignore` patterns are respected.

### Constitution Generation

Based on the scan results, a constitution file is generated with sections for Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every entry reflects an observed pattern in your codebase. Items where the system is uncertain are marked with `<!-- REVIEW -->` for you to confirm or correct.

### Initial Change Creation and Handoff

After the constitution is generated, an initial change workspace is created. The system then guides you to continue with `/opsx:ff` or `/opsx:continue` to generate artifacts, followed by `/opsx:apply` for implementation, and `/opsx:archive` to finalize.

### Recovery Mode

If baseline specs already exist, bootstrap enters recovery mode. It scans the current codebase, compares it against existing specs, and produces a drift report listing discrepancies. For minor drift, it suggests creating a targeted change. For major drift, it suggests a full re-bootstrap after backing up existing specs. Recovery mode never overwrites existing specs or the constitution.

## Edge Cases

- If the project has no source code files (empty repository), a minimal constitution with placeholder sections is generated and you are asked to update it manually.
- If the codebase uses multiple languages or conflicting conventions, the primary patterns are documented and variations are noted as exceptions.
- If a constitution exists but no specs exist, bootstrap treats this as a partial first-run — it skips constitution generation and proceeds to initial change creation.
- If the OpenSpec CLI is not installed, bootstrap instructs you to run `/opsx:init` first.
- If the project has an extremely deep directory structure, the scan uses reasonable depth limits to avoid performance issues.
