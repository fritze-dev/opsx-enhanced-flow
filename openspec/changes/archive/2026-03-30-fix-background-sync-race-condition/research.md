# Research: Fix Background Sync Race Condition

## 1. Current State

The archive skill ([SKILL.md:59](src/skills/archive/SKILL.md#L59)) invokes sync via the Agent/Task tool:

```
Automatically invoke sync using Task tool (subagent_type: "general-purpose", prompt: "Use Skill tool to invoke opsx:sync for change '<name>'. ...")
```

**The race condition has two root causes:**

1. **Insufficient subagent prompt**: The prompt ("Use Skill tool to invoke opsx:sync for change '<name>'.") does not convey that this is a blocking prerequisite for archive. The LLM has no context that sync must complete before the next step can start, so it may choose to launch it in the background or issue parallel tool calls.
2. **Missing result validation**: After the sync agent returns, the archive skill proceeds to step 5 (move directory) without validating that sync actually succeeded and wrote the expected changes. There is no gate between sync and archive.

**Affected files:**
- `src/skills/archive/SKILL.md` — step 4 (auto-sync delta specs), line 59
- `openspec/specs/change-workspace/spec.md` — "Auto-sync before archiving" scenario (line 80-85)
- `openspec/specs/spec-sync/spec.md` — assumption about sequential execution (line 94)

**Current spec language** (change-workspace spec, line 85):
> "SHALL proceed to archive after sync completes"

This correctly states the intent, but the skill implementation does not enforce it — the subagent prompt lacks context about why sync must complete first, and there is no validation of the sync result before archive proceeds.

**spec-sync assumption** (line 94):
> "Only one sync operation runs at a time; there is no concurrent merge protection beyond sequential execution."

This assumption depends on the caller ensuring sequential execution, which the archive skill currently does not enforce.

## 2. External Research

N/A — this is an internal workflow issue.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Fix subagent prompt + add result validation** — Improve the prompt to convey blocking intent; validate the agent result before proceeding to archive | Fixes both root causes. Preserves context isolation (sync in subagent). | Relies on LLM following improved prompt — but with clear context and a validation gate, the risk is minimal. |
| **B. Use Skill tool directly** — Replace the Agent/Task tool invocation with a direct Skill tool call | Structurally synchronous — cannot run in background. | Loses context isolation; sync consumes main context window tokens. Treats the symptom (background execution) rather than the causes (unclear prompt, missing validation). |
| **C. Restructure archive to commit after sync** — Add an explicit "wait for sync, then commit" sequence | Addresses the symptom (uncommitted changes). | Doesn't fix the root causes — sync could still race with the mv/archive step if prompt remains unclear. |

**Recommended**: Approach A. It addresses both root causes directly: the subagent prompt gets enough context to make correct scheduling decisions, and the validation gate ensures archive cannot proceed until sync is confirmed complete.

## 4. Risks & Constraints

- **Low risk**: The change is confined to the subagent prompt wording in the archive skill, adding a validation step, and a spec clarification.
- **No breaking changes**: The behavior (sync before archive) is already the intent — we're making the intent explicit in the prompt and adding a safety gate.
- **Skill immutability rule**: The constitution states skills are generic plugin code. This fix improves the archive skill's sync invocation, which is valid — it's a bug fix, not project-specific behavior.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Subagent prompt improvement + validation gate in archive skill + spec clarification |
| Behavior | Clear | Sync must complete and be validated before archive proceeds |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing changes — sync already runs automatically |
| Integration | Clear | Same Agent/Task tool, improved prompt and validation |
| Edge Cases | Clear | Sync failure already blocks archive (line 60); validation adds a second gate |
| Constraints | Clear | Skill immutability allows bug fixes |
| Terminology | Clear | No new terms |
| Non-Functional | Clear | Sync is fast; no performance concern |

All categories Clear — no open questions needed.

## 6. Open Questions

None — all categories are Clear.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Fix both root causes: improve subagent prompt + add result validation | The prompt lacks context about why sync is a blocking prerequisite — fix it at the source. The archive has no gate to verify sync completed — add validation. Together these address why the LLM made the wrong scheduling decision and prevent archive from proceeding on unverified state. | Switch to Skill tool (treats symptom, loses context isolation); restructure commit ordering (treats symptom, not causes) |
