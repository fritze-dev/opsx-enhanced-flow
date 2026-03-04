# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-03-04 — Documentation Ecosystem

### Added
- Enriched capability docs — `/opsx:docs` now adds "Why This Exists", "Background", and "Known Limitations" sections by reading archived proposal, research, design, and preflight artifacts
- Architecture overview generation — `/opsx:docs` creates `docs/architecture-overview.md` from constitution, three-layer-architecture spec, and design decisions
- Architecture Decision Records (ADRs) — `/opsx:docs` generates formal ADRs from archived design.md Decisions tables with research context

### Changed
- `docs-generation` capability split into three focused capabilities: `user-docs`, `architecture-docs`, `decision-docs`
- Changelog generation moved from `docs-generation` to `release-workflow` capability
- Documentation table of contents now links architecture overview and decisions index

## 2026-03-04 — Release Workflow

### Added
- Automatic patch version bump on archive — plugin version in `plugin.json` and `marketplace.json` auto-increments after each `/opsx:archive`
- Skill immutability rule — skills are shared plugin code and must not be modified for project-specific behavior
- Release workflow spec covering auto-bump, manual minor/major releases, consumer update process, and end-to-end test checklist
- Documented consumer update process: marketplace refresh → plugin update → restart

### Fixed
- `marketplace.json` version synced to match `plugin.json` (was 3 patch versions behind)
- Manual version bump convention replaced with automatic post-archive bump — eliminates forgotten version bumps

### Changed
- "Updating the Plugin" section in README simplified to reflect automatic versioning

## 2026-03-02 — Final Verify Step

### Changed
- QA loop now includes a mandatory final verification step (3.5) after the fix loop, ensuring all post-fix changes are verified before approval
- Approval step renumbered from 3.5 to 3.6 to accommodate the new final verify step
- Approval is now gated by a clean final verify pass — if the fix loop introduced new issues, they must be resolved first
- If the initial verify was clean and no fixes were needed, the final verify step is automatically satisfied

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
