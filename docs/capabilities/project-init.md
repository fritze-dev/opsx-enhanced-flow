---
title: "Project Init"
capability: "project-init"
description: "One-command project initialization with template merge, codebase scanning, constitution generation, and health checks"
lastUpdated: "2026-04-10"
---

# Project Init

Sets up a project for the opsx-enhanced workflow via `/opsx:workflow init` -- installing templates, generating a constitution from your codebase, configuring optional worktree isolation, and running health checks for spec and documentation drift.

## Purpose

Without a structured setup process, adopting spec-driven development requires manually creating configuration files, writing a constitution from scratch, and hoping the environment supports the features you need. Existing projects that drift from their specs have no way to detect the gap. Project Init handles all of this in a single command, whether you are starting fresh, migrating from a legacy layout, or checking the health of an established project.

## Rationale

A single `/opsx:workflow init` command covers fresh installs, legacy migrations, and re-initialization after plugin updates because these are all variations of the same concern: ensuring the project has the right files in the right state. Template merge detection uses a `template-version` field rather than blind overwrites so that user customizations survive plugin updates. The codebase scan runs on first setup to generate a project-specific constitution rather than a generic placeholder, since the constitution drives all subsequent AI behavior. Drift detection for specs and docs runs as a health check rather than auto-fixing, keeping the user in control of resolution decisions.

## Features

- **One-command setup** via `/opsx:workflow init` -- copies Smart Templates, installs WORKFLOW.md, creates CONSTITUTION.md placeholder, and validates the result
- **Version-aware template merge** -- uses `template-version` fields to detect user customizations and merge plugin updates instead of overwriting
- **Constitution section-level merge** -- detects missing sections from newer template versions and offers to generate content for them based on the codebase
- **Codebase scanning** -- analyzes tech stack, frameworks, languages, file structure, and coding conventions to populate the constitution with project-specific values
- **Constitution generation** -- produces Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and Standard Tasks sections from scan results
- **Environment checks** -- detects `gh` CLI availability, git version (2.5+ for worktree support), and `.gitignore` configuration
- **Worktree opt-in** -- offers to enable worktree-based change isolation when `gh` is available, including GitHub merge strategy configuration
- **Legacy migration** -- detects old schema-based layouts and automatically migrates to the WORKFLOW.md format
- **Idempotent re-initialization** -- skips already-completed steps when run on an initialized project
- **Spec drift detection** -- compares existing specs against the codebase and reports discrepancies with suggested corrective actions
- **Documentation drift verification** -- checks capability docs, ADRs, and README against current specs across three dimensions with CLEAN/DRIFTED/OUT OF SYNC verdicts
- **Initial change creation** -- creates the first change workspace after constitution generation and hands off to the standard pipeline

## Behavior

### Fresh Project Initialization

When you run `/opsx:workflow init` on a project without the workflow installed, the system copies Smart Templates from the plugin's templates directory, installs WORKFLOW.md from the plugin template, and creates a CONSTITUTION.md placeholder. If `gh` is available and authenticated, it offers to enable worktree mode and configure the GitHub repository for rebase-merge. The command validates that all files are in place and reports a summary.

### Codebase Scanning and Constitution Generation

On first run (no existing CONSTITUTION.md), the system scans the entire project -- skipping binary files and respecting `.gitignore` patterns -- to identify the tech stack, frameworks, file structure, and coding conventions. The scan results populate a project-specific constitution with Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, and an empty Standard Tasks section with an explanatory comment.

### Template Merge on Re-Init

When re-running init after a plugin update, the system compares `template-version` fields between local and plugin templates. Unchanged templates are updated silently. User-customized templates are preserved with a notification. Templates with both local customizations and plugin updates prompt for manual merge resolution. For CONSTITUTION.md, the merge operates at section level -- missing sections from newer template versions are offered for interactive generation.

### Legacy Migration

When the system detects a legacy project layout (presence of `openspec/schemas/` without WORKFLOW.md), it generates WORKFLOW.md from schema.yaml, moves and converts templates to Smart Template format, renames the constitution file, and removes legacy directories.

### Recovery Mode (Spec Drift Detection)

When existing specs are found, init enters recovery mode: scanning the codebase, comparing against specs, and producing a read-only drift report. Minor drift prompts a targeted change suggestion; major drift suggests a full re-bootstrap.

### Documentation Drift Verification

As a health check, init verifies generated documentation against current specs across three dimensions: capability docs vs specs (missing docs are CRITICAL, omitted requirements are WARNING), ADRs vs design decisions (missing ADRs are WARNING, using `has_decisions` frontmatter to skip irrelevant designs), and README vs current state (missing capabilities are CRITICAL, stale ADR references are WARNING). The verdict is CLEAN, DRIFTED, or OUT OF SYNC. No issues are auto-fixed; the system recommends running `/opsx:workflow finalize` to regenerate.

### Environment Checks

Init checks `gh` CLI availability and authentication, git version for worktree support, and `.gitignore` for the `/.claude/` entry. Results are informational -- they do not block init but determine which optional features are available.

## Known Limitations

- Codebase scanning relies on static file analysis (file extensions, config files, package manifests) without executing project code.
- Recovery mode compares structural and naming patterns rather than performing deep semantic analysis of code behavior.
- Documentation drift detection checks structural alignment, not prose-level semantic equivalence.

## Edge Cases

- If the user lacks write permissions, init fails before making changes.
- If both lowercase `constitution.md` and uppercase `CONSTITUTION.md` exist during migration, init uses the lowercase content and renames to uppercase.
- If WORKFLOW.md exists alongside legacy `schema.yaml` (partial manual migration), init preserves WORKFLOW.md and skips migration.
- If the plugin `template-version` is lower than the local version (plugin downgrade), init warns and skips rather than downgrading.
- If an empty repository has no source code files, init generates a minimal constitution with placeholder sections.
