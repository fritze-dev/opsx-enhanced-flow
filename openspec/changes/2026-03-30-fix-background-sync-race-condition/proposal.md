## Why

The archive skill's sync invocation has two root causes for the race condition observed in #73: (1) the subagent prompt lacks context about why sync is a blocking prerequisite for archive, giving the LLM no reason to prioritize sequential execution, and (2) there is no validation of the sync result before archive proceeds — the skill moves straight to step 5 without confirming sync completed successfully.

## What Changes

- Improve the subagent prompt in the archive skill (step 4) to convey that sync is a blocking prerequisite — the archive cannot proceed until sync has completed and reported its results
- Add result validation after the sync agent returns to confirm sync succeeded before proceeding to archive (step 5)
- Update the `change-workspace` spec to codify the prompt clarity and validation requirements for auto-sync

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: Add requirement that the sync subagent prompt MUST convey blocking intent, and that the archive skill MUST validate sync completion from the agent result before proceeding.

### Consolidation Check

N/A — no new specs proposed. Reviewed `spec-sync` (covers sync mechanics, not archive invocation ordering) and `change-workspace` (covers archive behavior including auto-sync — correct target for this fix).

## Impact

- `src/skills/archive/SKILL.md` — step 4 subagent prompt and post-sync validation
- `openspec/specs/change-workspace/spec.md` — "Auto-sync before archiving" scenario

## Scope & Boundaries

**In scope:**
- Improve the subagent prompt to convey blocking intent and context
- Add validation gate on the sync agent result before archive proceeds
- Update spec to codify prompt clarity and validation requirements

**Out of scope:**
- Changing the sync skill itself
- Switching from Agent/Task tool to Skill tool (context isolation is desirable)
- General audit of other subagent prompts across skills
