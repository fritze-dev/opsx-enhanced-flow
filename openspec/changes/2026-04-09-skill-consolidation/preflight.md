# Pre-Flight Check: Skill Consolidation

## A. Traceability Matrix

- [x] Router dispatch pattern → Scenarios: intent recognition, change detection, propose dispatch, apply dispatch, init dispatch → Design: Router section
- [x] Inline action definitions → Scenarios: action with specs+instruction, sub-agent execution, actions not in pipeline → Design: WORKFLOW.md Structure
- [x] review.md artifact → Scenarios: template fields, verdict gate, apply generates review → Design: review.md Template
- [x] Propose as single entry point → Scenarios: workspace creation, artifact status, existing change selection → Design: Router section
- [x] Spec merges (project-init, documentation, artifact-pipeline absorbs artifact-generation) → Design: Spec Merges section
- [x] Auto-approve config → Scenarios: WORKFLOW.md contains auto_approve → Design: Auto-Approve Config
- [x] CI pipeline → Scenarios: automation config, post-approval trigger → Design: GitHub Actions Pipeline
- [x] Plugin registration → Scenarios: 4 stub SKILL.md + shared router.md → Design: Plugin Registration

## B. Gap Analysis

- **review.md re-generation**: If user manually edits code after review.md PASS, review is stale. Covered in design: "apply deletes review.md at start, regenerates at end."
- **Finalize without review.md**: What if user runs `/opsx:finalize` before review.md exists? → Action instruction should check review.md existence and verdict before proceeding. Not explicitly in specs — **minor gap**, add to finalize action instruction.
- **Init modes**: Init needs to detect fresh install vs update vs health-check. Covered in project-init spec with mode detection requirement.
- **Stub include mechanism**: Design assumes SKILL.md can reference router.md via "Read and follow". If plugin system doesn't support this, fallback is inlining router in each stub. Covered in design risks.

## C. Side-Effect Analysis

| Area | Risk | Assessment |
|------|------|-----------|
| Consumer WORKFLOW.md migration | template-version 1→3 breaking change | LOW — `/opsx:init` handles migration, template-version field enables detection |
| Existing change directories | Changes in progress use old command references in tasks.md | LOW — tasks.md contains checkbox text, not command invocations. Apply reads WORKFLOW.md dynamically |
| Plugin marketplace.json | Command names change | LOW — marketplace.json points to `src/` source dir, plugin.json has version bump |
| docs/ generated content | Docs reference old spec names (user-docs, architecture-docs, etc.) | MEDIUM — `/opsx:finalize` will regenerate docs from new spec names. But stale references may exist until finalize runs |
| README.md | References old commands and 18 specs | MEDIUM — Must be updated as part of this change |

## D. Constitution Check

- Constitution references "Three-layer architecture" with Skills as Layer 3 → **Must update** to "Router + Actions"
- Constitution references "Skill immutability" rule → **Must update** — concept still applies but vocabulary changes (skills → router)
- Constitution references `/opsx:setup` → **Must update** to `/opsx:init`

## E. Duplication & Consistency

- `quality-gates` spec still has some verify/docs-verify language that may overlap with new `project-init` (docs-verify health check) and `review.md` template. Verify these are consistent.
- `artifact-pipeline` now contains propose behavior (from absorbed artifact-generation). Check that `workflow-contract` router dispatch requirement doesn't duplicate propose behavior.
- `human-approval-gate` references to QA loop should align with `task-implementation` QA loop changes.

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| Cross-file skill include (router.md) | design.md | Acceptable Risk — fallback documented (inline router in stubs) |
| Sub-agent context capacity | design.md | Acceptable Risk — instruction + specs + artifacts is less context than current full-conversation approach |
| 4-command sufficiency | design.md | Acceptable Risk — covers all identified workflows. Standalone preflight/verify available via propose re-run |
| Claude YAML frontmatter parsing | workflow-contract spec | Acceptable Risk — proven in practice across 49 changes |
| Agent tool availability | workflow-contract spec | Acceptable Risk — standard Claude Code tool |
| Sub-agent file access | workflow-contract spec | Acceptable Risk — sub-agents share working directory |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifact.

---

**Verdict: PASS**

All traceability checks pass. Two minor gaps identified (finalize review.md check, docs stale references) — both addressable during implementation. No blocking assumptions. No review markers.
