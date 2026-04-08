# ADR-039: Fix Friction Batch — Agent Guidance Improvements

## Status

Accepted

## Context

Four friction issues (#81, #86, #87, #88) were observed in real workflow sessions where the agent either paused unnecessarily, missed auto-fixable issues, forgot to sync templates, or left stale worktrees. All four issues stemmed from gaps in instruction text — the agent followed the text literally but the text did not give clear enough guidance. The project uses convention-based enforcement (ADR-004, ADR-006, ADR-015), so the quality of instruction text directly determines agent behavior. Each fix needed to land in the correct architectural layer: `apply.instruction` in WORKFLOW.md for execution behavior, SKILL.md for command-specific guidance, and the constitution for project-wide conventions.

## Decision

1. **Put automated-step guidance in `apply.instruction`** — The QA Loop's Metric Check and Auto-Verify are marked as automated steps that run without pausing; the first human gate is User Testing. This belongs in `apply.instruction` because it governs apply execution behavior, not in the tasks template (which defines output format) or the apply SKILL.md (skill immutability).
2. **Scope verify auto-fix to mechanically fixable WARNINGs** — Stale cross-references, inconsistent naming, and outdated text correctable by simple text replacement are auto-fixed inline and noted as "WARNING (auto-fixed)" in the report. Judgment-required WARNINGs (spec/design divergence) remain as open issues for user resolution. This prevents scope creep while eliminating unnecessary friction.
3. **Add Template synchronization as a constitution convention** — Changes to WORKFLOW.md behavior fields (`apply.instruction`, `post_artifact`, `context`) must also be reflected in `src/templates/workflow.md`. The `worktree` config may intentionally differ. This is a project-level concern (two-copy pattern) that belongs in the constitution, not in a WORKFLOW.md comment or CLAUDE.md.
4. **Put post-merge worktree cleanup in `apply.instruction`** — After a successful `gh pr merge` from within a worktree, the agent switches to the main worktree, removes the completed worktree, and deletes the branch. This extends the post-apply workflow sequence already defined in `apply.instruction`, complementing the lazy cleanup at `/opsx:new`.

## Alternatives Considered

| Decision | Alternative | Why Rejected |
|----------|------------|--------------|
| Automated-step guidance in apply.instruction | Tasks template comment | Wrong layer — template defines output format, not runtime behavior |
| Automated-step guidance in apply.instruction | Apply SKILL.md | Skill immutability — skills must not contain project-specific behavior |
| Verify auto-fix scoped to mechanical | Full auto-fix for all WARNINGs | Too aggressive — judgment calls must remain manual |
| Verify auto-fix scoped to mechanical | No auto-fix (status quo) | Continues the friction that prompted #86 |
| Template sync as constitution convention | WORKFLOW.md comment | Not visible enough during editing |
| Template sync as constitution convention | CLAUDE.md rule | Wrong scope — CLAUDE.md is for agent instructions, not project conventions |
| Post-merge cleanup in apply.instruction | New skill for cleanup | Overkill — cleanup is a simple 3-step sequence |
| Post-merge cleanup in apply.instruction | Only lazy cleanup at /opsx:new | Doesn't cover in-session merges |

## Consequences

### Positive

- The agent no longer pauses unnecessarily before running `/opsx:verify` in the QA loop
- Trivially fixable verify WARNINGs are resolved automatically, reducing friction for the user
- WORKFLOW.md and its consumer template stay in sync via an explicit convention
- Worktrees are cleaned up immediately after merge instead of lingering until the next `/opsx:new`
- Pre-existing drift between project and consumer WORKFLOW.md resolved as part of this change

### Negative

- Convention-based enforcement remains soft — the agent may still deviate from instruction text. This is consistent with the project's established philosophy (ADR-004, ADR-006, ADR-015).
- The auto-fix scope boundary ("mechanically fixable" vs. "judgment-required") relies on the agent's judgment. Clear examples in the SKILL.md mitigate ambiguity.
- `apply.instruction` grows by ~12 lines across the two additions. Still well within readable bounds.

## References

- [Change: fix-friction-batch](../../openspec/changes/2026-04-08-fix-friction-batch/)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [ADR-015: Smart Workflow Checkpoints](adr-015-smart-workflow-checkpoints.md)
- [ADR-038: Commit Before Approval](adr-038-commit-before-approval-in-apply-instruction.md)
