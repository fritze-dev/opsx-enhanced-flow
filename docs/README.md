# Documentation

## System Architecture

The opsx-enhanced plugin uses a **three-layer architecture** where each layer has distinct responsibilities and can be modified independently:

1. **Constitution** (`openspec/constitution.md`) — Global project rules including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Read before every AI action via config.yaml workflow rules. Serves as the single authoritative source for project-wide rules.

2. **Schema** (`openspec/schemas/opsx-enhanced/`) — Defines the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks) with templates, instructions, and dependency ordering. Single source of truth for pipeline structure.

3. **Skills** (`skills/*/SKILL.md`) — 13 commands delivered as SKILL.md files within the Claude Code plugin system. Categorized as workflow (6: new, continue, ff, apply, verify, archive), governance (5: init, bootstrap, discover, preflight, sync), and documentation (2: changelog, docs). All skills are model-invocable.

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
| 15 capabilities (not one per skill) | Groups related behavior logically; comprehensive coverage without gaps | [ADR-001](decisions/adr-001-15-capabilities-not-one-per-skill.md) |
| Use `/opsx:sync` for baseline creation | Programmatic merge has format limitations; agent-driven sync handles edge cases | [ADR-002](decisions/adr-002-use-opsx-sync-for-baseline-creation-not-progra.md) |
| Empty tasks.md (QA loop only) | No code to implement — documentation bootstrap | [ADR-003](decisions/adr-003-empty-tasks-md-qa-loop-only.md) |
| Schema owns workflow rules | DoD and post-apply sequence apply to all projects using opsx-enhanced | [ADR-004](decisions/adr-004-schema-owns-workflow-rules.md) |
| Config as bootstrap-only | With rules in schema and project rules in constitution, config just needs pointers | [ADR-005](decisions/adr-005-config-as-bootstrap-only.md) |
| Remove constitution redundancies | Single source of truth prevents drift and reduces noise | [ADR-006](decisions/adr-006-remove-constitution-redundancies.md) |
| Init generates minimal config template | Prevents project-specific rules from leaking into consumer projects | [ADR-007](decisions/adr-007-init-generates-minimal-config-template.md) |
| Convention in constitution, not skill modification | Skills are shared; project-specific behavior belongs in constitution | [ADR-008](decisions/adr-008-convention-in-constitution-not-skill-modification.md) |
| Patch-only auto-bump | 95%+ of changes are patches; minor/major are rare and intentional | [ADR-009](decisions/adr-009-patch-only-auto-bump.md) |
| Sync marketplace.json in same convention | One operation prevents version drift between files | [ADR-010](decisions/adr-010-sync-marketplace-json-in-same-convention.md) |
| Docs page for minor/major releases | Rare enough for a documented manual process | [ADR-011](decisions/adr-011-docs-page-for-minor-major.md) |
| Split docs-generation into user-docs, architecture-docs, decision-docs | Each concern independently spec'd and testable | [ADR-012](decisions/adr-012-split-docs-generation-into-user-docs-architectu.md) |
| All doc types in `/opsx:docs`, no new skills | Single entry point avoids skill proliferation | [ADR-013](decisions/adr-013-all-doc-types-in-opsx-docs-no-new-skills.md) |
| Direct glob per capability instead of pre-built index | Simpler, no separate step needed, archives are few | [ADR-014](decisions/adr-014-direct-glob-per-capability-instead-of-pre-built-in.md) |
| ADRs fully regenerated each run | Deterministic, no state to track, numbering always consistent | [ADR-015](decisions/adr-015-adrs-fully-regenerated-each-run.md) |
| Research context integrated into ADR Context | One place for "why did we decide this?" | [ADR-016](decisions/adr-016-research-context-integrated-into-adr-context-secti.md) |
| "Why This Exists" uses newest archive's proposal | Most current motivation is most relevant | [ADR-017](decisions/adr-017-why-this-exists-uses-newest-archive-s-proposal.md) |
| initial-spec-only capabilities use spec Purpose | Bootstrap proposal "Why" is about spec creation, not capabilities | [ADR-018](decisions/adr-018-initial-spec-only-capabilities-use-spec-purpose.md) |
| Design review checkpoint as constitution convention | Respects skill immutability; constitution is always loaded | [ADR-019](decisions/adr-019-constitution-convention-only.md) |
| Checkpoint after design specifically | Design finalizes approach — last cheap feedback point | [ADR-020](decisions/adr-020-checkpoint-after-design-specifically.md) |
| Skip checkpoint when preflight already done | Avoids unnecessary friction on resume | [ADR-021](decisions/adr-021-skip-checkpoint-when-preflight-already-done.md) |
| Update constitution before spec | Constitution establishes governance rule backing the spec | [ADR-022](decisions/adr-022-update-constitution-before-spec.md) |
| SKILL.md references templates via Read at runtime | Consistent with pipeline templates; format changes don't require prompt edits | [ADR-023](decisions/adr-023-skill-md-references-templates-via-read-at-runtime.md) |
| Consolidated README replaces 3 separate files | Eliminates navigation hops; architecture overview IS the entry point | [ADR-024](decisions/adr-024-consolidated-readme-replaces-3-separate-files.md) |
| Cleanup step deletes stale files | Automated migration from old 3-file to new 1-file structure | [ADR-025](decisions/adr-025-cleanup-step-in-skill-md-deletes-stale-files.md) |
| ADR generation runs before README generation | README needs ADR file paths for inline links | [ADR-026](decisions/adr-026-adr-generation-runs-before-readme-generation.md) |
| Ordering/grouping via order and category frontmatter | Project-specific, deterministic, set during spec creation | [ADR-027](decisions/adr-027-ordering-grouping-via-order-and-category-yaml-fron.md) |
| README shortening is a separate task | Allows independent review of subjective content decisions | [ADR-028](decisions/adr-028-readme-shortening-is-a-separate-implementation-tas.md) |
| Unified "Purpose" heading for all docs | Standard, unambiguous term across all capability docs | [ADR-029](decisions/adr-029-unified-purpose-heading-for-all-docs.md) |
| Unified "Rationale" heading for all docs | Standard ADR terminology; covers all design reasoning | [ADR-030](decisions/adr-030-unified-rationale-heading-for-all-docs.md) |
| Separate Future Enhancements from Known Limitations | Different audiences: constraints vs. actionable future ideas | [ADR-031](decisions/adr-031-separate-future-enhancements-from-known-limitation.md) |
| "Read before write" guardrail in SKILL.md | Prevents quality regression by preserving existing doc quality | [ADR-032](decisions/adr-032-read-before-write-guardrail-in-skill-md.md) |
| Manual doc fixes + deferred regeneration | Safer: preserves established quality, validates guardrails separately | [ADR-033](decisions/adr-033-manual-doc-fixes-deferred-regeneration.md) |
| Single docs_language field in config.yaml | Central, backward-compatible, all skills already read config | [ADR-034](decisions/adr-034-single-docs-language-field-in-config-yaml.md) |
| Commented-out field in init template | Users discover the feature without it being active by default | [ADR-035](decisions/adr-035-commented-out-field-in-init-template-for-discovera.md) |
| English enforcement via config context field | Single enforcement point passed to all skills automatically | [ADR-036](decisions/adr-036-english-enforcement-via-config-context-field.md) |
| Translation at generation time, not in templates | One set of templates for all languages; no proliferation | [ADR-037](decisions/adr-037-translation-at-generation-time-not-in-templates.md) |
| Manual ADRs use adr-MNNN naming in same directory | M prefix distinguishes from generated ADRs; single glob location | [ADR-038](decisions/adr-038-manual-adrs-use-adr-mnnn-slug-md-naming-in-docs-de.md) |
| Deterministic slug: replace non-[a-z0-9] with hyphen | Handles all special chars uniformly; consistent across runs | [ADR-039](decisions/adr-039-deterministic-slug-replace-non-a-z0-9-with-hyphen.md) |
| Fix both specs AND SKILL.md/templates | Both must agree to prevent future drift | [ADR-040](decisions/adr-040-fix-both-specs-and-skill-md-templates.md) |
| Replace priority rule with section-completeness rule | Positive guidance prevents section dropping; per-section limits remain | [ADR-041](decisions/adr-041-replace-priority-rule-with-section-completeness-ru.md) |
| Add enrichment reads only to Step 4 | Only Step 4 has the implicit dependency problem | [ADR-042](decisions/adr-042-add-enrichment-reads-only-to-step-4-not-all-steps.md) |
| Step independence as guardrail, not structural change | Simpler; matches existing SKILL.md structure | [ADR-043](decisions/adr-043-add-step-independence-as-a-guardrail-not-a-structu.md) |
| Reinforce specs with step independence language | Prevents future drift between spec and skill | [ADR-044](decisions/adr-044-reinforce-specs-with-step-independence-language.md) |
| All skills are model-invocable, including init | `disable-model-invocation: true` makes skills undiscoverable; bootstrap needs init | [ADR-M001](decisions/adr-M001-init-model-invocable.md) |

### Notable Trade-offs

- **15 capabilities (ADR-001)**: Significant number of specs to maintain, though each is focused and self-contained.
- **Schema owns workflow rules (ADR-004)**: Reduced defense-in-depth since rules live in one place instead of being duplicated; accepted because schema enforcement plus skill guardrails are sufficient.
- **Patch-only auto-bump (ADR-009)**: Version inflation with many small patches; no rollback mechanism for bad versions.
- **All doc types in /opsx:docs (ADR-013)**: Longer skill prompt with more complex step sequence; mitigated by clear section headers.
- **Convention in constitution (ADR-008, ADR-019)**: Soft enforcement relying on agent compliance, not hard code enforcement; mitigated by constitution being injected into every prompt.
- **Consolidated README (ADR-024)**: Breaking external links to previous file locations; low impact since docs are internal.
- **docs_language translation quality (ADR-034)**: LLM translation quality varies by language; major languages work well, exotic languages may need review.
- **Deterministic slug renames (ADR-039)**: Slug change causes ADR file renames for existing ADRs; all links regenerate to match.
- **Section-completeness rule (ADR-041)**: Agent may still drop sections despite rule change; mitigated by imperative language and per-section max limits.
- **Step independence is advisory (ADR-042, ADR-043)**: Guardrail is not structurally enforced; backed by explicit read instructions in affected steps.
- **"Read before write" is advisory (ADR-032)**: Agent compliance depends on well-written guidance; not hard-enforced.
- **Init model-invocable (ADR-M001)**: Spec no longer distinguishes init from other skills; would need revisiting if Claude Code adds user-only discoverable mode.

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
| [Project Setup](capabilities/project-setup.md) | One-time project initialization via /opsx:init with CLI install and schema setup. |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Initial codebase scanning, constitution generation, and drift detection. |

### Change Workflow

| Capability | Description |
|---|---|
| [Change Workspace](capabilities/change-workspace.md) | Create, manage, and archive change workspaces with date-prefixed naming. |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | Schema-driven 6-stage artifact pipeline with dependency gating. |
| [Artifact Generation](capabilities/artifact-generation.md) | Step-by-step and fast-forward commands for generating pipeline artifacts. |
| [Interactive Discovery](capabilities/interactive-discovery.md) | Standalone interactive research with targeted Q&A for complex features. |

### Development

| Capability | Description |
|---|---|
| [Constitution Management](capabilities/constitution-management.md) | Manages the project constitution lifecycle and global context enforcement. |
| [Quality Gates](capabilities/quality-gates.md) | Pre-implementation quality checks and post-implementation verification. |
| [Task Implementation](capabilities/task-implementation.md) | Working through task checklists with sequential implementation and progress tracking. |
| [Human Approval Gate](capabilities/human-approval-gate.md) | QA loop with mandatory explicit human approval before archiving. |

### Finalization

| Capability | Description |
|---|---|
| [Spec Sync](capabilities/spec-sync.md) | Agent-driven merging of delta specs into baseline specs. |
| [Release Workflow](capabilities/release-workflow.md) | Version management, changelog generation, and consumer update process. |

### Reference

| Capability | Description |
|---|---|
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Skills layers with independent modifiability. |
| [Spec Format](capabilities/spec-format.md) | Format rules for specifications including normative descriptions and Gherkin scenarios. |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Tracks planned improvements as GitHub Issues with a roadmap label. |

### Meta

| Capability | Description |
|---|---|
| [User Docs](capabilities/user-docs.md) | Enriched user-facing capability documentation generated by /opsx:docs. |
| [Architecture Docs](capabilities/architecture-docs.md) | Cross-cutting architecture overview and documentation entry point. |
| [Decision Docs](capabilities/decision-docs.md) | Architecture Decision Records generated from archived design decisions. |
