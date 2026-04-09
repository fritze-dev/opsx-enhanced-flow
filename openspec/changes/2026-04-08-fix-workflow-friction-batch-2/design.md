# Technical Design: Fix Workflow Friction Batch 2

## Context

Five frictions surfaced during the diff-based-verify change where the agent lacked explicit guidance. All fixes are instruction text additions — no new features, no spec changes, no skill modifications.

Three files affected: specs template instruction, WORKFLOW.md apply.instruction, and the consumer template mirror.

## Architecture & Components

| Component | File | Change |
|-----------|------|--------|
| Specs template | `openspec/templates/specs/spec.md` | Add guardrail to instruction: specs describe behavior, not implementation details |
| WORKFLOW.md | `openspec/WORKFLOW.md` (apply.instruction) | Add 3 guidance lines: fix-loop verify, artifact freshness, docs terminology check |
| Consumer template | `src/templates/workflow.md` | Mirror WORKFLOW.md apply.instruction changes |

## Goals & Success Metrics

* Specs template instruction explicitly prohibits implementation details (git commands, file paths, API calls) — PASS/FAIL
* Apply.instruction requires verify re-run after fix-loop changes — PASS/FAIL
* Apply.instruction requires updating stale artifacts when underlying issues are fixed — PASS/FAIL
* Apply.instruction includes docs terminology check before user testing — PASS/FAIL
* Consumer template (src/templates/workflow.md) mirrors all apply.instruction changes — PASS/FAIL

## Non-Goals

* Spec-level requirement changes (not needed)
* Verify SKILL.md modifications (instruction text is sufficient)
* Automated enforcement (agent compliance via instruction text is the project pattern)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| All fixes via instruction text, no spec changes | Frictions are about missing agent guidance, not missing requirements; instruction text is the project's enforcement pattern | Spec changes (over-engineering for guidance additions); verify SKILL.md changes (breaks skill immutability for project-specific guidance) |
| Add concise lines to apply.instruction rather than separate sections | Apply.instruction is already ~50 lines; concise additions avoid information overload | Separate "Fix Loop Rules" section (too verbose); constitution convention (too indirect) |
| Mirror to src/templates/workflow.md | Required by constitution "Template synchronization" convention | Skip sync (violates constitution) |

## Risks & Trade-offs

- **Instruction bloat** → Additions are 3 concise lines (one per friction cluster), not paragraphs. Acceptable.
- **Soft enforcement** → Consistent with all other enforcement in the system. No alternative for instruction-based architecture.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
