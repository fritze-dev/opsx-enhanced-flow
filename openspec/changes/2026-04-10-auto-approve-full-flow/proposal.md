<!--
---
status: completed
branch: worktree-auto-approve-full-flow
capabilities:
  new: []
  modified: [workflow-contract, human-approval-gate]
  removed: []
---
-->
## Why

When `auto_approve: true`, the workflow still pauses at the design checkpoint, between propose→apply, at the user testing gate, and between apply→finalize. This forces the user to intervene 3-4 times for routine changes where no genuine review is needed. `auto_approve` should mean "run end-to-end, only stop for real blockers." Closes #105.

## What Changes

- Update WORKFLOW.md propose instruction: skip design checkpoint when auto_approve is true
- Update WORKFLOW.md apply instruction: skip user testing pause when auto_approve is true and review.md verdict is PASS
- Update SKILL.md router: auto-dispatch propose→apply→finalize when auto_approve is true
- Update `workflow-contract` spec: expand auto_approve semantics to cover full flow + cross-action dispatch
- Update `human-approval-gate` spec: add auto_approve bypass scenario for QA loop
- Update CONSTITUTION.md: make design checkpoint respect auto_approve
- Sync consumer template (`src/templates/workflow.md`)
- Update capability docs

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workflow-contract`: Expand auto_approve semantics — when true, router auto-dispatches propose→apply→finalize; design checkpoint skipped; full end-to-end flow
- `human-approval-gate`: Add auto_approve bypass — when true and review.md verdict is PASS, QA loop auto-approves without user intervention

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed. Two existing specs modified.

Existing specs reviewed: workflow-contract (auto_approve field definition), human-approval-gate (QA loop approval requirement), artifact-pipeline (post-artifact commit), task-implementation (task execution). Only workflow-contract and human-approval-gate need changes.

## Impact

- **WORKFLOW.md**: Propose + apply instructions updated with auto_approve conditions
- **SKILL.md**: Router gains auto-dispatch logic for propose→apply→finalize
- **Specs**: workflow-contract (auto_approve semantics), human-approval-gate (bypass scenario)
- **Constitution**: Design checkpoint convention updated
- **Consumer template**: Synced instructions
- **Docs**: Capability docs updated

No breaking change — `auto_approve: false` behavior unchanged. `auto_approve: true` (the default) gains more comprehensive auto-continue behavior.

## Scope & Boundaries

**In scope:**
- All pause points listed in issue #105
- Spec, instruction, router, constitution, and doc updates

**Out of scope:**
- FAIL/BLOCKED paths — these always stop regardless of auto_approve
- Clarification questions — these always pause
- New configuration fields — reusing existing `auto_approve`
