# Pre-Flight Check: PR Lifecycle Automation

## A. Traceability Matrix

### workflow-contract (Modified)

- [x] WORKFLOW.md Pipeline Orchestration (frontmatter/body split) → Scenarios: skill reads config, frontmatter fields, body sections, pipeline array → Design §1 (WORKFLOW.md Restructuring)
- [x] Smart Template Format (type: action) → Scenarios: action template fields, artifact template fields → Design §2 (Action Templates)
- [x] Skill Reading Pattern (body sections, sub-agents) → Scenarios: context from body, post-artifact from body, sub-agent execution, checkpoint/resume → Design §3 (ff Skill Extension)
- [x] Automation Configuration → Scenarios: automation config, CI reads config, optional section → Design §4 (CI Trigger)
- [x] Full Pipeline Execution (ff full pipeline) → Scenarios: full pipeline, human gates, auto-approve → Design §3 (ff Skill Extension)

### release-workflow (Modified)

- [x] Post-Approval CI Pipeline → Scenarios: pipeline runs, failure, HEAD divergence, concurrency, single approval guard → Design §4 (CI Trigger)

## B. Gap Analysis

1. **Stale `claude.yml` reference in release-workflow spec** — The Post-Approval CI Pipeline requirement text says "using the existing interactive Claude workflow (`.github/workflows/claude.yml`)" but the design specifies a new `pipeline.yml`. This is a leftover from an earlier iteration. **MUST fix in spec before implementation.**

2. **Design review checkpoint encoding** — The constitution mandates a design review checkpoint (pause after design for user alignment). The pipeline array `[..., design, preflight, ...]` doesn't encode pause points. How does ff know to pause after design but not after research? Currently ff has a checkpoint model for preflight (PASS/WARNINGS/BLOCKED). The design checkpoint needs to be preserved — either via the action template model or as ff-specific logic.

3. **Consumer migration path** — When consumers update to template-version 2, their WORKFLOW.md will have the old structure (apply.instruction in frontmatter, no body sections). The `apply.md` action template won't exist in their templates dir until they run `/opsx:setup`. The apply skill must handle the case where neither `apply.instruction` in WORKFLOW.md nor `apply.md` template exists gracefully.

4. **Action step `requires` chain vs skill behavior** — The design shows `verify.md` requires `[apply]`, but the verify skill finds its change via branch context detection (proposal frontmatter lookup), not via pipeline dependencies. The `requires` field for action templates defines execution order for ff, not input files. This distinction should be explicit in the action template instructions.

## C. Side-Effect Analysis

| Area | Impact | Risk |
|------|--------|------|
| All skills reading WORKFLOW.md | Reading pattern changes (frontmatter → body for context/post-artifact) | MEDIUM — skills must be updated: ff, apply, new (reads worktree config — stays in frontmatter, no change) |
| Consumer WORKFLOW.md templates | template-version bumps to 2, structure changes | LOW — `/opsx:setup` handles merge detection |
| Constitution "Template synchronization" convention | References `apply.instruction`, `post_artifact`, `context` — all being relocated | MEDIUM — convention text must be updated |
| Existing changes in flight | Changes started before this update will have old-format WORKFLOW.md | LOW — old format still works until skills are updated |

## D. Constitution Check

1. **Template synchronization convention** (Constitution line 42) says: "Changes to `openspec/WORKFLOW.md` behavior fields (`apply.instruction`, `post_artifact`, `context`) must also be reflected in `src/templates/workflow.md`." — This convention references fields being removed/relocated. **MUST update this convention** to reflect the new structure (frontmatter config fields + body sections).

2. **Skill immutability** — ff and apply SKILL.md modifications are plugin-level enhancements (action template support, body section reading), not project-specific behavior. Allowed per the immutability rule.

3. **Code style: YAML 2-space indentation** — Unchanged, no conflict.

4. **Three-layer architecture** — Preserved: CONSTITUTION.md (global rules) → WORKFLOW.md + Smart Templates (pipeline) → Skills (user commands). The restructuring adds a new template type (action) to the middle layer.

## E. Duplication & Consistency

1. **CRITICAL: release-workflow spec vs design contradiction** — Spec says `claude.yml`, design says `pipeline.yml`. Must align to `pipeline.yml` (new file) per the design decision.

2. **Automation config in two specs** — `automation.post_approval` is defined in workflow-contract (structure) and referenced in release-workflow (behavior). No duplication — workflow-contract defines the config format, release-workflow defines what the CI pipeline does with it. Clean separation.

3. **Action template instructions vs existing skill SKILL.md** — The `apply.md` template `instruction` will contain guidance currently in `apply.instruction`. The apply SKILL.md will read this instead of WORKFLOW.md. No duplication if the migration is clean — old source removed, new source added.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | Claude natively parses YAML frontmatter from markdown files | workflow-contract spec | Acceptable Risk — proven across all existing skills |
| 2 | `claude-code-action@v1` loads plugins from local marketplace paths (`'./'`) | design.md | Acceptable Risk — confirmed in source code, untested in this repo |
| 3 | The Agent tool supports spawning sub-agents within a skill's execution context | workflow-contract spec, design.md | Needs Clarification — skills are prose instructions executed by Claude which has the Agent tool, but it's unclear if Claude will use the Agent tool when instructed by a SKILL.md. May need a proof-of-concept. |
| 4 | Sub-agents can read/write files in the same working directory | workflow-contract spec | Acceptable Risk — Agent tool default behavior |
| 5 | `pull_request_review: submitted` fires reliably for required reviews | design.md | Acceptable Risk — standard GitHub Actions behavior |
| 6 | GitHub Actions can read WORKFLOW.md frontmatter via `claude-code-action` | workflow-contract spec | Acceptable Risk — file is in repo, checked out by action |

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifacts.

---

## Verdict: PASS WITH WARNINGS

**0 Blockers, 4 Warnings:**

| # | Type | Finding | Recommendation |
|---|------|---------|----------------|
| W1 | Spec inconsistency | release-workflow spec references `claude.yml` but design uses `pipeline.yml` | Fix spec text: replace "existing interactive Claude workflow (`.github/workflows/claude.yml`)" with "a dedicated workflow (`.github/workflows/pipeline.yml`)" |
| W2 | Constitution drift | Template synchronization convention references `apply.instruction`, `post_artifact`, `context` — all being relocated | Update convention text during implementation to reflect new structure |
| W3 | Assumption risk | Agent tool in skill context (assumption #3) is unverified | Consider a proof-of-concept during implementation: add a simple action template, run ff, check if sub-agent spawns correctly |
| W4 | Missing migration guard | Apply skill must handle missing `apply.md` template for consumers on old template-version | Add fallback in apply skill: if `apply.md` template not found, fall back to reading `apply.instruction` from WORKFLOW.md frontmatter |
