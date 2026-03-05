---
title: "Project Bootstrap"
capability: "project-bootstrap"
description: "Provides initial codebase scanning, constitution generation, initial change creation, and recovery mode for detecting drift between code and specs."
lastUpdated: "2026-03-05"
---

# Project Bootstrap

Scans your existing codebase, generates a project constitution, creates the first change workspace, and hands off to the standard spec-driven workflow -- getting a project from zero to structured development in a single command.

## Purpose

Adopting spec-driven development on an existing project requires understanding the codebase's tech stack, conventions, and architecture before any specs can be written. Without an automated bootstrap, this analysis is manual and error-prone, leading to constitutions that describe generic defaults rather than actual project patterns. Project Bootstrap automates this entire onboarding process and also provides a recovery mode for projects where code and specs have drifted apart.

## Rationale

The bootstrap scan analyzes static files (source code, configuration, package manifests) to detect the tech stack, frameworks, coding conventions, and file structure -- without executing any project code. This keeps the process safe and fast. The generated constitution is project-specific rather than generic, because it derives every section from observed patterns. Recovery mode exists as a separate path because overwriting existing specs would destroy valuable work; instead, it produces a read-only drift report and lets you decide on the corrective action.

## Features

- **Automatic codebase scanning** -- identifies tech stack, languages, frameworks, file structure, dependency management, and coding conventions.
- **Constitution generation** -- creates `openspec/constitution.md` with Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections populated from scan results.
- **Initial change creation** -- sets up the first change workspace and provides a clear workflow handoff.
- **Recovery mode** -- detects existing specs and reports drift without overwriting anything.

## Behavior

### First-Run Codebase Scan

When you run `/opsx:bootstrap` on a project without an existing constitution, the system scans the entire codebase. It identifies the tech stack, languages, frameworks, file structure, configuration patterns, and coding conventions. Binary files are skipped, and `.gitignore` patterns are respected.

### Constitution Generation

Based on the scan results, the system creates `openspec/constitution.md`. If your project uses TypeScript, React, and Jest, for example, the Tech Stack section lists those technologies. If your code uses 4-space indentation and camelCase, the Code Style section reflects those conventions. The constitution captures your project as it actually is, not as a generic template.

### Initial Change Creation and Handoff

After generating the constitution, the system creates the first change workspace (e.g., `initial-spec`) using the OpenSpec CLI. It then provides a clear workflow guide: use `/opsx:ff` or `/opsx:continue` to generate artifacts, `/opsx:apply` for the QA loop, and `/opsx:archive` to archive the change (which prompts for spec sync).

### Recovery Mode

If baseline specs already exist in `openspec/specs/`, running `/opsx:bootstrap` enters recovery mode. The system scans the codebase, compares it against existing specs, and produces a drift report listing discrepancies. It does not modify any existing files. For minor drift (e.g., renamed functions), it suggests creating a targeted change. For major drift (e.g., rewritten modules), it suggests a full re-bootstrap after backing up existing specs.

## Known Limitations

- Codebase scanning relies on static file analysis and may not detect conventions that are only visible at runtime.
- Recovery mode drift detection compares structural and naming patterns rather than performing deep semantic analysis.

## Edge Cases

- If the project has no source code files (empty repository), bootstrap generates a minimal constitution with placeholder sections and asks you to update it manually.
- If the codebase uses multiple languages or conflicting conventions, the constitution documents the primary patterns and notes variations as exceptions.
- If a constitution exists but `openspec/specs/` is empty, bootstrap treats this as a partial first-run: it skips constitution generation and proceeds to initial change creation.
- If the OpenSpec CLI is not installed, bootstrap directs you to run `/opsx:init` first.
