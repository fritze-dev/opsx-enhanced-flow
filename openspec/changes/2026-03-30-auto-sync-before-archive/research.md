# Research: Auto-Sync Before Archive

## 1. Current State

The `/opsx:archive` skill (Step 4 in `src/skills/archive/SKILL.md`) currently assesses delta spec sync state and prompts the user with options:
- **If changes needed:** "Sync now (recommended)" or "Archive without syncing"
- **If already synced:** "Archive now", "Sync anyway", "Cancel"

This prompt creates unnecessary friction because the workflow is linear and deterministic: the post-apply sequence is `/opsx:verify → /opsx:archive → /opsx:changelog → /opsx:docs`. Syncing before archive is always the correct choice — there is no valid reason to archive without syncing.

**Affected files:**
- `src/skills/archive/SKILL.md` — Step 4 (sync prompt logic)
- `openspec/specs/change-workspace/spec.md` — "Prompt for sync before archiving" scenario (lines 78-85) and requirement description (line 66)
- `docs/capabilities/change-workspace.md` — sync prompt documentation (line 54)

## 2. External Research

Not applicable — this is an internal workflow improvement.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Auto-sync silently, remove prompt entirely | Zero friction; sync always happens | User loses visibility into what was synced |
| B: Auto-sync with summary output (no prompt) | Zero friction; user sees what was synced | Slightly more output |

**Recommendation:** Approach B — auto-sync when delta specs exist but still show the summary of what changes were applied (adds/modifications/removals). This preserves transparency without adding friction.

## 4. Risks & Constraints

- **Low risk:** Sync is already the recommended default; removing the prompt just automates the expected choice.
- **Idempotency:** The sync operation is already designed to be idempotent (running twice gives the same result), so auto-syncing is safe.
- **Already-synced case:** When delta specs exist but are already synced, the auto-sync is a no-op — still safe.
- **No delta specs:** When no delta specs exist, the current behavior already skips the prompt — no change needed for this case.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Remove prompt from archive Step 4, auto-sync instead |
| Behavior | Clear | Show sync summary, skip prompt |
| Data Model | Clear | No data model changes |
| UX | Clear | Less friction, same transparency |
| Integration | Clear | Sync skill invocation stays the same |
| Edge Cases | Clear | No delta specs = skip; already synced = no-op |
| Constraints | Clear | Skill immutability respected (archive is the plugin's own skill) |
| Terminology | Clear | No new terms |
| Non-Functional | Clear | No performance impact |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Auto-sync with summary (Approach B) | Preserves transparency while eliminating unnecessary prompt | Silent auto-sync (less transparent) |
