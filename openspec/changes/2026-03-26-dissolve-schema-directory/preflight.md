# Pre-Flight Check: Dissolve Schema Directory

## A. Traceability Matrix

| Requirement | Scenarios | Components |
|-------------|-----------|------------|
| WORKFLOW.md Pipeline Orchestration | Skill reads WORKFLOW.md; Replaces schema+config; Contains required fields | openspec/WORKFLOW.md, all 12 skills |
| Smart Template Format | Contains frontmatter; Skill reads instruction; Body defines output; All templates use format | openspec/templates/*.md, skills/ff, skills/discover, skills/preflight |
| Template Variable Substitution | Resolves in active change; Unavailable → empty; Unknown → as-is | skills/ff (primary), all artifact-generating skills |
| Skill Reading Pattern | Resolves template path; Checks status via file existence | All 12 skills |
| Constitution Layer (modified) | Read before action; Contains required sections | openspec/CONSTITUTION.md, WORKFLOW.md context field |
| Schema Layer (modified) | WORKFLOW.md defines pipeline; Smart Templates have metadata; Apply gated | openspec/WORKFLOW.md, openspec/templates/ |
| Skills Layer (modified) | 12 skills present; All model-invocable | skills/ (12 directories) |
| Layer Separation (modified) | WORKFLOW.md change ≠ skill change; Constitution ≠ WORKFLOW.md; Skill ≠ constitution | All layers |
| Six-Stage Pipeline (modified) | Dependency order; No skipping; Verifiable artifacts | WORKFLOW.md pipeline[], Smart Templates requires[] |
| Artifact Dependencies (modified) | Check passes/fails; Template declares deps; Status from file existence | Smart Template frontmatter, skill logic |
| Apply Gate (modified) | Blocked without tasks; Proceeds after; Tracks progress | WORKFLOW.md apply{} |
| WORKFLOW.md Owns Pipeline Config | Contains orchestration fields | openspec/WORKFLOW.md |
| Post-Artifact Hook (modified) | Branch+PR; Subsequent push; Graceful degradation; Missing field | WORKFLOW.md post_artifact |
| Smart Templates Own Workflow Rules | DoD rule; Post-apply workflow; Standard tasks | openspec/templates/tasks.md, WORKFLOW.md apply.instruction |
| Capability Granularity (modified) | Guidance in proposal template | openspec/templates/proposal.md instruction |
| Consolidation Check (modified) | Present in proposal template | openspec/templates/proposal.md instruction |
| Specs Overlap (modified) | Present in specs template | openspec/templates/specs/spec.md instruction |
| Fast-Forward Generation (modified) | Full pipeline; Partial resume; Already complete; Dependency order; Design checkpoint; Preflight warnings; Change selection; New change creation | skills/ff/SKILL.md |
| Skill Delivery (modified) | Reads WORKFLOW.md+templates; Model-invocable | skills/ff/SKILL.md |
| Install OpenSpec Workflow (modified) | First-time; Idempotent; WORKFLOW.md generated | skills/setup/SKILL.md |
| Legacy Migration | Detected+migrated; Preserves content; Already migrated skipped | skills/setup/SKILL.md |
| Setup Validation (modified) | Success; Partial failure | skills/setup/SKILL.md |
| Config Bootstrap (removed) | N/A — replaced by WORKFLOW.md | openspec/config.yaml removed |
| Step-by-Step Generation (removed) | N/A — merged into ff | skills/continue/ removed |

All requirements traced to components.

## B. Gap Analysis

- **No gaps found.** All requirements have clear implementation targets.
- Edge cases covered: missing WORKFLOW.md, malformed YAML, legacy migration, branch conflicts, network failures, empty pipeline.
- Template variable substitution in code blocks: spec notes to leave as-is in fenced blocks — implementation should use simple line-by-line replacement outside fenced blocks, or accept that `{{ }}` in code blocks may be substituted (acceptable trade-off since code blocks rarely contain these exact tokens).

## C. Side-Effect Analysis

| Affected System | Risk | Mitigation |
|----------------|------|-----------|
| Consumer projects with old layout | **High** — breaking change | Migration logic in `/opsx:setup`; documented in setup skill |
| Active changes mid-pipeline | **Low** — change artifacts are in change directories, not affected by schema restructuring | Artifacts reference change-local files; pipeline status is file-existence based |
| Git history | **Low** — file moves lose history | Use `git mv` where possible for constitution rename |
| Archived changes | **None** — archives are read-only snapshots | No modification to archive structure |
| Docs ecosystem (docs/, ADRs) | **Low** — path references in generated docs | Will be regenerated post-archive via `/opsx:docs` |
| CI/CD workflows | **None** — no CI references to schema.yaml | Verified: `.github/workflows/` has no schema refs |

## D. Constitution Check

Constitution needs updating for this change:
- **Tech Stack**: `YAML (schema.yaml, config.yaml)` → `YAML (WORKFLOW.md frontmatter, Smart Template frontmatter)`
- **Architecture Rules**: `Three-layer architecture: Constitution → Schema → Skills` → `CONSTITUTION.md → WORKFLOW.md → Skills`
- **Architecture Rules**: `Schema source of truth: openspec/schemas/opsx-enhanced/` → `Pipeline source of truth: openspec/WORKFLOW.md + openspec/templates/`
- **Architecture Rules**: Remove `schema does not embed skill logic` → replace with `WORKFLOW.md and Smart Templates do not embed skill logic`
- **Conventions**: `README accuracy` rule still applies — README must be updated

## E. Duplication & Consistency

- **No contradictions found** between new specs and existing baseline specs.
- Specs that reference `schema.yaml` in their baseline (quality-gates, spec-format, task-implementation, etc.) are NOT modified by this change — they describe behaviors that don't depend on where the pipeline definition lives. The modified specs (artifact-pipeline, artifact-generation, three-layer-architecture, project-setup) are the only ones that reference the schema layer directly.
- `workflow-contract` spec and `artifact-pipeline` spec have intentional overlap in WORKFLOW.md field descriptions — artifact-pipeline describes the pipeline behavior, workflow-contract describes the file format. This is acceptable: different perspectives on the same artifact.

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| Claude YAML frontmatter parsing | workflow-contract spec, design.md | **Acceptable Risk** — Claude already parses YAML from schema.yaml; frontmatter is the same capability |
| Simple substitution sufficient | workflow-contract spec, design.md | **Acceptable Risk** — only 3 variables needed; full template engine deferred |
| Skill discovery mechanism | three-layer-architecture spec | **Acceptable Risk** — unchanged from current behavior; observed and verified |
| Context enforcement | three-layer-architecture spec | **Acceptable Risk** — same mechanism as current config.yaml context; just different file |
| File-existence-based completion | artifact-pipeline spec, artifact-generation spec | **Acceptable Risk** — unchanged from current behavior |
| Agent compliance sufficient | artifact-pipeline spec | **Acceptable Risk** — unchanged from current; template section provides reviewable artifact |
| gh CLI authentication | artifact-pipeline spec | **Acceptable Risk** — graceful degradation if unavailable |
| One-way migration acceptable | design.md | **Acceptable Risk** — old layout has no users who would need to revert; plugin itself migrates |

No Blocking or Needs Clarification assumptions.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifact files.

---

## Verdict: PASS

All requirements traced. No gaps. No contradictions. All assumptions acceptable risk. No review markers. Constitution changes identified and scoped. Side effects mitigated.
