# Pre-Flight Check: Auto-Sync Before Archive

## A. Traceability Matrix

- [x] Archive Completed Change (MODIFIED) → Scenario: Auto-sync before archiving → `src/skills/archive/SKILL.md` Step 4
- [x] Archive Completed Change (MODIFIED) → Scenario: Archive a completed change → `src/skills/archive/SKILL.md` Step 5 (unchanged)
- [x] Archive Completed Change (MODIFIED) → Scenario: Archive with incomplete artifacts → `src/skills/archive/SKILL.md` Step 2 (unchanged)
- [x] Archive Completed Change (MODIFIED) → Scenario: Archive target already exists → `src/skills/archive/SKILL.md` Step 5 (unchanged)
- [x] Archive Completed Change (MODIFIED) → Scenario: Archive with incomplete tasks → `src/skills/archive/SKILL.md` Step 3 (unchanged)

## B. Gap Analysis

No gaps identified. The change is narrowly scoped to removing a prompt and replacing it with automatic behavior. Edge cases are covered:
- No delta specs → skip sync (existing behavior, unchanged)
- Delta specs already synced → sync is a no-op (safe)
- Sync failure → blocks archive (new edge case in delta spec, covered)

## C. Side-Effect Analysis

- **`/opsx:sync` skill**: Not modified. Called the same way (via Task tool subagent). No side effects.
- **WORKFLOW.md `post_artifact` hook**: Refers to post-apply workflow as "verify → archive → changelog → docs". The sequence is unchanged — sync just happens automatically within archive now instead of being prompted.
- **Other archive steps**: Steps 1-3 and 5-7 are untouched. Only Step 4 changes.
- **Guardrails section**: The archive skill guardrail "If delta specs exist, always run the sync assessment and show the combined summary before prompting" needs updating to match auto-sync behavior.

## D. Constitution Check

No constitution updates needed. No new patterns or architectural changes introduced.

## E. Duplication & Consistency

- **Spec consistency**: The delta spec replaces the "Prompt for sync" scenario with "Auto-sync" — no duplication.
- **WORKFLOW.md line 19**: States "IMPORTANT: /opsx:verify MUST run before /opsx:sync or /opsx:archive." — still valid since sync now happens inside archive, and verify still precedes archive in the workflow.
- **No contradictions** with other specs.

## F. Assumption Audit

No assumption markers found in spec.md or design.md. Both explicitly state "No assumptions made."

## G. Review Marker Audit

No REVIEW markers found in any change artifacts.
