---
status: active
branch: custom-actions
worktree: .claude/worktrees/custom-actions
capabilities:
  new: []
  modified: [workflow-contract, three-layer-architecture]
  removed: []
---
## Why

Consumer projects need to define their own workflow actions (e.g., QA review, deployment, linting) without modifying the OPSX plugin source. The router already reads the `actions` array from WORKFLOW.md but ignores it for validation and dispatch — it hardcodes 4 actions. Opening this to consumer-defined actions enables extensibility with minimal change.

## What Changes

- Router SKILL.md Step 1 validates actions against the `actions` array from WORKFLOW.md instead of a hardcoded list
- Router SKILL.md Step 5 adds a generic Sub-Agent Execution fallback for any action not in [init, propose, apply, finalize]
- Consumer WORKFLOW.md template gets a comment explaining custom action usage
- Specs updated to reflect that the system supports built-in + custom actions

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workflow-contract`: Inline Action Definitions and Router Dispatch Pattern requirements updated to support consumer-defined actions beyond the 4 built-in ones
- `three-layer-architecture`: Router + Actions Layer requirement updated from "4 commands" to "4 built-in commands + custom actions"

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed. Both modifications extend existing requirements in their natural home specs.

## Impact

- **Router SKILL.md** (`src/skills/workflow/SKILL.md`): ~10 lines changed (Step 1 dynamic validation + Step 5 generic fallback)
- **Consumer template** (`src/templates/workflow.md`): Comment added to frontmatter
- **Specs**: `workflow-contract/spec.md` and `three-layer-architecture/spec.md` updated
- **No breaking changes**: All 4 built-in actions retain their exact current behavior

## Scope & Boundaries

**In scope:**
- Dynamic action validation from `actions` array
- Generic Sub-Agent dispatch for custom actions
- Spec updates for the two affected capabilities
- Consumer template hint

**Out of scope:**
- Requirement links for custom actions (they use self-contained instructions)
- Custom pipeline stages (the `pipeline` array stays fixed for propose)
- Hook/lifecycle patterns (actions are the extension mechanism)
- The QA Review skill itself (that's a consumer-side implementation)
