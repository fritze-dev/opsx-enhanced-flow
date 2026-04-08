# Research: Fix Workflow Friction Batch 2

## 1. Current State

Five frictions discovered during the diff-based-verify change (#83 → #90):

**Friction 1: Specs contain implementation details**
- `openspec/templates/specs/spec.md` instruction says "Edit spec files that define WHAT the system should do" but has no explicit guardrail against implementation details (git commands, file paths, API calls)
- During diff-based-verify, spec contained `git diff main...HEAD --name-only` — user had to point out specs should describe behavior only

**Friction 2: Verify not re-run after fix loop changes**
- `openspec/WORKFLOW.md` apply.instruction mentions the QA loop but doesn't explicitly require re-running verify after fix-loop changes before presenting to user
- Tasks.md template has step 3.5 "Final Verify" but the agent skipped it after restructuring the SKILL.md
- The apply.instruction says "QA Loop automated steps: Metric Check and Auto-Verify are automated" — but doesn't say verify must re-run after every fix-loop iteration

**Friction 3: Stale artifacts after fix**
- Preflight.md showed "PASS WITH WARNINGS" after the warning was already fixed in the spec
- Nothing in apply.instruction mentions keeping change artifacts up to date when their source issues are resolved during implementation

**Friction 4+5: Docs reference stale terminology after spec changes**
- After changing "three dimensions" → "two dimensions" in spec, capability doc and README still referenced old terminology
- User had to ask "musst du nicht noch readme oder constitution anpassen?"
- `/opsx:docs` in standard tasks regenerates capability docs, but doesn't cover manual README/constitution checks
- The post-apply workflow already runs `/opsx:docs` but the agent didn't proactively check docs for stale references before user testing

## 2. External Research

Not applicable — all fixes are instruction text changes.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Fix all 5 via instruction text changes in templates + WORKFLOW.md | Minimal scope, consistent with existing enforcement pattern | Soft enforcement (agent compliance), not hard gates |
| B: Add automated checks (e.g., verify scans docs for stale terminology) | Harder enforcement | Over-engineering for instruction-based system; adds complexity to verify |
| C: Mix — instructions for 1-3, verify enhancement for 4-5 | Best of both | More files to change |

**Recommendation: Approach A** — all frictions are about missing guidance. The system already works via instructions (apply.instruction, template instructions). Adding the right words is the simplest and most consistent fix.

## 4. Risks & Constraints

- **Skill immutability**: Per constitution, skills are generic plugin code. Frictions #4-5 could be addressed via verify SKILL.md changes, but instruction text in apply.instruction is simpler and project-agnostic.
- **Instruction bloat**: apply.instruction is already long (50 lines). Adding more guidance risks information overload. Fixes should be concise.
- **Template synchronization**: Changes to WORKFLOW.md apply.instruction must be mirrored to `src/templates/workflow.md`.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 5 frictions, 3 affected files identified |
| Behavior | Clear | Each fix is a specific instruction text addition |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing command changes |
| Integration | Clear | Instruction changes only, no new dependencies |
| Edge Cases | Clear | Instructions are advisory, no edge cases beyond agent compliance |
| Constraints | Clear | Skill immutability respected |
| Terminology | Clear | No new terms introduced |
| Non-Functional | Clear | No performance impact |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
