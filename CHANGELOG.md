# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-03-25 — ADR-Aware Docs Restructure

### Changed
- Documentation entry point `docs/README.md` restructured from a monolithic 148-line document into a compact hub linking to separate architecture and decisions files — the README now focuses on navigation and capability browsing (closes #17)
- Architecture overview (System Architecture, Tech Stack, Conventions) moved to standalone `docs/architecture.md` with independent conditional regeneration triggered only by constitution drift
- Key Design Decisions table and Notable Trade-offs moved to standalone `docs/decisions.md` with independent conditional regeneration triggered only by new ADRs
- `/opsx:discover` now reads existing architectural decisions during research — scans `docs/decisions.md` as a lightweight index and deep-dives into relevant ADR files for full context, avoiding loading all 26+ ADR files

### Added
- `docs/architecture.md` template in the schema for focused architecture documentation
- `docs/decisions.md` template in the schema for dedicated decisions index
- "Related Decisions" section in the research template for capturing ADR context during discovery
- ADR awareness guidance in the schema's research instruction
- Per-file conditional regeneration: each documentation file has its own trigger (constitution drift → architecture, ADR changes → decisions, capability/sub-file changes → README)

## 2026-03-25 — Add PR Step

### Added
- Draft pull request is automatically created during the proposal step — a feature branch is pushed and a draft PR opened via `gh` for early team visibility and review
- Proposal template now includes a Pull Request section recording the branch name, PR URL, and status
- Constitution standard tasks are split into pre-merge (executed automatically) and post-merge (manual reminders) categories

### Changed
- Post-apply workflow now executes constitution-defined pre-merge standard tasks after commit and push — post-merge tasks remain as unchecked reminders
- Graceful degradation when `gh` CLI is unavailable — branch is created but PR creation is skipped without blocking the pipeline

## 2026-03-25 — Constitution Template

### Changed
- Constitution section structure is now defined by a schema template instead of being hardcoded in the bootstrap skill — enables per-schema constitution variants and is consistent with the existing template system (closes #48)
- Bootstrap now uses the template as a flexible starting structure — sections can be added, omitted, or restructured to fit each project's needs

### Added
- Constitution template at `templates/constitution.md` in the schema directory with recommended sections (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks)

## 2026-03-25 — Fix Standard Tasks Commit Order

### Fixed
- Standard task checkboxes (archive, changelog, docs, commit) are now marked complete before the final commit — the committed tasks.md reflects the fully-checked state, eliminating the extra follow-up commit (closes #49)

## 2026-03-25 — Bootstrap Standard Tasks Section

### Changed
- Bootstrap now generates a `## Standard Tasks` section in the constitution during first run — new projects are immediately aware of the feature and know where to define project-specific post-implementation steps (closes #47)
- Constitution management spec updated to recognize Standard Tasks as a retained section alongside Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions

## 2026-03-24 — Visible Assumptions & REVIEW Auto-Resolution

### Changed
- Assumptions in specs are now always visible in Markdown preview — each assumption appears as a readable list item followed by a machine-parseable tag (closes #46)
- Preflight quality check now audits both assumption visibility and unresolved REVIEW markers — invisible assumptions and leftover REVIEW markers are flagged as blockers
- Bootstrap skill now actively resolves uncertain items during constitution generation — each `<!-- REVIEW -->` marker is presented to the user for confirmation and removed after the decision is documented
- Docs skill now actively resolves broken ADR references instead of leaving invisible markers — broken spec or archive links are fixed interactively with the user

### Added
- Assumption Marker Format requirement in the spec-format spec — defines the correct format and flags invisible assumptions as violations
- Review Marker Audit section in the preflight template — scans for unresolved `<!-- REVIEW -->` markers as a separate quality dimension
- REVIEW auto-resolution step in the bootstrap skill (Step 2b) — iterates markers, asks user, documents decisions, removes markers before proceeding

## 2026-03-24 — Standard Tasks

### Added
- Universal post-implementation steps (archive, changelog, docs, commit and push) are now included as trackable checkboxes in every generated task list — no more forgetting post-apply workflow steps (closes #12)
- Project-specific extras can be defined in the constitution's `## Standard Tasks` section and are appended after the universal steps
- Apply skill explicitly excludes standard tasks from implementation scope — they are tracked for auditability but executed separately after apply completes

### Changed
- Post-archive convention prose trimmed — "next steps" workflow replaced by the standard tasks section; auto-bump mechanism description preserved

## 2026-03-24 — Optimize Docs Regeneration

### Added
- `/opsx:docs` now accepts a comma-separated list of capability names (e.g., `/opsx:docs artifact-pipeline,artifact-generation`) — only the listed capabilities are regenerated, skipping the full archive date scan
- Multi-capability mode designed for the post-archive workflow where affected capabilities are already known, significantly reducing unnecessary archive scanning

### Changed
- Change detection in `/opsx:docs` now distinguishes three modes: no argument (full incremental scan), single capability (existing behavior), and multi-capability (new, skips date scan for unlisted capabilities)

## 2026-03-24 — Consolidation Guidance

### Added
- Capability granularity rules in proposal instructions — defines what constitutes a "capability" (cohesive behavior domain) vs. a "feature detail" (single behavior within an existing spec), with merge and minimum-scope heuristics (closes #45)
- Mandatory consolidation check before finalizing proposal capabilities — agents must verify overlap with existing specs, check pair-wise overlap between new capabilities, and confirm each capability has 3+ distinct requirements
- Consolidation Check section in the proposal template — makes the agent's consolidation reasoning visible and reviewable
- Overlap verification step in the specs creation instructions — catches any remaining overlap before spec files are created

### Changed
- `/opsx:continue` specs creation guideline now includes consolidation-awareness — verifies the proposal's Consolidation Check before creating spec files

## 2026-03-23 — Streamline ADR Format

### Changed
- ADR Decision section now includes rationale inline using the em-dash pattern — the separate Rationale section has been removed from the template (closes #24)
- ADR template formalized: both consolidated and single-decision ADRs use the same inline-rationale format
- Key Design Decisions table in the documentation README now sources all data directly from ADR files instead of archived design artifacts — ADRs are the single canonical source
- Language-aware ADR generation updated to 6 section headings (Rationale heading removed)

## 2026-03-23 — Smart Workflow Checkpoints

### Changed
- `/opsx:continue` now auto-continues through routine transitions (research→proposal→specs→design) without pausing — only stops at mandatory review checkpoints
- `/opsx:ff` now pauses on preflight PASS WITH WARNINGS and requires explicit user acknowledgment before generating tasks — warnings are no longer auto-accepted
- Post-apply workflow enforces verify-before-sync ordering — `/opsx:verify` must run before `/opsx:archive` to prevent baseline spec modification before validation

### Added
- Checkpoint model for workflow transitions classifying each step as auto-continue or mandatory-pause
- Mandatory-pause checkpoints: design review, preflight warnings, discovery Q&A
- Verify-before-sync guard in apply instruction

## 2026-03-23 — Fix Apply Baseline Edits

### Fixed
- Task generation no longer includes tasks that edit baseline specs (`openspec/specs/`) — spec changes now flow exclusively through delta specs and `/opsx:sync`
- Apply skill no longer modifies baseline spec files during implementation — a new guardrail prevents direct edits

### Added
- Baseline spec exclusion requirement in the task-implementation spec with formal Gherkin scenarios

## 2026-03-23 — Fix ADR Reference Quality

### Changed
- ADR References now contain only internal relative links (archive backlinks, spec links, ADR cross-references) — external URLs like GitHub issue links are no longer included, as the archive backlink provides traceability to issues via the archive's proposal.md
- ADR generation now validates all spec and archive links after writing — broken links to renamed or split specs are automatically replaced with successors

### Added
- Cross-reference heuristic for related ADRs — when an ADR modifies a system established by an earlier ADR, a back-reference is added automatically
- Reference validation catches broken spec links (e.g., renamed specs) and missing archive directories

## 2026-03-23 — Improve Docs Efficiency

### Changed
- `/opsx:docs` now runs incrementally by default — only capabilities with newer archives are regenerated, unchanged capabilities are skipped entirely (closes #22)
- ADR generation is now incremental — existing ADRs are preserved, only new archives produce new ADR files
- README is only regenerated when capability docs, ADRs, or constitution content actually changed
- Capability doc `lastUpdated` timestamps are no longer bumped when regeneration produces identical content (closes #42)
- Related decisions from the same archive are now consolidated into a single ADR with numbered sub-decisions instead of producing one ADR per table row (closes #44)

### Added
- ADR References now include a backlink to the source archive directory for traceability (closes #30)
- Constitution drift detection — README regenerates automatically when constitution content diverges from what's in the README
- Output summary now shows three categories: regenerated, skipped (unchanged content), and skipped (no newer archives)

## 2026-03-23 — Rename Init Skill to Setup

### Changed
- **BREAKING**: Project setup command renamed from `/opsx:init` to `/opsx:setup` — the previous name conflicted with Claude Code's built-in `/init` command and was unavailable to users (closes #31)
- All skill error messages, specs, and documentation now reference `/opsx:setup` instead of `/opsx:init`

## 2026-03-05 — Fix Docs Regeneration Quality

### Fixed
- ADR Context sections no longer lose depth when regenerated from scratch — Step 4 now independently reads full `design.md`, `research.md`, and `proposal.md` for each archive (closes #28)
- Capability docs no longer drop Known Limitations and Future Enhancements sections — "space-constrained" priority rule replaced with data-driven section inclusion (closes #29)

### Changed
- Each `/opsx:docs` step now reads its own source materials independently — no implicit dependencies between steps
- ADR generation explicitly reads archive Context, Architecture, and Risks sections for richer Consequences
- ADR References determined by checking each archive's `specs/` subdirectory for affected capabilities
- Behavior section depth now matches spec scenario count — distinct Gherkin scenario groups are not merged

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
