<!--
---
status: completed
branch: auto-approve-default
capabilities:
  new: []
  modified: [workflow-contract, artifact-pipeline]
  removed: []
---
-->
## Why

`auto_approve: true` is commented out in WORKFLOW.md — the default is to pause at every checkpoint. In practice, experienced users review via PR anyway, making inline pauses redundant friction. The PR review is the real approval gate. Flipping the default reduces end-to-end friction while preserving all safety nets (FAIL always stops, design checkpoint is constitutional).

## What Changes

- Uncomment `auto_approve: true` in project `openspec/WORKFLOW.md`
- Uncomment `auto_approve: true` in consumer template `src/templates/workflow.md`
- Update `workflow-contract` spec: `auto_approve` defaults to `true` when absent
- Update `artifact-pipeline` spec: clarify checkpoint behavior under default auto-approve
- Documentation regenerated via finalize

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workflow-contract`: Change `auto_approve` from optional-defaults-false to optional-defaults-true
- `artifact-pipeline`: Update "Propose as Single Entry Point" requirement to reflect new default

### Removed Capabilities

(none)

### Consolidation Check

1. Existing specs reviewed: workflow-contract, artifact-pipeline, human-approval-gate, quality-gates
2. Overlap assessment: N/A — no new specs proposed. Changes are spec-level behavior changes to existing capabilities.
3. Merge assessment: N/A — no new capabilities to merge.

## Impact

- **WORKFLOW.md**: Single line uncommented
- **Consumer template**: Single line uncommented — consumers get auto-approve on next init/update
- **Specs**: Two specs updated with new default semantics
- **Behavior**: Pipeline checkpoints (preflight warnings, post-apply PASS) no longer pause by default. Design review checkpoint is unaffected (constitutional requirement).

## Scope & Boundaries

**In scope:**
- Flip `auto_approve` default to true in WORKFLOW.md and template
- Update workflow-contract and artifact-pipeline specs
- Docs regenerated via finalize

**Out of scope:**
- Design review checkpoint behavior (constitutional, independent of auto_approve)
- QA loop / human-approval-gate spec (FAIL always stops, unchanged)
- New auto_approve features or per-action granularity
