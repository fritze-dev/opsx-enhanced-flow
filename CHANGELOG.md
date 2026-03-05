# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-03-05 — Fix Docs Skill Regressions

### Fixed
- Phantom ADR no longer generated from archives with prose-only or non-Decisions tables in design.md
- Manual ADR (`adr-M001-init-model-invocable.md`) no longer lost during docs regeneration
- ADR slug generation is now deterministic — consistent file names across regeneration runs
- ADR references now use descriptive link text instead of raw file paths

### Changed
- Manual ADRs (`adr-MNNN-slug.md` naming) are now preserved during regeneration and included in the README design decisions table
- Capability doc Rationale sections use present tense and no longer narrate change history
- Multi-command capabilities now include command names in behavior section headers for quick scanning
- Initial-spec-only capabilities now derive Rationale from spec requirements when archive research data is thin
- README capability descriptions limited to 80 characters / 15 words for scannability
- Notable Trade-offs section now aims to represent every ADR with a substantive negative consequence

## 2026-03-05 — Configurable Docs Language

### Added
- Documentation language is now configurable via `docs_language` in `openspec/config.yaml` — set to any language name (e.g., "German", "French") and `/opsx:docs` generates all capability docs, ADRs, and the consolidated README in that language
- `/opsx:changelog` generates new entries in the configured language, including translated section headers (e.g., "Hinzugefügt" instead of "Added" for German)
- New projects created with `/opsx:init` include a commented-out `docs_language` field for discoverability
- Workflow artifacts (research, proposal, specs, design, preflight, tasks) are now explicitly enforced to be English via the config context field, regardless of documentation language

### Changed
- Init skill config template expanded with `docs_language` field and English-enforcement rule for internal artifacts
- `/opsx:docs` and `/opsx:changelog` now read the `docs_language` setting before generating output
- Product names (OpenSpec, Claude Code), commands, file paths, and YAML frontmatter keys remain in English regardless of configured language

## 2026-03-05 — Improve Docs Sections

### Added
- "Future Enhancements" section in capability docs for deferred features and tracked GitHub Issues, separate from Known Limitations
- "Read before write" guardrail — `/opsx:docs` now reads existing docs before regenerating, preserving established tone and quality
- Purpose BAD/GOOD examples in the capability doc template to prevent change-motivation from replacing capability-purpose

### Changed
- Capability doc headings unified: "Why This Exists" → "Purpose", "Background"/"Design Rationale" → "Rationale" across all 18 docs
- Purpose sections now always derive from the capability's spec Purpose using problem-framing, never from archive proposal "Why" sections
- Non-Goals from design artifacts are now classified into Known Limitations (current constraints) and Future Enhancements (deferred features)
- Enriched section order standardized: Overview, Purpose, Rationale, Features, Behavior, Known Limitations, Future Enhancements, Edge Cases

### Fixed
- 11 Rationale sections that had replaced design reasoning with change-event descriptions reverted to original content
- 4 Purpose sections that had been weakened during regeneration reverted to original content

## 2026-03-05 — Improve Docs Quality

### Added
- Doc templates for capability docs, ADRs, and consolidated README — `/opsx:docs` now reads templates at runtime instead of inlining format definitions
- "Design Rationale" section for initial-spec-only capability docs, derived from bootstrap research data
- Workflow sequence notes for multi-command capabilities (e.g., quality-gates explains when to use preflight vs. verify)
- `order` and `category` YAML frontmatter in baseline specs for deterministic, project-specific documentation ordering
- "Notable Trade-offs" subsection in the architecture overview, surfacing significant negative consequences from ADRs
- "References" section in ADRs linking to related specs and other ADRs

### Changed
- Architecture overview, capabilities table, and ADR index consolidated into a single `docs/README.md` entry point — `docs/architecture-overview.md` and `docs/decisions/README.md` are deleted on regeneration
- Capabilities in documentation are now grouped by workflow phase (Setup, Change Workflow, Development, etc.) and ordered by position within each phase
- ADR "Consequences" section split into "Positive" and "Negative" subsections for clearer trade-off visibility
- ADR "Context" sections now require at least 4-6 sentences covering motivation, investigation, and constraints
- Edge Cases in capability docs restricted to surprising states, error conditions, and non-obvious interactions — normal flow variants moved to Behavior
- Initial-spec "Why This Exists" sections now use problem-framing (what goes wrong without the capability) instead of restating the spec Purpose
- Project README shortened with links to `docs/README.md` for detailed documentation

## 2026-03-05 — Design Review Checkpoint

### Changed
- Design review is now governed by a constitution convention — agents pause after design in any multi-artifact workflow (including `/opsx:ff`) for user alignment

### Added
- "Design review checkpoint" convention in the project constitution — the design phase is the mandatory review point in every workflow
- "Design review mandatory" workflow principle in the README

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
