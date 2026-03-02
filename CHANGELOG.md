# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-03-02 — Fix Workflow Friction

### Changed
- Workflow rules now live at their authoritative source — schema owns universal rules, constitution owns project-specific rules, config.yaml is just a bootstrap pointer
- Constitution cleaned up: 12 redundant rules removed that duplicated schema instructions and templates
- Init skill generates a minimal config template instead of copying the plugin's own config, preventing project-specific rules from leaking into consumer projects
- Development & Testing documentation simplified

### Added
- Friction tracking convention: workflow friction is now captured as GitHub Issues with the `friction` label
- Definition of Done rule embedded in the schema's task instruction
- Post-apply workflow sequence embedded in the schema's apply instruction

## 2026-03-02 — Fix Init Skill

### Fixed
- `/opsx:init` can now be invoked — was previously invisible due to `disable-model-invocation: true`

### Changed
- Init no longer creates duplicate built-in OpenSpec skills that conflict with the plugin's `/opsx:*` commands
- Init steps reduced from 7 to 6 (removed redundant `openspec init --tools claude`)
- Added directory safety (`mkdir -p`) before copying schema files

## 2026-03-02 — Initial Specification

### Added
- Formal baseline specifications for all 15 plugin capabilities
- Three-layer architecture spec covering Constitution, Schema, and Skills layers
- Project setup and bootstrap specs for initialization and codebase scanning
- Artifact pipeline spec defining the 6-stage workflow with dependency gating
- Artifact generation spec for step-by-step and fast-forward creation commands
- Spec format rules for normative descriptions, Gherkin scenarios, and delta operations
- Change workspace spec covering creation, structure, and archiving lifecycle
- Task implementation spec for working through checklists with progress tracking
- Quality gates spec for preflight checks and post-implementation verification
- Human approval gate spec with mandatory sign-off and fix-verify loop
- Interactive discovery spec for standalone research with targeted Q&A
- Spec sync spec for agent-driven delta merging into baselines
- Constitution management spec for generation, updates, and global enforcement
- Documentation generation spec for user-facing docs and changelog from specs
- Roadmap tracking spec for GitHub Issues with roadmap label
