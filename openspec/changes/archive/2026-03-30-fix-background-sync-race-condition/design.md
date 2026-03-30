# Technical Design: Fix Background Sync Race Condition

## Context

The archive skill's step 4 delegates spec sync to a subagent via the Agent/Task tool. The current subagent prompt is:

```
"Use Skill tool to invoke opsx:sync for change '<name>'. Delta spec analysis: <include the analyzed delta spec summary>"
```

This prompt lacks context about why sync must complete before archive proceeds. The LLM has no signal that this is a blocking prerequisite, so it may schedule the agent in the background or issue parallel tool calls. Additionally, there is no validation of the agent result — step 5 (mv to archive) starts unconditionally after the agent call.

## Architecture & Components

**Single file affected:** `src/skills/archive/SKILL.md` — step 4

Two changes within step 4:

1. **Subagent prompt** (line 59): Rewrite to convey blocking intent. The prompt must explain that sync writes to `openspec/specs/` and that these changes must be committed as part of the archive — therefore sync must complete and return its result before the workflow continues.

2. **State-based validation** (new, between current lines 60-61): After the sync agent returns, validate sync completion by checking file system state — the same pattern used by step 2 (artifact checklist) and step 3 (task checklist). For each delta spec at `openspec/changes/<name>/specs/<capability>/`, verify that a corresponding baseline spec exists at `openspec/specs/<capability>/spec.md`. This decouples validation from the sync skill's output format entirely.

**No other files change.** The sync skill itself, the spec-sync spec, and the workflow config remain untouched.

## Goals & Success Metrics

* **Prompt clarity**: The subagent prompt explicitly states that sync is a blocking prerequisite and must return its result before archive proceeds — PASS/FAIL by inspection of the prompt text.
* **Validation gate**: The archive skill contains a state-based validation step that checks baseline spec existence for each delta spec before proceeding to step 5 — PASS/FAIL by inspection of the skill text.
* **Failure path**: If any delta spec lacks a corresponding baseline spec after sync, the archive skill stops and reports which capabilities are missing — PASS/FAIL by inspection.

## Non-Goals

- Changing the sync skill's behavior or output format
- Switching from Agent/Task tool to Skill tool
- Deep content diffing (verifying specific requirements were merged) — existence check is sufficient
- Auditing other subagent invocations across skills

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Rewrite subagent prompt to include blocking context | The LLM needs to understand *why* sync must complete first — not just *what* to do. Explaining that sync writes files needed for the archive commit gives the LLM enough context to prioritize sequential execution. | Add "do NOT use run_in_background" (treats symptom, not cause — LLM could still parallelize tool calls) |
| State-based validation (baseline spec existence) | Follows the same pattern as step 2/3 (check state, not output). Decoupled from sync skill's output format — no assumption on format stability. Simple: for each delta spec capability, check that `openspec/specs/<capability>/spec.md` exists. | Parse sync agent output text (couples to output format, fragile); trust the agent (current behavior, caused the bug) |

## Risks & Trade-offs

- **[LLM may still ignore prompt context]** → Mitigation: The state-based validation gate is the safety net. Even if the LLM mishandles scheduling, the archive cannot proceed without baseline specs existing for all delta specs. The two fixes are defense-in-depth.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
