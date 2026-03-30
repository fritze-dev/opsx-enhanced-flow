# ADR-036: Fix Sync Race Condition in Archive

## Status

Accepted (2026-03-30)

## Context

The archive skill delegates spec sync to a subagent via the Agent/Task tool during step 4 (auto-sync delta specs). In production, the sync agent was observed finishing after the archive commit had already been made, leaving uncommitted spec changes in `openspec/specs/`. Investigation revealed two root causes: the subagent prompt lacked context about why sync is a blocking prerequisite for archive, giving the LLM no reason to prioritize sequential execution; and there was no validation of the sync result before the archive step proceeded. The existing spec language ("SHALL proceed to archive after sync completes") stated the correct intent but was not enforced at the skill level. The archive skill already uses state-based validation in steps 2 and 3 (checking artifact completion and task completion by inspecting file state), providing a proven pattern to follow.

## Decision

1. **Rewrite subagent prompt to include blocking context** — the LLM needs to understand *why* sync must complete first, not just *what* to do. Explaining that sync writes files needed for the archive commit gives the LLM enough context to prioritize sequential execution.
2. **State-based validation via baseline spec existence** — follows the same pattern as steps 2 and 3 (check state, not output). Decoupled from sync skill's output format. For each delta spec capability, check that `openspec/specs/<capability>/spec.md` exists before proceeding to archive.

## Alternatives Considered

- **Add "do NOT use run_in_background" to prompt**: Treats the symptom (background execution) rather than the cause — the LLM could still parallelize tool calls even without the background flag.
- **Parse sync agent output text for success indicator**: Couples validation to the sync skill's output format, which is fragile and introduces an assumption on format stability.
- **Trust the agent result without validation**: The current behavior that caused the bug.

## Consequences

### Positive

- Archive cannot proceed without verified baseline specs for all delta spec capabilities — defense-in-depth against scheduling issues
- Validation is decoupled from sync output format — no assumptions about how the sync skill reports success
- Follows established pattern (steps 2/3 use the same state-check-before-proceed approach)

### Negative

- LLM may still ignore prompt context in edge cases, but the validation gate catches this as a safety net

## References

- [Archive: fix-background-sync-race-condition](../../openspec/changes/archive/2026-03-30-fix-background-sync-race-condition/)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [ADR-034: Auto-Sync Before Archive](adr-034-auto-sync-before-archive.md)
