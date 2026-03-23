# Documentation

## System Architecture

The opsx-enhanced plugin uses a **three-layer architecture** where each layer has distinct responsibilities and can be modified independently:

1. **Constitution** (`openspec/constitution.md`) — Global project rules including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Read before every AI action via config.yaml workflow rules. Serves as the single authoritative source for project-wide rules.

2. **Schema** (`openspec/schemas/opsx-enhanced/`) — Defines the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks) with templates, instructions, and dependency ordering. Single source of truth for pipeline structure.

3. **Skills** (`skills/*/SKILL.md`) — 13 commands delivered as SKILL.md files within the Claude Code plugin system. Categorized as workflow (6: new, continue, ff, apply, verify, archive), governance (5: setup, bootstrap, discover, preflight, sync), and documentation (2: changelog, docs). All skills are model-invocable.

Layers are independently modifiable — the schema does not embed skill logic, skills depend on the schema via the OpenSpec CLI, and the constitution does not contain schema-specific artifact definitions.

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (schema.yaml, config.yaml)
- **Shell:** Bash (skill command execution)
- **Core dependency:** OpenSpec CLI (`@fission-ai/openspec@^1.2.0`)
- **Runtime:** Node.js + npm (required for OpenSpec CLI)
- **Platform:** Claude Code plugin system
- **Package manager:** npm (global installs only — no project-level package.json)

## Key Design Decisions

| Decision | Rationale | ADR |
|----------|-----------|-----|
| Organize 15 capabilities (not one per skill) | Groups related behavior logically; comprehensive coverage without maintenance burden of 1:1 skill mapping | [ADR-001](decisions/adr-001-initial-spec-organization.md) |
| Schema owns workflow rules; config reduced to bootstrap-only; remove constitution redundancies | Clear separation of concerns: schema for universal rules, constitution for project-specific rules, config for bootstrap pointers | [ADR-002](decisions/adr-002-workflow-rule-ownership.md) |
| Split docs-generation into user-docs, architecture-docs, decision-docs; all doc types in /opsx:docs | Each concern independently specifiable and testable; single entry point avoids skill proliferation | [ADR-003](decisions/adr-003-documentation-ecosystem.md) |
| Convention in constitution for release workflow; patch-only auto-bump on archive | Skills remain generic shared code; 95%+ of changes are patches; prevents forgotten version bumps | [ADR-004](decisions/adr-004-release-workflow.md) |
| Single docs_language field in config.yaml; translation at generation time | Central, backward-compatible; one set of templates for all languages; no template proliferation | [ADR-005](decisions/adr-005-configurable-documentation-language.md) |
| Design review checkpoint as constitution convention; checkpoint after design specifically | Respects skill immutability; design finalizes approach — last cheap feedback point before quality gates | [ADR-006](decisions/adr-006-design-review-checkpoint.md) |
| Replace priority rule with section-completeness rule; add enrichment reads to Step 4 | Positive guidance prevents section dropping; only Step 4 has the implicit dependency problem | [ADR-007](decisions/adr-007-fix-docs-regeneration-quality.md) |
| Manual ADRs use adr-MNNN naming; deterministic slug algorithm; fix specs AND SKILL.md together | M prefix distinguishes from generated ADRs; consistent filenames across runs; prevents drift between layers | [ADR-008](decisions/adr-008-fix-docs-skill-regressions.md) |
| SKILL.md references templates via Read at runtime; consolidated README replaces 3 separate files | Consistent with pipeline templates; eliminates navigation hops between index documents | [ADR-009](decisions/adr-009-improve-docs-output-quality.md) |
| Unified "Purpose" and "Rationale" headings; "read before write" guardrail; separate Future Enhancements | Standard terminology across all docs; prevents quality regression; distinct audiences for limitations vs. enhancements | [ADR-010](decisions/adr-010-improve-docs-sections.md) |
| Rename init skill to setup; use git mv for history preservation | Avoids built-in /init conflict; preserves git history; historical records left unchanged | [ADR-011](decisions/adr-011-rename-init-to-setup.md) |
| Stateless date comparison for incremental generation; agent-side ADR consolidation heuristics | No state file to maintain; reduces excessive ADR granularity while preserving detail | [ADR-012](decisions/adr-012-incremental-docs-generation.md) |
| All skills are model-invocable, including setup | disable-model-invocation: true makes skills undiscoverable; bootstrap needs setup | [ADR-M001](decisions/adr-M001-init-model-invocable.md) |

### Notable Trade-offs

- **15 capabilities (ADR-001)**: Significant number of specs to maintain, though each is focused and self-contained.
- **Schema owns workflow rules (ADR-002)**: Reduced defense-in-depth since rules live in one place instead of being duplicated; accepted because schema enforcement plus skill guardrails are sufficient.
- **Patch-only auto-bump (ADR-004)**: Version inflation with many small patches; no rollback mechanism for bad versions.
- **Convention-based enforcement (ADR-004, ADR-006)**: Soft enforcement relying on agent compliance, not hard code enforcement; mitigated by constitution being injected into every prompt.
- **Docs language translation quality (ADR-005)**: LLM translation quality varies by language; major languages work well, exotic languages may need review.
- **Consolidated README (ADR-009)**: Breaking external links to previous file locations; low impact since docs are internal.
- **Section-completeness rule (ADR-007)**: Agent may still drop sections despite rule change; mitigated by imperative language and per-section max limits.
- **Step independence is advisory (ADR-007)**: Guardrail is not structurally enforced; backed by explicit read instructions in affected steps.
- **"Read before write" is advisory (ADR-010)**: Agent compliance depends on well-written guidance; not hard-enforced.
- **Deterministic slug renames (ADR-008)**: Slug change causes ADR file renames for existing ADRs; all links regenerate to match.
- **Rename to setup (ADR-011)**: Breaking change for existing users who memorized /opsx:init; low impact since the old command was not working anyway.
- **Setup model-invocable (ADR-M001)**: Spec no longer distinguishes setup from other skills; would need revisiting if Claude Code adds user-only discoverable mode.
- **Incremental generation date comparison (ADR-012)**: Agent may misinterpret date comparison logic; worst case is unnecessary regeneration, which is a safe failure mode.
- **ADR consolidation heuristics (ADR-012)**: May misjudge grouping in edge cases; conservative rules minimize false consolidation.

## Conventions

- **Commits:** Imperative present tense with category prefix (e.g., `Refactor: ...`, `Fix: ...`)
- **Post-archive version bump:** After `/opsx:archive`, automatically increment patch version in `.claude-plugin/plugin.json` and sync `marketplace.json`. For minor/major releases, manually set versions, create a git tag, and push.
- **README accuracy:** When plugin behavior changes, update the README to reflect the new state.
- **Workflow friction:** Capture friction as GitHub Issues with the `friction` label.
- **Design review checkpoint:** After creating specs + design artifacts, always pause for user alignment before preflight/tasks.
- **No ADR references in specs:** Specs must not reference ADRs — ADRs are generated after archiving.

## Capabilities

### Setup

| Capability | Description |
|---|---|
| [Project Setup](capabilities/project-setup.md) | One-time project initialization with CLI install and schema setup |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Codebase scanning, constitution generation, and drift detection |

### Change Workflow

| Capability | Description |
|---|---|
| [Change Workspace](capabilities/change-workspace.md) | Create, manage, and archive change workspaces with date-prefixed naming |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | Schema-driven 6-stage pipeline with dependency gating |
| [Artifact Generation](capabilities/artifact-generation.md) | Step-by-step and fast-forward artifact generation commands |
| [Interactive Discovery](capabilities/interactive-discovery.md) | Standalone interactive research with targeted Q&A for complex features |

### Development

| Capability | Description |
|---|---|
| [Constitution Management](capabilities/constitution-management.md) | Constitution lifecycle management and global context enforcement |
| [Quality Gates](capabilities/quality-gates.md) | Pre-implementation checks and post-implementation verification |
| [Task Implementation](capabilities/task-implementation.md) | Sequential task execution with progress tracking and pause-on-blocker |
| [Human Approval Gate](capabilities/human-approval-gate.md) | QA loop with mandatory explicit human approval before archiving |

### Finalization

| Capability | Description |
|---|---|
| [Spec Sync](capabilities/spec-sync.md) | Agent-driven merging of delta specs into baseline specs |
| [Release Workflow](capabilities/release-workflow.md) | Version management, changelog generation, and consumer updates |

### Reference

| Capability | Description |
|---|---|
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Skills layers with independent modifiability |
| [Spec Format](capabilities/spec-format.md) | Format rules for specs with normative descriptions and Gherkin scenarios |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Planned improvements tracked as GitHub Issues with a roadmap label |

### Meta

| Capability | Description |
|---|---|
| [User Docs](capabilities/user-docs.md) | Enriched user-facing capability documentation generated by /opsx:docs |
| [Architecture Docs](capabilities/architecture-docs.md) | Cross-cutting architecture overview and documentation entry point |
| [Decision Docs](capabilities/decision-docs.md) | Architecture Decision Records generated from archived design decisions |
