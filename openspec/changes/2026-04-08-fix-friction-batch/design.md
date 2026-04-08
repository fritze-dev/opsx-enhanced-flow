# Technical Design: Fix Friction Batch (#81, #86, #87, #88)

## Context

Four friction issues from real workflow sessions need instruction-level fixes. No code changes — all fixes are text updates to WORKFLOW.md, SKILL.md, CONSTITUTION.md, and specs. The project uses convention-based enforcement (agent reads instructions and follows them), so the quality of instruction text directly determines agent behavior.

## Architecture & Components

| File | Change | Friction |
|------|--------|----------|
| `openspec/WORKFLOW.md` → `apply.instruction` | Add automated-step and post-merge cleanup guidance | #81, #88 |
| `src/templates/workflow.md` → `apply.instruction` | Mirror the same changes (dual-update) | #81, #88 |
| `src/skills/verify/SKILL.md` | Add auto-fix guidance for mechanically fixable WARNINGs | #86 |
| `openspec/CONSTITUTION.md` | Add "Template synchronization" convention | #87 |
| `src/templates/constitution.md` | Mirror new convention if template has conventions section | #87 |
| `openspec/specs/task-implementation/spec.md` | Already updated in specs stage | #81 |
| `openspec/specs/quality-gates/spec.md` | Already updated in specs stage | #86 |
| `openspec/specs/change-workspace/spec.md` | Already updated in specs stage | #88 |

## Goals & Success Metrics

* **SM-1**: `apply.instruction` in both WORKFLOW.md files contains explicit text distinguishing automated QA steps (3.1, 3.2) from human gate (3.3) — verified by grep for "automated" or "without pausing" in `apply.instruction`
* **SM-2**: Verify SKILL.md contains auto-fix guidance with clear scope boundary (mechanically fixable vs. judgment-required) — verified by grep for "auto-fix" in verify SKILL.md
* **SM-3**: CONSTITUTION.md contains a "Template synchronization" convention mentioning both `openspec/WORKFLOW.md` and `src/templates/workflow.md` — verified by grep
* **SM-4**: `apply.instruction` in both WORKFLOW.md files contains post-merge worktree cleanup sequence (switch directory → remove worktree → delete branch) — verified by grep for "worktree remove" in `apply.instruction`

## Non-Goals

- Hard enforcement (hooks, validation scripts) for any of these conventions
- Changes to the tasks template structure (QA loop steps remain 3.1–3.6)
- Changes to `/opsx:new` skill (lazy cleanup already works)
- Modifying the preflight template or side-effect checklist

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Put automated-step guidance in `apply.instruction` (not tasks template) | `apply.instruction` is what the agent reads during execution; tasks template defines output format, not runtime behavior | Tasks template comment (wrong layer), apply SKILL.md (skill immutability) |
| Scope verify auto-fix to "mechanically fixable" (stale references, naming) | Prevents scope creep; judgment calls (spec/design divergence) must stay manual | Full auto-fix (too aggressive), no auto-fix (status quo friction) |
| Add "Template synchronization" as a constitution convention | Constitution owns project-specific conventions; the two-copy pattern is a project-level concern | WORKFLOW.md comment (not visible enough), CLAUDE.md rule (wrong scope) |
| Put post-merge cleanup in `apply.instruction` | The post-apply workflow already covers commit/push/approve; post-merge is the natural next step in that sequence | New skill (overkill), `/opsx:new` only (doesn't cover in-session merges) |

## Risks & Trade-offs

- [Convention-based enforcement] → Mitigation: Consistent with project philosophy (ADR-004, -006, -015); instruction text is the established enforcement mechanism
- [Consumer template divergence for worktree config] → Mitigation: The dual-update convention clarifies which fields must sync (behavior fields) vs. which may differ (worktree.enabled default)
- [Auto-fix scope creep in verify] → Mitigation: Explicit scope boundary in SKILL.md ("stale cross-references, inconsistent naming" = auto-fix; "spec/design divergence" = manual)
- [Post-merge cleanup from within CWD] → Mitigation: Instruction explicitly requires switching to main worktree first

## Open Questions

No open questions.

## Assumptions

- The agent reads and follows `apply.instruction` text during QA loop execution. <!-- ASSUMPTION: Agent instruction compliance -->
- `src/templates/constitution.md` has a Conventions section where the new convention can be added. <!-- ASSUMPTION: Constitution template structure -->
