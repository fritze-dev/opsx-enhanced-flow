# Research: Fix Friction Batch (#81, #86, #87, #88)

## 1. Current State

Four friction issues target agent guidance gaps in the apply/verify workflow and template maintenance conventions. All four are instruction-level fixes — no code changes, only spec/skill/workflow/constitution text updates.

### #81 — Agent pauses before /opsx:verify
- **Affected:** `apply.instruction` in WORKFLOW.md (both `openspec/WORKFLOW.md` and `src/templates/workflow.md`)
- **Root cause:** The apply skill processes QA Loop tasks (3.1 Metric Check, 3.2 Auto-Verify, 3.3 User Testing) as regular pending tasks. Nothing distinguishes automated steps from human gates. The agent, uncertain whether to invoke a command autonomously, pauses to ask.
- **Current state:** The tasks template labels step 3.2 as "Auto-Verify" — the "Auto-" prefix implies autonomous execution, but the apply skill instruction doesn't reinforce this. The `apply.instruction` in WORKFLOW.md mentions the post-apply workflow sequence but doesn't clarify which QA steps are automated vs. human-gated.

### #86 — Verify reports trivially fixable WARNINGs instead of auto-fixing
- **Affected:** Verify SKILL.md (`src/skills/verify/SKILL.md`), quality-gates spec (`openspec/specs/quality-gates/spec.md`)
- **Root cause:** The verify skill instruction says to present all findings in a report — no distinction between WARNINGs requiring judgment and ones that are mechanically fixable (stale artifact cross-references, inconsistent naming).
- **Current state:** Verify skill output format groups issues as CRITICAL/WARNING/SUGGESTION with recommendations. The skill never auto-fixes anything — it's purely diagnostic. The spec says "Each issue found SHALL be classified as CRITICAL, WARNING, or SUGGESTION" without auto-fix guidance.

### #87 — Agent updates WORKFLOW.md but forgets consumer template
- **Affected:** CONSTITUTION.md conventions, potentially preflight side-effect checklist
- **Root cause:** No explicit dual-update convention exists. The constitution says "Plugin source code lives in `src/`" and "README accuracy" convention, but neither mentions the WORKFLOW.md ↔ `src/templates/workflow.md` sync requirement.
- **Current state:** Two copies exist:
  - `openspec/WORKFLOW.md` — project-local instance (active for this repo)
  - `src/templates/workflow.md` — consumer template (shipped to new projects via `/opsx:setup`)
  - These can diverge silently. The consumer template currently differs from the project version (e.g., worktree section is commented out in consumer template).

### #88 — Worktree cleanup after local merge
- **Affected:** `apply.instruction` in WORKFLOW.md, change-workspace spec (`openspec/specs/change-workspace/spec.md`)
- **Root cause:** Lazy cleanup in `/opsx:new` only handles stale worktrees from *previously* merged PRs. When the merge happens locally in the same session (via `gh pr merge` from within the worktree), the agent leaves the worktree behind.
- **Current state:** The `apply.instruction` covers post-apply workflow through commit/push and standard tasks, but says nothing about post-merge worktree cleanup. The change-workspace spec has "Lazy Worktree Cleanup at Change Creation" but no "immediate cleanup after merge" requirement.

## 2. External Research

Not applicable — all fixes are internal instruction/spec changes.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Instruction-only fixes (WORKFLOW.md apply.instruction + verify SKILL.md + constitution convention) | Minimal change surface; consistent with project's convention-based enforcement philosophy | Soft enforcement — agent may still deviate |
| B: Template-level changes (add auto-fix behavior to tasks template + verify template) | More structural enforcement | Templates define output format, not runtime behavior — wrong layer for these fixes |
| C: Spec-level changes only (update specs, let skills/instructions follow) | Specs drive everything | Specs alone don't guide agent behavior — instruction text is what the agent reads during execution |

**Recommended: Approach A** — with spec updates where behavior requirements change. This is consistent with how the project already works (ADR-015 "smart checkpoints", ADR-038 "commit before approval").

## 4. Risks & Constraints

- **Convention-based enforcement:** All four fixes rely on the agent reading and following instruction text. This is consistent with the project's philosophy (noted as a trade-off in ADR-004, ADR-006, ADR-015) but carries inherent soft-enforcement risk.
- **Dual-update for WORKFLOW.md:** The consumer template intentionally differs from the project instance (e.g., worktree disabled by default). The dual-update convention must clarify which fields must sync vs. which may differ.
- **Verify auto-fix scope creep:** Auto-fixing WARNINGs must be narrowly scoped to mechanically fixable issues (stale references, typos in artifact cross-references). Judgment calls (spec/design divergence) must remain reported-only.
- **Post-merge cleanup in worktree:** The agent cannot `git worktree remove` the current working directory. Cleanup requires switching directories first — instruction must be explicit about the sequence.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 4 friction issues with well-defined fixes |
| Behavior | Clear | Each issue has a concrete expected behavior from the GitHub issue |
| Data Model | Clear | No data model changes — text/instruction only |
| UX | Clear | Agent behavior improvements, no user-facing UI changes |
| Integration | Clear | Changes touch WORKFLOW.md, skills, constitution, specs — all internal |
| Edge Cases | Clear | Edge cases identified per issue (worktree CWD, sync divergence, auto-fix scope) |
| Constraints | Clear | Must respect three-layer architecture, skill immutability |
| Terminology | Clear | Existing terms: auto-verify, human gate, consumer template |
| Non-Functional | Clear | No performance or scalability impact |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

No user input required — proceeding.
