---
has_decisions: true
---
# Technical Design: Custom Actions

## Context

The router SKILL.md currently hardcodes 4 actions in Step 1 (validation) and Step 5 (dispatch). The `actions` array in WORKFLOW.md frontmatter is read but not used for validation. Three of the four dispatch patterns (apply, finalize, init) already follow the identical Sub-Agent Execution pattern. The change opens the actions system so consumer projects can define additional actions via WORKFLOW.md alone.

## Architecture & Components

**Files affected:**

| File | Change |
|------|--------|
| `src/skills/workflow/SKILL.md` | Step 1: dynamic validation from `actions` array. Step 5: generic fallback block for custom actions. |
| `src/templates/workflow.md` | Add comment explaining custom actions in frontmatter. |

**Dispatch flow for custom actions:**

```
User: /opsx:workflow qa-review
  → Router Step 1: validate "qa-review" ∈ actions array from WORKFLOW.md ✓
  → Router Step 2: load WORKFLOW.md (already happens)
  → Router Step 3: change context detection (same as apply/finalize)
  → Router Step 4: read ## Action: qa-review → ### Instruction (no requirement links)
  → Router Step 5: generic fallback → spawn sub-agent with instruction + change context
```

**No new files, no new concepts.** The generic fallback reuses the existing Sub-Agent Execution pattern used by apply/finalize/init.

## Goals & Success Metrics

- Built-in actions (init, propose, apply, finalize) behave identically to before — zero regression
- Custom action defined in `actions` array + `## Action:` body section dispatches correctly via Sub-Agent
- Action not in `actions` array produces error with available actions list
- Missing `## Action:` section for a listed action produces clear error

## Non-Goals

- Custom pipeline stages (the `pipeline` array stays fixed for propose-time artifact generation)
- Requirement links for custom actions (instruction text is self-contained)
- Hook/lifecycle patterns around existing actions
- The QA Review skill itself (consumer-side implementation)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Generic fallback in Step 5 rather than refactoring all 4 actions | Minimizes change surface. propose has unique Pipeline Traversal logic that can't be generalized. apply/finalize/init have requirement links that custom actions don't need. | Refactor all actions into a single generic dispatch — rejected because propose is fundamentally different. |
| Custom actions go through change context detection | Most custom actions operate on a change (QA review, deploy, lint). Actions that don't need change context can handle this in their instruction. | Skip change context for custom actions — rejected because it would limit usefulness. |
| Validate against `actions` array, fall back to built-in list if WORKFLOW.md missing | Graceful degradation for projects without WORKFLOW.md (pre-init). | Hard-require WORKFLOW.md for all invocations — rejected because init needs to work without it. |

## Risks & Trade-offs

- **Custom action instruction quality depends on author**: The sub-agent receives only the instruction text, no curated spec requirements. If the instruction is vague, the sub-agent may underperform. → Mitigation: This is the consumer's responsibility, same as writing good apply/finalize instructions.
- **Change context detection for all custom actions**: Some custom actions may not need a change context (e.g., a project-wide linting action). → Mitigation: The instruction can tell the sub-agent to ignore the change context, or the consumer can add the action to the init-like skip list in a future iteration.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
