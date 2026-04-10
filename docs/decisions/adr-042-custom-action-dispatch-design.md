# ADR-042: Custom Action Dispatch Design

## Status

Accepted (2026-04-10)

## Context

The router SKILL.md hardcodes 4 actions in Step 1 (validation) and Step 5 (dispatch). The `actions` array in WORKFLOW.md frontmatter is read but not used for validation -- it is ignored in favor of a hardcoded list. Consumer projects need to define their own workflow actions (e.g., QA review, deployment, linting) without modifying the plugin source. Three of the four built-in dispatch patterns (apply, finalize, init) already follow the identical Sub-Agent Execution pattern. The `propose` action is fundamentally different because it uses Pipeline Traversal logic. Opening the actions system to consumer-defined actions requires decisions about validation strategy, dispatch mechanism, execution mode, and change context handling.

## Decision

1. **Add a generic fallback in Step 5 rather than refactoring all 4 built-in actions** -- Minimizes change surface. The `propose` action has unique Pipeline Traversal logic that cannot be generalized, and built-in actions have requirement links that custom actions do not need. A fallback block after the built-in dispatch handles any action not in `[init, propose, apply, finalize]`.

2. **Execute custom action instructions directly instead of forcing a sub-agent** -- Custom actions may invoke skills that spawn their own sub-agents. Forcing a router-level sub-agent would cause unnecessary nesting and constrain custom action authors. The executing agent decides whether to handle inline or spawn a sub-agent based on the instruction content.

3. **Custom actions go through change context detection** -- Most custom actions operate on a change (QA review, deploy, lint). Actions that do not need change context can handle this in their instruction text, the same way `init` is explicitly excluded.

4. **Validate against the `actions` array, fall back to built-in list if WORKFLOW.md is missing** -- Graceful degradation for projects without WORKFLOW.md (pre-init). Hard-requiring WORKFLOW.md was rejected because `init` needs to work without it.

## Alternatives Considered

- Refactor all 4 actions into a single generic dispatch -- rejected because `propose` is fundamentally different (Pipeline Traversal vs. Sub-Agent Execution)
- Always spawn a sub-agent for custom actions -- rejected because it constrains custom action authors and causes unnecessary double-nesting when the instruction itself invokes skills with sub-agents
- Skip change context detection for custom actions -- rejected because most custom actions operate on a change and would lose access to useful context
- Hard-require WORKFLOW.md for all invocations -- rejected because `init` needs to work without it to bootstrap a project

## Consequences

### Positive

- Consumer projects can define custom workflow actions without modifying the plugin source
- Adding a custom action requires only WORKFLOW.md changes (adding to `actions` array + writing `## Action: <name>` section), preserving layer separation
- All 4 built-in actions retain their exact current behavior -- zero regression
- The router validates custom actions against the `actions` array, providing clear error messages for typos or missing actions
- Custom actions get full change context, enabling them to operate on the current change directory and branch

### Negative

- Custom action instruction quality depends entirely on the author -- the router provides no spec requirement links, so vague instructions may lead to poor execution
- Change context detection runs for all custom actions even if an action does not need it; the instruction must explicitly handle that case
- The generic fallback is a new code path that could diverge from built-in dispatch patterns over time

## References

- [Change: 2026-04-10-custom-actions](../../openspec/changes/2026-04-10-custom-actions/)
- [Spec: workflow-contract](../../openspec/specs/workflow-contract/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [ADR-041: Skill Consolidation](adr-041-skill-consolidation.md)
