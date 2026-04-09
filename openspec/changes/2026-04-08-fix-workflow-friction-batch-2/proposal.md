## Why

Five workflow frictions discovered during the diff-based-verify change (#83 → #90). The agent missed guidance that would have prevented user intervention: specs contained git commands, verify wasn't re-run after restructuring, preflight artifact went stale, and docs weren't proactively checked for stale terminology. All are fixable by adding explicit instruction text.

## What Changes

- Add **"no implementation details"** guardrail to specs template instruction — specs describe behavior, not commands/paths/APIs
- Add **fix-loop verify enforcement** to apply.instruction — after any fix-loop change, verify must re-run before presenting to user
- Add **artifact freshness** rule to apply.instruction — when a fix resolves a preflight/design issue, update the affected artifact
- Add **docs terminology check** reminder to apply.instruction — before user testing, check that docs/README don't reference stale terminology from changed specs

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

(none — all changes are instruction text in templates and WORKFLOW.md, not spec-level requirements)

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed, no existing specs modified. Changes are limited to template instruction text (`openspec/templates/specs/spec.md`) and WORKFLOW.md `apply.instruction`. These are authoring guidance, not capability requirements.

Existing specs reviewed: spec-format (owns spec formatting rules — but the fix is in the template instruction, not the spec), task-implementation (owns apply behavior — but the fix is in WORKFLOW.md instruction text, not the spec), quality-gates (owns verify — no verify changes needed).

## Impact

- **Template**: `openspec/templates/specs/spec.md` — one guardrail line added to instruction
- **WORKFLOW.md**: `openspec/WORKFLOW.md` apply.instruction — three guidance additions (fix-loop verify, artifact freshness, docs check)
- **Template sync**: `src/templates/workflow.md` must mirror WORKFLOW.md changes
- **No breaking changes** — all additions are advisory guidance for the agent

## Scope & Boundaries

**In scope:**
- Specs template instruction guardrail (no implementation details)
- Apply.instruction additions (fix-loop verify, artifact freshness, docs terminology check)
- Template synchronization (src/templates/workflow.md)

**Out of scope:**
- Spec-level requirement changes (not needed — frictions are about missing guidance)
- Verify SKILL.md changes (instruction text is sufficient)
- New commands or flags
