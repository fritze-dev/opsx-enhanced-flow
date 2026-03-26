# Documentation

## System Architecture

The opsx-enhanced plugin uses a **three-layer architecture** where each layer has distinct responsibilities and can be modified independently:

1. **Constitution** (`openspec/CONSTITUTION.md`) — Global project rules including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Read before every AI action via WORKFLOW.md's `context` field. Serves as the single authoritative source for project-wide rules.

2. **WORKFLOW.md + Smart Templates** (`openspec/WORKFLOW.md` + `openspec/templates/`) — WORKFLOW.md declares the 6-stage artifact pipeline order, apply gate, post-artifact hook, and project context in YAML frontmatter. Smart Templates in `openspec/templates/` carry per-artifact instructions, output paths, and dependencies in YAML frontmatter alongside the output structure. Together they are the single source of truth for pipeline structure and artifact generation.

3. **Skills** (`skills/*/SKILL.md`) — 12 commands delivered as SKILL.md files within the Claude Code plugin system. Categorized as workflow (5: new, ff, apply, verify, archive), governance (5: setup, bootstrap, discover, preflight, sync), and documentation (2: changelog, docs). All skills are model-invocable.

Layers are independently modifiable — WORKFLOW.md and Smart Templates do not embed skill logic, skills depend on them by reading WORKFLOW.md and templates directly at runtime, and the constitution does not contain pipeline-specific artifact definitions.

## Tech Stack

- **Primary format:** Markdown (artifacts, specs, skills, documentation)
- **Configuration:** YAML (WORKFLOW.md frontmatter, Smart Template frontmatter)
- **Shell:** Bash (skill command execution)
- **Platform:** Claude Code plugin system
- **No external dependencies:** Skills read WORKFLOW.md and Smart Templates directly — no CLI tools, Node.js, or npm required

## Key Design Decisions

| Decision | Rationale | ADR |
|----------|-----------|-----|
| Organize 15 capabilities (not one per skill) | Groups related behavior logically; comprehensive coverage without 1:1 skill mapping burden | [ADR-001](decisions/adr-001-initial-spec-organization.md) |
| WORKFLOW.md + Smart Templates own workflow rules | Clear separation: WORKFLOW.md and templates for universal rules, constitution for project-specific rules | [ADR-002](decisions/adr-002-workflow-rule-ownership.md) |
| Split docs-generation into user-docs, architecture-docs, decision-docs | Each concern independently specifiable and testable; single entry point via /opsx:docs | [ADR-003](decisions/adr-003-documentation-ecosystem.md) |
| Convention in constitution for release workflow; patch-only auto-bump | Skills remain generic shared code; 95%+ of changes are patches; prevents forgotten bumps | [ADR-004](decisions/adr-004-release-workflow.md) |
| Single docs_language field in config.yaml; translation at generation time | Central, backward-compatible; one set of templates for all languages | [ADR-005](decisions/adr-005-configurable-documentation-language.md) |
| Design review checkpoint as constitution convention | Respects skill immutability; design is the last cheap feedback point before quality gates | [ADR-006](decisions/adr-006-design-review-checkpoint.md) |
| Replace priority rule with section-completeness rule; add enrichment reads | Positive guidance prevents section dropping; only Step 4 has the implicit dependency problem | [ADR-007](decisions/adr-007-fix-docs-regeneration-quality.md) |
| Manual ADRs use adr-MNNN naming; deterministic slug algorithm | M prefix distinguishes from generated ADRs; consistent filenames across runs | [ADR-008](decisions/adr-008-fix-docs-skill-regressions.md) |
| SKILL.md references templates via Read at runtime; consolidated README | Consistent with pipeline templates; eliminates navigation hops between index documents | [ADR-009](decisions/adr-009-improve-docs-output-quality.md) |
| Unified "Purpose" and "Rationale" headings; "read before write" guardrail | Standard terminology across all docs; prevents quality regression | [ADR-010](decisions/adr-010-improve-docs-sections.md) |
| Rename init skill to setup; use git mv for history preservation | Avoids built-in /init conflict; preserves git history | [ADR-011](decisions/adr-011-rename-init-to-setup.md) |
| Stateless date comparison for incremental generation; ADR consolidation heuristics | No state file to maintain; reduces excessive ADR granularity while preserving detail | [ADR-012](decisions/adr-012-incremental-docs-generation.md) |
| Internal-only ADR references; post-generation link validation via glob | Eliminates external URL maintenance; catches broken spec links automatically | [ADR-013](decisions/adr-013-fix-adr-reference-quality.md) |
| Exclude baseline specs from implementation scope; defense in depth | Single authoritative path for spec updates via delta spec and sync pipeline | [ADR-014](decisions/adr-014-fix-apply-baseline-edits.md) |
| Smart workflow checkpoints; auto-continue default with mandatory pauses | Reduces friction at routine transitions; increases rigor at critical decision points | [ADR-015](decisions/adr-015-smart-workflow-checkpoints.md) |
| Inline rationale in Decision section; ADR-sourced README table | Separate Rationale was always redundant; ADRs are the canonical source for decisions | [ADR-016](decisions/adr-016-streamline-adr-format.md) |
| Consolidation guidance via instruction + template + skill layers | Shift-left consolidation pressure prevents spec fragmentation; template section makes reasoning reviewable | [ADR-017](decisions/adr-017-consolidation-guidance.md) |
| Two-layer standard tasks: schema (universal) + constitution (extras) | Universal steps available to all projects; project-specific extras stay flexible; no CLI changes | [ADR-018](decisions/adr-018-standard-tasks-two-layer-design.md) |
| Visible assumptions with machine-parseable tags; REVIEW markers auto-resolved | Preserves preflight tag for auditing; transient markers should never persist in committed files | [ADR-019](decisions/adr-019-visible-assumptions-and-review-auto-resolution.md) |
| Bootstrap Standard Tasks section after Conventions with HTML comment | Logical grouping; bootstrap should not invent rules, only provide structure | [ADR-020](decisions/adr-020-bootstrap-standard-tasks-section-placement.md) |
| Constitution template extraction: schema-defined structure with flexible adaptation | Consistent with existing template system; single source of truth; enables per-schema variants | [ADR-021](decisions/adr-021-constitution-template-extraction.md) |
| Extend docs argument to accept multiple capability names | Simplest change; natural extension of existing single-capability mode | [ADR-022](decisions/adr-022-extend-argument-to-accept-multiple-capability-nam.md) |
| Only modify user-docs spec for multi-capability optimization | Docs skill is a thin wrapper; user-docs spec owns incremental generation logic | [ADR-023](decisions/adr-023-modified-capabilities-user-docs-only.md) |
| General rule for marking standard tasks before commit | Simpler, less prescriptive; agent decides timing; accurate because all steps completed by commit time | [ADR-024](decisions/adr-024-general-rule-ensure-all-checked-before-commit-rat.md) |
| Add mark-before-commit directive to apply.instruction only | Apply instruction owns the post-apply workflow; no other location needed | [ADR-025](decisions/adr-025-add-directive-to-apply-instruction-only.md) |
| ~~Inline PR integration in proposal step~~ | ~~Superseded by ADR-028~~ | [ADR-026](decisions/adr-026-inline-pr-integration-in-proposal-step.md) |
| Post-artifact commit and PR integration | Schema-level `post_artifact` hook commits after every artifact; branch+PR on first commit; avoids orphaned PRs | [ADR-028](decisions/adr-028-post-artifact-commit-and-pr-integration.md) |
| All skills are model-invocable, including setup | disable-model-invocation: true makes skills undiscoverable; bootstrap needs setup | [ADR-M001](decisions/adr-M001-init-model-invocable.md) |
| Remove CLI dependency; skills read schema.yaml directly | Zero external dependencies; Claude natively parses YAML; simpler than CLI subprocess | [ADR-027](decisions/adr-027-remove-cli-dependency.md) |
| Dissolve schema directory; WORKFLOW.md + Smart Templates | Clean separation of orchestration and artifact definition; self-describing templates; one-way migration | [ADR-029](decisions/adr-029-dissolve-schema-directory.md) |
| Verify preflight side-effect cross-check as step 8 with WARNING severity | Additive safety net; consistent with heuristic philosophy; two-pass matching (tasks then codebase) | [ADR-030](decisions/adr-030-verify-preflight-side-effect-cross-check.md) |
| Plugin source in `src/`, auto GitHub Releases via CI, local marketplace for dev | Clean consumer cache; automated releases; VS Code-compatible dev workflow | [ADR-031](decisions/adr-031-auto-github-releases-and-plugin-source-restr.md) |

### Notable Trade-offs

- **15 capabilities (ADR-001)**: Significant number of specs to maintain, though each is focused and self-contained.
- **Schema owns workflow rules (ADR-002)**: Reduced defense-in-depth since rules live in one place instead of being duplicated; accepted because schema enforcement plus skill guardrails are sufficient.
- **Patch-only auto-bump (ADR-004)**: Version inflation with many small patches; no rollback mechanism for bad versions.
- **Convention-based enforcement (ADR-004, ADR-006)**: Soft enforcement relying on agent compliance, not hard code enforcement; mitigated by constitution being injected into every prompt.
- **Docs language translation quality (ADR-005)**: LLM translation quality varies by language; major languages work well, exotic languages may need review.
- **Section-completeness rule (ADR-007)**: Agent may still drop sections despite rule change; mitigated by imperative language and per-section max limits.
- **Step independence is advisory (ADR-007)**: Guardrail is not structurally enforced; backed by explicit read instructions in affected steps.
- **Deterministic slug renames (ADR-008)**: Slug change causes ADR file renames for existing ADRs; all links regenerate to match.
- **Consolidated README (ADR-009)**: Breaking external links to previous file locations; low impact since docs are internal.
- **"Read before write" is advisory (ADR-010)**: Agent compliance depends on well-written guidance; not hard-enforced.
- **Rename to setup (ADR-011)**: Breaking change for existing users who memorized /opsx:init; low impact since the old command was not working anyway.
- **Incremental generation date comparison (ADR-012)**: Agent may misinterpret date comparison logic; worst case is unnecessary regeneration, which is a safe failure mode.
- **ADR consolidation heuristics (ADR-012)**: May misjudge grouping in edge cases; conservative rules minimize false consolidation.
- **Internal-only ADR references (ADR-013)**: Less direct traceability to GitHub issues; readers must follow archive backlink then read proposal.md to find issue references.
- **Cross-reference heuristic (ADR-013)**: May miss some relationships when connections are not explicit in archive content; manual review can supplement.
- **Baseline spec exclusion is text-based (ADR-014)**: AI agents may still ignore text-based instructions; no hard runtime enforcement exists.
- **Three files for one rule (ADR-014)**: Schema instruction, apply guardrail, and spec all express the same rule; small additive text edits.
- **Auto-continue surprises (ADR-015)**: Users accustomed to per-artifact pauses may be surprised by auto-continue behavior.
- **Checkpoint enforcement is advisory (ADR-015)**: Text-based instructions in skills have no hard runtime enforcement; agents may still deviate.
- **Inline rationale extraction (ADR-016)**: README table requires agent to parse the em-dash pattern from ADR Decision sections; for consolidated ADRs, agent summarizes the overarching decision.
- **Consolidation guidance is instruction-based (ADR-017)**: Agent compliance not programmatically enforced; mitigated by Consolidation Check template section creating a visible, reviewable artifact. Over-consolidation possible with heuristics; mitigated by upper-bound guidance.
- **Standard tasks soft enforcement (ADR-018)**: Apply instruction tells agent to skip standard tasks, but no hard gate. Consistent with all other enforcement in the system. Progress counts include standard tasks, showing e.g. "5/9 complete" after apply.
- **Inline assumptions moved to Assumptions section (ADR-019)**: Assumptions formerly inline within requirements lose proximity to their context; trades locality for centralized auditability.
- **REVIEW auto-resolution adds prompts (ADR-019)**: Bootstrap and docs skill runs may be slower due to interactive user prompts for uncertain items and broken references.
- **Multi-capability argument requires caller knowledge (ADR-022)**: Caller must know which capabilities were affected; no automatic detection from archive data.
- **Mark-before-commit partial failure (ADR-024)**: If a post-apply step fails before commit, the agent must be careful to only mark completed steps; relies on natural agent behavior.
- **More commits per change (ADR-028)**: One commit per artifact instead of one bulk commit at proposal; intentional trade-off for better git traceability.
- **Minimal initial PR body (ADR-028)**: Draft PR body is just "WIP: <name>" until the constitution standard task enriches it post-apply; teams must follow the branch for artifact content.
- **gh CLI dependency for full PR functionality (ADR-028)**: Environments without `gh` CLI get degraded experience (branch created but no PR).
- **Free-form Section C parsing (ADR-030)**: Preflight side-effect analysis uses free-form markdown; parsing is inherently fragile. Generic side-effect descriptions are marked inconclusive rather than producing false warnings.
- **Setup model-invocable (ADR-M001)**: Spec no longer distinguishes setup from other skills; would need revisiting if Claude Code adds user-only discoverable mode.
- **CLI removal (ADR-027)**: Skills are slightly more verbose with file-read instructions; no programmatic schema validation — mitigated by version-controlled schema and runtime read errors.

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
| [Project Setup](capabilities/project-setup.md) | One-time project initialization with WORKFLOW.md generation, Smart Template installation, and legacy migration |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Codebase scanning, constitution generation, and drift detection |

### Change Workflow

| Capability | Description |
|---|---|
| [Change Workspace](capabilities/change-workspace.md) | Create, manage, and archive change workspaces with date-prefixed naming |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | 6-stage pipeline driven by WORKFLOW.md and Smart Templates with dependency gating and PR integration |
| [Artifact Generation](capabilities/artifact-generation.md) | Fast-forward generation with smart checkpoints and change selection |
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
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | CONSTITUTION.md, WORKFLOW.md + Smart Templates, and Skills layers with independent modifiability |
| [Workflow Contract](capabilities/workflow-contract.md) | WORKFLOW.md pipeline orchestration format, Smart Template format, and skill reading pattern |
| [Spec Format](capabilities/spec-format.md) | Format rules for specs with normative descriptions and Gherkin scenarios |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Planned improvements tracked as GitHub Issues with a roadmap label |

### Meta

| Capability | Description |
|---|---|
| [User Docs](capabilities/user-docs.md) | Enriched user-facing capability documentation generated by /opsx:docs |
| [Architecture Docs](capabilities/architecture-docs.md) | Cross-cutting architecture overview and documentation entry point |
| [Decision Docs](capabilities/decision-docs.md) | Architecture Decision Records generated from archived design decisions |
