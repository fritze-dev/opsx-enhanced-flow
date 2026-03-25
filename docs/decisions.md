# Design Decisions

| Decision | Rationale | ADR |
|----------|-----------|-----|
| Organize 15 capabilities (not one per skill) | Groups related behavior logically; comprehensive coverage without 1:1 skill mapping burden | [ADR-001](decisions/adr-001-initial-spec-organization.md) |
| Schema owns workflow rules; config reduced to bootstrap-only | Clear separation: schema for universal rules, constitution for project-specific rules | [ADR-002](decisions/adr-002-workflow-rule-ownership.md) |
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
| Inline PR integration in proposal step | Preserves 6-stage pipeline; draft PR provides early visibility; graceful degradation for non-GitHub environments | [ADR-026](decisions/adr-026-inline-pr-integration-in-proposal-step.md) |
| Split README into hub + architecture.md + decisions.md; discover reads decisions index | Decisions table grows with every change; per-file regeneration avoids unnecessary rewrites; decisions.md serves as lightweight ADR index for discover | [ADR-027](decisions/adr-027-split-readme-into-hub-architecture-md-dec.md) |
| All skills are model-invocable, including setup | disable-model-invocation: true makes skills undiscoverable; bootstrap needs setup | [ADR-M001](decisions/adr-M001-init-model-invocable.md) |

## Notable Trade-offs

- **15 capabilities (ADR-001)**: Significant number of specs to maintain, though each is focused and self-contained.
- **Schema owns workflow rules (ADR-002)**: Reduced defense-in-depth since rules live in one place instead of being duplicated; accepted because schema enforcement plus skill guardrails are sufficient.
- **Patch-only auto-bump (ADR-004)**: Version inflation with many small patches; no rollback mechanism for bad versions.
- **Convention-based enforcement (ADR-004, ADR-006)**: Soft enforcement relying on agent compliance, not hard code enforcement; mitigated by constitution being injected into every prompt.
- **Docs language translation quality (ADR-005)**: LLM translation quality varies by language; major languages work well, exotic languages may need review.
- **Section-completeness rule (ADR-007)**: Agent may still drop sections despite rule change; mitigated by imperative language and per-section max limits.
- **Step independence is advisory (ADR-007)**: Guardrail is not structurally enforced; backed by explicit read instructions in affected steps.
- **Deterministic slug renames (ADR-008)**: Slug change causes ADR file renames for existing ADRs; all links regenerate to match.
- **Consolidated README superseded (ADR-009 → ADR-027)**: ADR-009's single-file design replaced by hub + architecture.md + decisions.md; better separation of concerns at the cost of multiple files.
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
- **Inline rationale extraction (ADR-016)**: Decisions index table requires agent to parse the em-dash pattern from ADR Decision sections; for consolidated ADRs, agent summarizes the overarching decision.
- **Consolidation guidance is instruction-based (ADR-017)**: Agent compliance not programmatically enforced; mitigated by Consolidation Check template section creating a visible, reviewable artifact. Over-consolidation possible with heuristics; mitigated by upper-bound guidance.
- **Standard tasks soft enforcement (ADR-018)**: Apply instruction tells agent to skip standard tasks, but no hard gate. Consistent with all other enforcement in the system. Progress counts include standard tasks, showing e.g. "5/9 complete" after apply.
- **Inline assumptions moved to Assumptions section (ADR-019)**: Assumptions formerly inline within requirements lose proximity to their context; trades locality for centralized auditability.
- **REVIEW auto-resolution adds prompts (ADR-019)**: Bootstrap and docs skill runs may be slower due to interactive user prompts for uncertain items and broken references.
- **Multi-capability argument requires caller knowledge (ADR-022)**: Caller must know which capabilities were affected; no automatic detection from archive data.
- **Mark-before-commit partial failure (ADR-024)**: If a post-apply step fails before commit, the agent must be careful to only mark completed steps; relies on natural agent behavior.
- **PR creation is a side effect of proposal (ADR-026)**: Not independently trackable as a pipeline artifact; side effect rather than first-class pipeline stage.
- **Constitution extras auto-execution (ADR-026)**: Existing constitution extras that were previously manual-only are now auto-executed during post-apply; behavior change for existing projects.
- **gh CLI dependency for full PR functionality (ADR-026)**: Environments without `gh` CLI get degraded experience (branch created but no PR).
- **Reverses ADR-009 (ADR-027)**: The established "single entry point" design is superseded; new hub structure provides better separation but adds files.
- **Keyword-based ADR relevance in discover (ADR-027)**: May miss some relevant ADRs or include irrelevant ones; false negatives mean same as today, false positives are low-cost.
- **Setup model-invocable (ADR-M001)**: Spec no longer distinguishes setup from other skills; would need revisiting if Claude Code adds user-only discoverable mode.
